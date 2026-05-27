///|
extern "C" fn ffi_app_dir() -> Bytes = "moonbit_desktop_app_dir"

///|
fn join_path(base : String, relative : String) -> String {
  if base.has_suffix("/") || base.has_suffix("\\") {
    base + relative
  } else {
    base + "/" + relative
  }
}

///|
/// Directory containing the current native executable.
pub fn app_dir() -> String {
  @utf8.decode_lossy(ffi_app_dir())
}

///|
/// Directory containing packaged application resources.
///
/// The packager writes files under `resources` next to the executable.
pub fn resource_dir() -> String {
  join_path(app_dir(), "resources")
}

///|
/// Build a path inside the packaged `resources` directory.
pub fn resource_path(relative : String) -> String {
  join_path(resource_dir(), relative)
}
