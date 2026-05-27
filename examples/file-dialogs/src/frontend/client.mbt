///|
pub fn open_file_message() -> String {
  @ipc.RequestFrame(()).stringify()
}

///|
pub fn open_folder_message() -> String {
  @ipc.RequestFrame(()).stringify()
}
