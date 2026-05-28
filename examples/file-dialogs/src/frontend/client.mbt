///|
/// Build the raw IPC payload for opening a file picker.
pub fn open_file_message() -> String {
  @ipc.RequestFrame(()).stringify()
}

///|
/// Build the raw IPC payload for opening a folder picker.
pub fn open_folder_message() -> String {
  @ipc.RequestFrame(()).stringify()
}
