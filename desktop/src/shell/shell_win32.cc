#include <moonbit.h>

#include <cstdint>
#include <string>

#ifdef _WIN32
#include <windows.h>
#include <commctrl.h>

#pragma comment(linker, "\"/manifestdependency:type='win32' "                 \
                       "name='Microsoft.Windows.Common-Controls' "            \
                       "version='6.0.0.0' processorArchitecture='*' "         \
                       "publicKeyToken='6595b64144ccf1df' language='*'\"")
#endif

static const char *as_c_string(moonbit_bytes_t bytes) {
  return reinterpret_cast<const char *>(bytes);
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

}
