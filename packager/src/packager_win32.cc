#include <moonbit.h>

#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <map>
#include <sstream>
#include <string>
#include <vector>

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

static const char k_bundle_magic[] = "MBTAPPRSRC000001";

static void write_u32(std::ofstream &output, uint32_t value) {
  unsigned char bytes[4]{
      static_cast<unsigned char>(value & 0xff),
      static_cast<unsigned char>((value >> 8) & 0xff),
      static_cast<unsigned char>((value >> 16) & 0xff),
      static_cast<unsigned char>((value >> 24) & 0xff),
  };
  output.write(reinterpret_cast<const char *>(bytes), sizeof(bytes));
}

static void write_u64(std::ofstream &output, uint64_t value) {
  unsigned char bytes[8]{};
  for (int i = 0; i < 8; ++i) {
    bytes[i] = static_cast<unsigned char>((value >> (i * 8)) & 0xff);
  }
  output.write(reinterpret_cast<const char *>(bytes), sizeof(bytes));
}

static bool read_file_bytes(const fs::path &path, std::string &data) {
  std::ifstream input(path, std::ios::binary);
  if (!input) {
    g_last_error = "could not open " + path.string();
    return false;
  }
  data.assign(std::istreambuf_iterator<char>(input),
              std::istreambuf_iterator<char>());
  if (!input.good() && !input.eof()) {
    g_last_error = "failed while reading " + path.string();
    return false;
  }
  return true;
}

static std::string normalize_resource_name(const fs::path &path) {
  std::string name = path.generic_string();
  while (!name.empty() && name[0] == '/') {
    name.erase(name.begin());
  }
  return name;
}

static bool collect_resource_tree(const fs::path &source,
                                  std::map<std::string, std::string> &files) {
  for (const auto &entry : fs::recursive_directory_iterator(source)) {
    if (!entry.is_regular_file()) {
      continue;
    }
    std::string data;
    if (!read_file_bytes(entry.path(), data)) {
      return false;
    }
    files[normalize_resource_name(fs::relative(entry.path(), source))] = data;
  }
  return true;
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
int32_t moonbit_packager_remove_path(moonbit_bytes_t path) {
  clear_error();
  try {
    fs::remove_all(fs::path(as_c_string(path)));
    return 0;
  } catch (const std::exception &err) {
    return fail(err.what());
  }
}

MOONBIT_FFI_EXPORT
int32_t moonbit_packager_embed_resources(moonbit_bytes_t exe,
                                         moonbit_bytes_t static_dir,
                                         moonbit_bytes_t frontend_js) {
  clear_error();
  try {
    std::map<std::string, std::string> files;
    if (!collect_resource_tree(fs::path(as_c_string(static_dir)), files)) {
      return 1;
    }
    std::string frontend;
    if (!read_file_bytes(fs::path(as_c_string(frontend_js)), frontend)) {
      return 1;
    }
    files["frontend.js"] = frontend;

    const fs::path exe_path(as_c_string(exe));
    const uint64_t offset = static_cast<uint64_t>(fs::file_size(exe_path));
    std::ofstream output(exe_path, std::ios::binary | std::ios::app);
    if (!output) {
      return fail("could not open executable for appending");
    }
    write_u32(output, static_cast<uint32_t>(files.size()));
    for (const auto &entry : files) {
      write_u32(output, static_cast<uint32_t>(entry.first.size()));
      write_u64(output, static_cast<uint64_t>(entry.second.size()));
      output.write(entry.first.data(),
                   static_cast<std::streamsize>(entry.first.size()));
      output.write(entry.second.data(),
                   static_cast<std::streamsize>(entry.second.size()));
    }
    write_u64(output, offset);
    output.write(k_bundle_magic, 16);
    if (!output) {
      return fail("failed while writing resource bundle");
    }
    return 0;
  } catch (const std::exception &err) {
    return fail(err.what());
  }
}

MOONBIT_FFI_EXPORT
int32_t moonbit_packager_set_windows_subsystem(moonbit_bytes_t exe,
                                               moonbit_bytes_t subsystem) {
  clear_error();
  try {
    const std::string mode = as_c_string(subsystem);
    uint16_t value = 0;
    if (mode == "windows" || mode == "gui") {
      value = 2;
    } else if (mode == "console") {
      value = 3;
    } else {
      return fail("unknown Windows subsystem: " + mode);
    }

    std::fstream file(as_c_string(exe),
                      std::ios::binary | std::ios::in | std::ios::out);
    if (!file) {
      return fail("could not open executable for subsystem patching");
    }

    file.seekg(0x3c);
    uint32_t pe_offset = 0;
    file.read(reinterpret_cast<char *>(&pe_offset), sizeof(pe_offset));
    if (!file) {
      return fail("could not read PE header offset");
    }

    file.seekg(pe_offset);
    char signature[4]{};
    file.read(signature, sizeof(signature));
    if (!file || std::memcmp(signature, "PE\0\0", 4) != 0) {
      return fail("not a PE executable");
    }

    const std::streamoff subsystem_offset =
      static_cast<std::streamoff>(pe_offset) + 4 + 20 + 68;
    file.seekp(subsystem_offset);
    file.write(reinterpret_cast<const char *>(&value), sizeof(value));
    if (!file) {
      return fail("could not write PE subsystem");
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
