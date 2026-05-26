///|
/// Errors raised by native shell integrations.
pub(all) suberror ShellError {
  UnsupportedPlatform
  InvalidWindow
  InvalidFileFilter(String)
  DialogFailed(String)
  UnknownDialogResult(Int)
} derive(Debug, Eq)
