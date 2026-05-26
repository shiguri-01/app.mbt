///|
/// Visual style for a native message dialog.
pub(all) enum MessageDialogKind {
  Info
  Warning
  Error
  Question
} derive(Debug, Eq)

///|
fn MessageDialogKind::to_int(self : MessageDialogKind) -> Int {
  match self {
    Info => 0
    Warning => 1
    Error => 2
    Question => 3
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
fn MessageDialogButtons::to_int(self : MessageDialogButtons) -> Int {
  match self {
    Ok => 0
    OkCancel => 1
    YesNo => 2
    YesNoCancel => 3
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
/// A file filter shown in native file open/save dialogs.
///
/// `extensions` must contain extension names without leading dots, such as
/// `["png", "jpg", "jpeg"]`.
pub(all) struct FileFilter {
  name : String
  extensions : Array[String]
} derive(Debug, Eq)
