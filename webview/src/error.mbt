///|
/// Errors reported by the native webview backend.
pub(all) suberror WebViewError {
  CreationFailed
  MissingDependency
  Canceled
  InvalidState
  InvalidArgument
  Unspecified
  Duplicate
  NotFound
  Unknown(Int)
} derive(Debug, Eq)

///|
fn check_status(status : Int) -> Unit raise WebViewError {
  match status {
    0 => ()
    -5 => raise MissingDependency
    -4 => raise Canceled
    -3 => raise InvalidState
    -2 => raise InvalidArgument
    -1 => raise Unspecified
    1 => raise Duplicate
    2 => raise NotFound
    code => raise Unknown(code)
  }
}
