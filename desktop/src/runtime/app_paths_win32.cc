#include <moonbit.h>

#include <cstdint>
#include <cstring>
#include <fstream>
#include <iterator>
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

static const char *as_c_string(moonbit_bytes_t bytes) {
  return reinterpret_cast<const char *>(bytes);
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

static const char k_bundle_magic[] = "MBTAPPRSRC000001";

struct MoonBitResourceReadResult {
  int32_t status;
  std::string data;
  std::string error;
};

static void finalize_resource_read_result(void *ptr) {
  reinterpret_cast<MoonBitResourceReadResult *>(ptr)->~MoonBitResourceReadResult();
}

static MoonBitResourceReadResult *make_resource_result(int32_t status) {
  void *memory = moonbit_make_external_object(
      finalize_resource_read_result, sizeof(MoonBitResourceReadResult));
  return new (memory) MoonBitResourceReadResult{status, {}, {}};
}

static bool read_u32(std::ifstream &input, uint32_t &value) {
  unsigned char bytes[4]{};
  if (!input.read(reinterpret_cast<char *>(bytes), sizeof(bytes))) {
    return false;
  }
  value = static_cast<uint32_t>(bytes[0]) |
          (static_cast<uint32_t>(bytes[1]) << 8) |
          (static_cast<uint32_t>(bytes[2]) << 16) |
          (static_cast<uint32_t>(bytes[3]) << 24);
  return true;
}

static bool read_u64(std::ifstream &input, uint64_t &value) {
  unsigned char bytes[8]{};
  if (!input.read(reinterpret_cast<char *>(bytes), sizeof(bytes))) {
    return false;
  }
  value = 0;
  for (int i = 7; i >= 0; --i) {
    value = (value << 8) | bytes[i];
  }
  return true;
}

static std::string executable_path_utf8() {
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
    return {};
  }
  buffer.resize(length);
  return utf8_from_wide(buffer);
#else
  return {};
#endif
}

static std::string app_dir_utf8() {
  std::string exe = executable_path_utf8();
  size_t separator = exe.find_last_of("\\/");
  if (separator == std::string::npos) {
    return ".";
  }
  return exe.substr(0, separator);
}

static bool valid_resource_name(const std::string &name) {
  return !name.empty() && name[0] != '/' && name[0] != '\\' &&
         name.find("..") == std::string::npos &&
         name.find(':') == std::string::npos;
}

static bool read_all_file(const std::string &path, std::string &data,
                          std::string &error) {
  std::ifstream input(path, std::ios::binary);
  if (!input) {
    return false;
  }
  data.assign(std::istreambuf_iterator<char>(input),
              std::istreambuf_iterator<char>());
  if (!input.good() && !input.eof()) {
    error = "failed while reading " + path;
    return false;
  }
  return true;
}

static int32_t read_embedded_resource(const std::string &name,
                                      std::string &data,
                                      std::string &error) {
  const std::string exe = executable_path_utf8();
  if (exe.empty()) {
    return 1;
  }
  std::ifstream input(exe, std::ios::binary);
  if (!input) {
    return 1;
  }
  input.seekg(0, std::ios::end);
  std::streamoff size = input.tellg();
  constexpr std::streamoff footer_size = 8 + 16;
  if (size < footer_size) {
    return 1;
  }
  input.seekg(size - footer_size);
  uint64_t offset = 0;
  if (!read_u64(input, offset)) {
    return 1;
  }
  char magic[16]{};
  if (!input.read(magic, sizeof(magic)) ||
      std::memcmp(magic, k_bundle_magic, sizeof(magic)) != 0) {
    return 1;
  }
  if (offset >= static_cast<uint64_t>(size - footer_size)) {
    error = "invalid resource bundle offset";
    return 2;
  }
  input.seekg(static_cast<std::streamoff>(offset));
  uint32_t count = 0;
  if (!read_u32(input, count)) {
    error = "invalid resource bundle header";
    return 2;
  }
  for (uint32_t i = 0; i < count; ++i) {
    uint32_t name_len = 0;
    uint64_t data_len = 0;
    if (!read_u32(input, name_len) || !read_u64(input, data_len)) {
      error = "invalid resource bundle entry";
      return 2;
    }
    std::string entry_name(name_len, '\0');
    if (!input.read(&entry_name[0], static_cast<std::streamsize>(name_len))) {
      error = "invalid resource bundle entry name";
      return 2;
    }
    if (entry_name == name) {
      data.assign(static_cast<size_t>(data_len), '\0');
      if (data_len > 0 &&
          !input.read(&data[0], static_cast<std::streamsize>(data_len))) {
        error = "invalid resource bundle data";
        return 2;
      }
      return 0;
    }
    input.seekg(static_cast<std::streamoff>(data_len), std::ios::cur);
    if (!input) {
      error = "invalid resource bundle data span";
      return 2;
    }
  }
  return 1;
}

static int32_t read_resource(const std::string &name, std::string &data,
                             std::string &error) {
  if (!valid_resource_name(name)) {
    error = "invalid resource name";
    return 2;
  }
  int32_t embedded = read_embedded_resource(name, data, error);
  if (embedded != 1) {
    return embedded;
  }
  std::string path = app_dir_utf8() + "/resources/" + name;
  if (read_all_file(path, data, error)) {
    return 0;
  }
  if (!error.empty()) {
    return 2;
  }
  return 1;
}

extern "C" {

MOONBIT_FFI_EXPORT
moonbit_bytes_t moonbit_desktop_app_dir(void) {
#ifdef _WIN32
  return make_bytes_from_string(app_dir_utf8());
#else
  return make_bytes_from_string(".");
#endif
}

MOONBIT_FFI_EXPORT
MoonBitResourceReadResult *moonbit_desktop_read_resource(moonbit_bytes_t name) {
  auto *result = make_resource_result(1);
  result->status = read_resource(as_c_string(name), result->data, result->error);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t moonbit_desktop_resource_status(MoonBitResourceReadResult *result) {
  return result == nullptr ? 2 : result->status;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t moonbit_desktop_resource_data(MoonBitResourceReadResult *result) {
  return make_bytes_from_string(result == nullptr ? "" : result->data);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t moonbit_desktop_resource_error(MoonBitResourceReadResult *result) {
  return make_bytes_from_string(result == nullptr ? "missing result" : result->error);
}

}
