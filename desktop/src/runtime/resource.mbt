///|
priv type ResourceReadResult

///|
#borrow(name)
extern "C" fn ffi_read_resource(name : Bytes) -> ResourceReadResult = "moonbit_desktop_read_resource"

///|
#borrow(result)
extern "C" fn ffi_resource_status(result : ResourceReadResult) -> Int = "moonbit_desktop_resource_status"

///|
#borrow(result)
extern "C" fn ffi_resource_data(result : ResourceReadResult) -> Bytes = "moonbit_desktop_resource_data"

///|
#borrow(result)
extern "C" fn ffi_resource_error(result : ResourceReadResult) -> Bytes = "moonbit_desktop_resource_error"

///|
/// Read bytes from packaged resources.
///
/// Embedded single-exe resources are checked first. If none are embedded, or
/// the requested resource is not embedded, this falls back to `resources` next
/// to the executable.
pub fn resource_bytes(name : String) -> Bytes? raise DesktopError {
  let result = ffi_read_resource(@utf8.encode(name))
  match ffi_resource_status(result) {
    0 => Some(ffi_resource_data(result))
    1 => None
    _ => {
      let message = @utf8.decode_lossy(ffi_resource_error(result))
      raise InvalidState("failed to read resource \{name}: \{message}")
    }
  }
}

///|
/// Read a UTF-8 text file from packaged resources.
pub fn resource_text(name : String) -> String? raise DesktopError {
  match resource_bytes(name) {
    None => None
    Some(bytes) =>
      Some(
        @utf8.decode(bytes) catch {
          err => {
            raise InvalidState(
              "resource \{name} is not valid UTF-8: \{to_repr(err)}",
            )
            abort("unreachable")
          }
        },
      )
  }
}
