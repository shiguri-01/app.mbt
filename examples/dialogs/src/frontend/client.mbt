///|
/// Build the raw IPC payload for showing the info dialog.
pub fn info_message() -> String {
  @ipc.RequestFrame(()).stringify()
}

///|
/// Build the raw IPC payload for showing the question dialog.
pub fn question_message() -> String {
  @ipc.RequestFrame(()).stringify()
}
