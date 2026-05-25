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
    -5 => raise WebViewError::MissingDependency
    -4 => raise WebViewError::Canceled
    -3 => raise WebViewError::InvalidState
    -2 => raise WebViewError::InvalidArgument
    -1 => raise WebViewError::Unspecified
    1 => raise WebViewError::Duplicate
    2 => raise WebViewError::NotFound
    code => raise WebViewError::Unknown(code)
  }
}
