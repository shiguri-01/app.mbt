///|
fn dialog_result_from_status(
  status : Int,
) -> MessageDialogResult raise ShellError {
  match status {
    1 => Ok
    2 => Cancel
    3 => Yes
    4 => No
    -1 => raise InvalidWindow
    -2 => raise UnsupportedPlatform
    -3 => raise DialogFailed("message dialog failed")
    code => raise UnknownDialogResult(code)
  }
}

///|
/// Show a native modal message dialog for a webview-backed window.
pub fn show_message_dialog(
  parent : @webview.NativeWindow,
  message : String,
  title? : String,
  kind? : MessageDialogKind = Info,
  buttons? : MessageDialogButtons = Ok,
) -> MessageDialogResult raise ShellError {
  let caption = match title {
    Some(title) => title
    None => ""
  }
  let status = ffi_show_message_dialog(
    parent,
    @utf8.encode(message),
    @utf8.encode(caption),
    kind.to_int(),
    buttons.to_int(),
  )
  dialog_result_from_status(status)
}
