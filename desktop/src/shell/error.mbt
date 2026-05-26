///|
/// Errors raised by native shell integrations.
pub(all) suberror ShellError {
  UnsupportedPlatform
  InvalidWindow
  DialogFailed(String)
  UnknownDialogResult(Int)
} derive(Debug, Eq)
