#include <moonbit.h>

#include <cstring>
#include <string>

#ifdef _WIN32
#include <windows.h>
#endif

static moonbit_bytes_t make_bytes_from_string(const std::string &text) {
  moonbit_bytes_t bytes =
      moonbit_make_bytes(static_cast<int32_t>(text.size()), 0);
  if (!text.empty()) {
    std::memcpy(bytes, text.data(), text.size());
  }
  return bytes;
}

#ifdef _WIN32
static std::string utf8_from_wide(const std::wstring &wide) {
  if (wide.empty()) {
    return {};
  }
  int size = WideCharToMultiByte(CP_UTF8, 0, wide.c_str(), -1, nullptr, 0,
                                 nullptr, nullptr);
  if (size <= 0) {
    return {};
  }
  std::string text(static_cast<size_t>(size - 1), '\0');
  WideCharToMultiByte(CP_UTF8, 0, wide.c_str(), -1, &text[0], size, nullptr,
                      nullptr);
  return text;
}
#endif

extern "C" {

MOONBIT_FFI_EXPORT
moonbit_bytes_t moonbit_desktop_app_dir(void) {
#ifdef _WIN32
  std::wstring buffer(MAX_PATH, L'\0');
  DWORD length = GetModuleFileNameW(nullptr, &buffer[0],
                                    static_cast<DWORD>(buffer.size()));
  while (length == buffer.size()) {
    buffer.resize(buffer.size() * 2);
    length = GetModuleFileNameW(nullptr, &buffer[0],
                                static_cast<DWORD>(buffer.size()));
  }
  if (length == 0) {
    return make_bytes_from_string(".");
  }
  buffer.resize(length);
  size_t separator = buffer.find_last_of(L"\\/");
  if (separator == std::wstring::npos) {
    return make_bytes_from_string(".");
  }
  return make_bytes_from_string(utf8_from_wide(buffer.substr(0, separator)));
#else
  return make_bytes_from_string(".");
#endif
}

}
