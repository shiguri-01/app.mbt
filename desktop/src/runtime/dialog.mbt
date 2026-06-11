///|
/// Visual style for a native message dialog.
pub(all) enum MessageDialogKind {
  Info
  Warning
  Error
  Question
} derive(Debug, Eq)

///|
fn MessageDialogKind::to_shell(
  self : MessageDialogKind,
) -> @shell.MessageDialogKind {
  match self {
    Info => Info
    Warning => Warning
    Error => Error
    Question => Question
  }
}

///|
/// Button set shown by a native message dialog.
pub(all) enum MessageDialogButtons {
  Ok
  OkCancel
  YesNo
  YesNoCancel
} derive(Debug, Eq)

///|
fn MessageDialogButtons::to_shell(
  self : MessageDialogButtons,
) -> @shell.MessageDialogButtons {
  match self {
    Ok => Ok
    OkCancel => OkCancel
    YesNo => YesNo
    YesNoCancel => YesNoCancel
  }
}

///|
/// Button selected by the user in a native message dialog.
pub(all) enum MessageDialogResult {
  Ok
  Cancel
  Yes
  No
} derive(Debug, Eq)

///|
fn MessageDialogResult::from_shell(
  result : @shell.MessageDialogResult,
) -> MessageDialogResult {
  match result {
    Ok => Ok
    Cancel => Cancel
    Yes => Yes
    No => No
  }
}

///|
/// Show a native modal message dialog owned by this window.
pub fn Window::show_message_dialog(
  self : Window,
  message : String,
  title? : String,
  kind? : MessageDialogKind = Info,
  buttons? : MessageDialogButtons = Ok,
) -> MessageDialogResult raise DesktopError {
  let parent = self.view.native_window() catch {
    err => {
      raise_webview(err)
      abort("unreachable")
    }
  }
  let result = @shell.show_message_dialog(
    parent,
    message,
    title?,
    kind=kind.to_shell(),
    buttons=buttons.to_shell(),
  ) catch {
    err => {
      raise_shell(err)
      abort("unreachable")
    }
  }
  MessageDialogResult::from_shell(result)
}
