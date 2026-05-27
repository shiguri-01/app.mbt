///|
suberror PackError {
  Failed(String)
} derive(Debug)

///|
fn last_error() -> String {
  @utf8.decode_lossy(ffi_last_error())
}

///|
fn fail_with(message : String) -> Unit raise PackError {
  raise Failed(message)
}

///|
fn require_status(action : String, status : Int) -> Unit raise PackError {
  if status != 0 {
    let detail = last_error()
    if detail == "" {
      fail_with("\{action} failed with status \{status}")
    } else {
      fail_with("\{action} failed: \{detail}")
    }
  }
}
