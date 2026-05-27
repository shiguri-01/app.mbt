///|
struct AppManifest {
  id : String
  name : String
  version : String
  module_name : String
  host : String
  frontend : String
  static_dir : String
  dist : String
  executable : String
  bundle : String?
  windows_subsystem : String?
} derive(FromJson, ToJson, Debug, Eq)

///|
fn AppManifest::bundle_kind(self : AppManifest) -> String {
  match self.bundle {
    Some(kind) => kind
    None => "dir"
  }
}

///|
fn AppManifest::windows_subsystem_kind(self : AppManifest) -> String {
  match self.windows_subsystem {
    Some(kind) => kind
    None => "windows"
  }
}

///|
fn read_text(path : String) -> String raise PackError {
  let content = @utf8.decode_lossy(ffi_read_text(@utf8.encode(path)))
  if content == "" {
    let detail = last_error()
    if detail != "" {
      fail_with("failed to read \{path}: \{detail}")
    }
  }
  content
}

///|
fn read_manifest(path : String) -> AppManifest raise PackError {
  let content = read_text(path)
  let json = @json.parse(content) catch {
    err => {
      fail_with("failed to parse \{path}: \{err.to_string()}")
      abort("unreachable")
    }
  }
  @json.from_json(json) catch {
    err => {
      fail_with("invalid manifest \{path}: \{err.to_string()}")
      abort("unreachable")
    }
  }
}
