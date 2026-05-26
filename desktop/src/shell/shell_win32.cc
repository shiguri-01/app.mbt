#include <moonbit.h>

#include <cstdint>
#include <cstring>
#include <new>
#include <string>
#include <vector>

#ifdef _WIN32
#include <windows.h>
#include <commctrl.h>
#include "nfd.h"

#pragma comment(linker, "\"/manifestdependency:type='win32' "                 \
                       "name='Microsoft.Windows.Common-Controls' "            \
                       "version='6.0.0.0' processorArchitecture='*' "         \
                       "publicKeyToken='6595b64144ccf1df' language='*'\"")
#endif

static const char *as_c_string(moonbit_bytes_t bytes) {
  return reinterpret_cast<const char *>(bytes);
}

struct MoonBitFileDialogResult {
  int32_t status;
  std::vector<std::string> paths;
  std::string error;
};

static void finalize_file_dialog_result(void *ptr) {
  reinterpret_cast<MoonBitFileDialogResult *>(ptr)->~MoonBitFileDialogResult();
}

static MoonBitFileDialogResult *make_file_dialog_result(int32_t status) {
  void *memory = moonbit_make_external_object(finalize_file_dialog_result,
                                              sizeof(MoonBitFileDialogResult));
  return new (memory) MoonBitFileDialogResult{status, {}, {}};
}

static moonbit_bytes_t make_bytes_from_string(const std::string &text) {
  moonbit_bytes_t bytes =
      moonbit_make_bytes(static_cast<int32_t>(text.size()), 0);
  if (!text.empty()) {
    std::memcpy(bytes, text.data(), text.size());
  }
  return bytes;
}

#ifdef _WIN32
static std::wstring widen_utf8(const char *text) {
  if (text == nullptr || text[0] == '\0') {
    return std::wstring();
  }
  int len = MultiByteToWideChar(CP_UTF8, 0, text, -1, nullptr, 0);
  if (len <= 0) {
    return std::wstring();
  }
  std::wstring wide(static_cast<size_t>(len - 1), L'\0');
  MultiByteToWideChar(CP_UTF8, 0, text, -1, &wide[0], len);
  return wide;
}

static PCWSTR message_kind_icon(int32_t kind) {
  switch (kind) {
  case 1:
    return TD_WARNING_ICON;
  case 2:
    return TD_ERROR_ICON;
  case 3:
    return TD_INFORMATION_ICON;
  case 0:
  default:
    return TD_INFORMATION_ICON;
  }
}

static TASKDIALOG_COMMON_BUTTON_FLAGS message_buttons_flag(int32_t buttons) {
  switch (buttons) {
  case 1:
    return TDCBF_OK_BUTTON | TDCBF_CANCEL_BUTTON;
  case 2:
    return TDCBF_YES_BUTTON | TDCBF_NO_BUTTON;
  case 3:
    return TDCBF_YES_BUTTON | TDCBF_NO_BUTTON | TDCBF_CANCEL_BUTTON;
  case 0:
  default:
    return TDCBF_OK_BUTTON;
  }
}

static int32_t message_result_code(int result) {
  switch (result) {
  case IDOK:
    return 1;
  case IDCANCEL:
    return 2;
  case IDYES:
    return 3;
  case IDNO:
    return 4;
  default:
    return result;
  }
}

using TaskDialogIndirectFn = HRESULT(WINAPI *)(const TASKDIALOGCONFIG *, int *,
                                               int *, BOOL *);

static TaskDialogIndirectFn load_task_dialog_indirect() {
  static HMODULE module = LoadLibraryW(L"comctl32.dll");
  static TaskDialogIndirectFn fn = module == nullptr
                                     ? nullptr
                                     : reinterpret_cast<TaskDialogIndirectFn>(
                                           GetProcAddress(
                                               module,
                                               "TaskDialogIndirect"));
  return fn;
}

static int32_t show_message_box_fallback(HWND parent,
                                         const std::wstring &message_text,
                                         const std::wstring &title_text,
                                         int32_t kind, int32_t buttons) {
  UINT icon = MB_ICONINFORMATION;
  switch (kind) {
  case 1:
    icon = MB_ICONWARNING;
    break;
  case 2:
    icon = MB_ICONERROR;
    break;
  case 3:
    icon = MB_ICONQUESTION;
    break;
  default:
    break;
  }

  UINT button_flags = MB_OK;
  switch (buttons) {
  case 1:
    button_flags = MB_OKCANCEL;
    break;
  case 2:
    button_flags = MB_YESNO;
    break;
  case 3:
    button_flags = MB_YESNOCANCEL;
    break;
  default:
    break;
  }

  int result = MessageBoxW(parent, message_text.c_str(), title_text.c_str(),
                           MB_TASKMODAL | icon | button_flags);
  if (result == 0) {
    return -3;
  }
  return message_result_code(result);
}

static const char *null_if_empty(const char *text) {
  return text == nullptr || text[0] == '\0' ? nullptr : text;
}

static std::vector<std::string> split_filters(const char *text) {
  std::vector<std::string> parts;
  if (text == nullptr || text[0] == '\0') {
    return parts;
  }
  const char separator = 0x1f;
  const char *start = text;
  for (const char *cursor = text; true; ++cursor) {
    if (*cursor == separator || *cursor == '\0') {
      parts.emplace_back(start, static_cast<size_t>(cursor - start));
      if (*cursor == '\0') {
        break;
      }
      start = cursor + 1;
    }
  }
  return parts;
}

static std::vector<nfdu8filteritem_t>
make_nfd_filters(const std::vector<std::string> &names,
                 const std::vector<std::string> &specs) {
  std::vector<nfdu8filteritem_t> filters;
  if (names.size() != specs.size()) {
    return filters;
  }
  filters.reserve(names.size());
  for (size_t index = 0; index < names.size(); ++index) {
    filters.push_back({names[index].c_str(), specs[index].c_str()});
  }
  return filters;
}

static MoonBitFileDialogResult *make_nfd_error_result() {
  MoonBitFileDialogResult *result = make_file_dialog_result(-3);
  const char *error = NFD_GetError();
  result->error = error == nullptr ? "native file dialog failed" : error;
  NFD_ClearError();
  return result;
}

static MoonBitFileDialogResult *make_path_result(nfdresult_t nfd_result,
                                                 nfdu8char_t *out_path) {
  if (nfd_result == NFD_CANCEL) {
    return make_file_dialog_result(0);
  }
  if (nfd_result == NFD_ERROR) {
    return make_nfd_error_result();
  }
  if (out_path == nullptr) {
    MoonBitFileDialogResult *result = make_file_dialog_result(-3);
    result->error = "native file dialog returned no path";
    return result;
  }
  MoonBitFileDialogResult *result = make_file_dialog_result(1);
  result->paths.emplace_back(out_path);
  NFD_FreePathU8(out_path);
  return result;
}

static MoonBitFileDialogResult *make_path_set_result(nfdresult_t nfd_result,
                                                     const nfdpathset_t *paths) {
  if (nfd_result == NFD_CANCEL) {
    return make_file_dialog_result(0);
  }
  if (nfd_result == NFD_ERROR) {
    return make_nfd_error_result();
  }
  if (paths == nullptr) {
    MoonBitFileDialogResult *result = make_file_dialog_result(-3);
    result->error = "native file dialog returned no path set";
    return result;
  }

  MoonBitFileDialogResult *result = make_file_dialog_result(1);
  nfdpathsetsize_t count = 0;
  if (NFD_PathSet_GetCount(paths, &count) == NFD_ERROR) {
    NFD_PathSet_Free(paths);
    result->status = -3;
    const char *error = NFD_GetError();
    result->error = error == nullptr ? "native file dialog failed" : error;
    NFD_ClearError();
    return result;
  }
  for (nfdpathsetsize_t index = 0; index < count; ++index) {
    nfdu8char_t *path = nullptr;
    if (NFD_PathSet_GetPathU8(paths, index, &path) == NFD_ERROR) {
      NFD_PathSet_Free(paths);
      result->status = -3;
      const char *error = NFD_GetError();
      result->error = error == nullptr ? "native file dialog failed" : error;
      NFD_ClearError();
      return result;
    }
    result->paths.emplace_back(path);
    NFD_PathSet_FreePathU8(path);
  }
  NFD_PathSet_Free(paths);
  return result;
}

static MoonBitFileDialogResult *
show_nfd_file_dialog(HWND parent, int32_t kind, const char *filter_names,
                     const char *filter_specs, const char *default_path,
                     const char *default_name) {
  if (NFD_Init() == NFD_ERROR) {
    return make_nfd_error_result();
  }

  std::vector<std::string> names = split_filters(filter_names);
  std::vector<std::string> specs = split_filters(filter_specs);
  std::vector<nfdu8filteritem_t> filters = make_nfd_filters(names, specs);
  if (names.size() != specs.size()) {
    NFD_Quit();
    MoonBitFileDialogResult *result = make_file_dialog_result(-3);
    result->error = "file filter names and specs differ in length";
    return result;
  }

  nfdwindowhandle_t parent_window = {NFD_WINDOW_HANDLE_TYPE_WINDOWS, parent};
  nfdresult_t nfd_result = NFD_ERROR;
  MoonBitFileDialogResult *result = nullptr;
  nfdu8char_t *out_path = nullptr;
  const nfdpathset_t *out_paths = nullptr;

  switch (kind) {
  case 0: {
    nfdopendialogu8args_t args = {};
    args.filterList = filters.empty() ? nullptr : filters.data();
    args.filterCount = static_cast<nfdfiltersize_t>(filters.size());
    args.defaultPath = null_if_empty(default_path);
    args.parentWindow = parent_window;
    nfd_result = NFD_OpenDialogU8_With(&out_path, &args);
    result = make_path_result(nfd_result, out_path);
    break;
  }
  case 1: {
    nfdopendialogu8args_t args = {};
    args.filterList = filters.empty() ? nullptr : filters.data();
    args.filterCount = static_cast<nfdfiltersize_t>(filters.size());
    args.defaultPath = null_if_empty(default_path);
    args.parentWindow = parent_window;
    nfd_result = NFD_OpenDialogMultipleU8_With(&out_paths, &args);
    result = make_path_set_result(nfd_result, out_paths);
    break;
  }
  case 2: {
    nfdsavedialogu8args_t args = {};
    args.filterList = filters.empty() ? nullptr : filters.data();
    args.filterCount = static_cast<nfdfiltersize_t>(filters.size());
    args.defaultPath = null_if_empty(default_path);
    args.defaultName = null_if_empty(default_name);
    args.parentWindow = parent_window;
    nfd_result = NFD_SaveDialogU8_With(&out_path, &args);
    result = make_path_result(nfd_result, out_path);
    break;
  }
  case 3: {
    nfdpickfolderu8args_t args = {};
    args.defaultPath = null_if_empty(default_path);
    args.parentWindow = parent_window;
    nfd_result = NFD_PickFolderU8_With(&out_path, &args);
    result = make_path_result(nfd_result, out_path);
    break;
  }
  default:
    result = make_file_dialog_result(-3);
    result->error = "unknown file dialog kind";
    break;
  }

  NFD_Quit();
  return result;
}
#endif

extern "C" {

MOONBIT_FFI_EXPORT
int32_t moonbit_desktop_show_message_dialog(void *parent,
                                            moonbit_bytes_t message,
                                            moonbit_bytes_t title,
                                            int32_t kind, int32_t buttons) {
#ifdef _WIN32
  if (parent == nullptr) {
    return -1;
  }
  std::wstring message_text = widen_utf8(as_c_string(message));
  std::wstring title_text = widen_utf8(as_c_string(title));

  TaskDialogIndirectFn task_dialog_indirect = load_task_dialog_indirect();
  if (task_dialog_indirect == nullptr) {
    return show_message_box_fallback(static_cast<HWND>(parent), message_text,
                                     title_text, kind, buttons);
  }

  TASKDIALOGCONFIG config = {};
  config.cbSize = sizeof(config);
  config.hwndParent = static_cast<HWND>(parent);
  config.dwFlags = TDF_POSITION_RELATIVE_TO_WINDOW | TDF_SIZE_TO_CONTENT;
  config.dwCommonButtons = message_buttons_flag(buttons);
  config.pszWindowTitle = title_text.empty() ? nullptr : title_text.c_str();
  config.pszMainIcon = message_kind_icon(kind);
  config.pszMainInstruction = message_text.c_str();

  int result = 0;
  HRESULT hr = task_dialog_indirect(&config, &result, nullptr, nullptr);
  if (FAILED(hr) || result == 0) {
    return -3;
  }
  return message_result_code(result);
#else
  (void)parent;
  (void)message;
  (void)title;
  (void)kind;
  (void)buttons;
  return -2;
#endif
}

MOONBIT_FFI_EXPORT
MoonBitFileDialogResult *
moonbit_desktop_show_file_dialog(void *parent, int32_t kind,
                                 moonbit_bytes_t filter_names,
                                 moonbit_bytes_t filter_specs,
                                 moonbit_bytes_t default_path,
                                 moonbit_bytes_t default_name) {
#ifdef _WIN32
  if (parent == nullptr) {
    return make_file_dialog_result(-1);
  }
  return show_nfd_file_dialog(static_cast<HWND>(parent), kind,
                              as_c_string(filter_names),
                              as_c_string(filter_specs),
                              as_c_string(default_path),
                              as_c_string(default_name));
#else
  (void)parent;
  (void)kind;
  (void)filter_names;
  (void)filter_specs;
  (void)default_path;
  (void)default_name;
  return make_file_dialog_result(-2);
#endif
}

MOONBIT_FFI_EXPORT
int32_t moonbit_desktop_file_dialog_result_status(
    MoonBitFileDialogResult *result) {
  return result == nullptr ? -3 : result->status;
}

MOONBIT_FFI_EXPORT
int32_t moonbit_desktop_file_dialog_result_len(MoonBitFileDialogResult *result) {
  if (result == nullptr) {
    return 0;
  }
  return static_cast<int32_t>(result->paths.size());
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t moonbit_desktop_file_dialog_result_path_at(
    MoonBitFileDialogResult *result, int32_t index) {
  if (result == nullptr || index < 0 ||
      static_cast<size_t>(index) >= result->paths.size()) {
    return moonbit_make_bytes(0, 0);
  }
  return make_bytes_from_string(result->paths[static_cast<size_t>(index)]);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t moonbit_desktop_file_dialog_result_error(
    MoonBitFileDialogResult *result) {
  if (result == nullptr) {
    return make_bytes_from_string("file dialog result is null");
  }
  return make_bytes_from_string(result->error);
}

}
