#include <moonbit.h>

#include <cstdlib>
#include <cstring>
#include <fstream>
#include <sstream>
#include <string>

#ifdef _WIN32
#include <windows.h>
#endif

#if __has_include(<filesystem>)
#include <filesystem>
namespace fs = std::filesystem;
#elif __has_include(<experimental/filesystem>)
#include <experimental/filesystem>
namespace fs = std::experimental::filesystem;
#else
#error "filesystem support is required"
#endif

static std::string g_last_error;

static const char *as_c_string(moonbit_bytes_t bytes) {
  return reinterpret_cast<const char *>(bytes);
}

static moonbit_bytes_t make_bytes_from_string(const std::string &text) {
  moonbit_bytes_t bytes =
      moonbit_make_bytes(static_cast<int32_t>(text.size()), 0);
  if (!text.empty()) {
    std::memcpy(bytes, text.data(), text.size());
  }
  return bytes;
}

static void clear_error() { g_last_error.clear(); }

static int32_t fail(const std::string &message) {
  g_last_error = message;
  return 1;
}

extern "C" {

MOONBIT_FFI_EXPORT
moonbit_bytes_t moonbit_packager_read_text(moonbit_bytes_t path) {
  clear_error();
  std::ifstream input(as_c_string(path), std::ios::binary);
  if (!input) {
    g_last_error = "could not open file";
    return make_bytes_from_string("");
  }
  std::ostringstream buffer;
  buffer << input.rdbuf();
  return make_bytes_from_string(buffer.str());
}

MOONBIT_FFI_EXPORT
int32_t moonbit_packager_make_dirs(moonbit_bytes_t path) {
  clear_error();
  try {
    fs::create_directories(fs::path(as_c_string(path)));
    return 0;
  } catch (const std::exception &err) {
    return fail(err.what());
  }
}

MOONBIT_FFI_EXPORT
int32_t moonbit_packager_copy_file(moonbit_bytes_t from, moonbit_bytes_t to) {
  clear_error();
  try {
    fs::path dest(as_c_string(to));
    if (dest.has_parent_path()) {
      fs::create_directories(dest.parent_path());
    }
    fs::copy_file(fs::path(as_c_string(from)), dest,
                  fs::copy_options::overwrite_existing);
    return 0;
  } catch (const std::exception &err) {
    return fail(err.what());
  }
}

MOONBIT_FFI_EXPORT
int32_t moonbit_packager_copy_tree(moonbit_bytes_t from, moonbit_bytes_t to) {
  clear_error();
  try {
    fs::path source(as_c_string(from));
    fs::path dest(as_c_string(to));
    fs::create_directories(dest);
    for (const auto &entry : fs::recursive_directory_iterator(source)) {
      const auto relative = fs::relative(entry.path(), source);
      const auto target = dest / relative;
      if (entry.is_directory()) {
        fs::create_directories(target);
      } else if (entry.is_regular_file()) {
        if (target.has_parent_path()) {
          fs::create_directories(target.parent_path());
        }
        fs::copy_file(entry.path(), target, fs::copy_options::overwrite_existing);
      }
    }
    return 0;
  } catch (const std::exception &err) {
    return fail(err.what());
  }
}

MOONBIT_FFI_EXPORT
int32_t moonbit_packager_run_command(moonbit_bytes_t command) {
  clear_error();
  int status = std::system(as_c_string(command));
  if (status != 0) {
    g_last_error = "command exited with status " + std::to_string(status);
  }
  return static_cast<int32_t>(status);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t moonbit_packager_last_error(void) {
  return make_bytes_from_string(g_last_error);
}

}
