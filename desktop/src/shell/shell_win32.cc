#include <moonbit.h>

#include <cstdint>
#include <string>

#ifdef _WIN32
#include <windows.h>
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

static UINT message_kind_flag(int32_t kind) {
  switch (kind) {
  case 1:
    return MB_ICONWARNING;
  case 2:
    return MB_ICONERROR;
  case 3:
    return MB_ICONQUESTION;
  case 0:
  default:
    return MB_ICONINFORMATION;
  }
}

static UINT message_buttons_flag(int32_t buttons) {
  switch (buttons) {
  case 1:
    return MB_OKCANCEL;
  case 2:
    return MB_YESNO;
  case 3:
    return MB_YESNOCANCEL;
  case 0:
  default:
    return MB_OK;
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
  UINT flags = MB_TASKMODAL | message_kind_flag(kind) |
               message_buttons_flag(buttons);
  int result = MessageBoxW(static_cast<HWND>(parent), message_text.c_str(),
                           title_text.c_str(), flags);
  if (result == 0) {
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
