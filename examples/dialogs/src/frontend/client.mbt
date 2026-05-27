///|
pub fn info_message() -> String {
  @ipc.RequestFrame(()).stringify()
}

///|
pub fn question_message() -> String {
  @ipc.RequestFrame(()).stringify()
}
