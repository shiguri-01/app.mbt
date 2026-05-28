///|
/// Build the raw IPC payload for an increment request.
pub fn increment_message(amount : Int) -> String {
  @ipc.RequestFrame(@shared.IncrementRequest::{ amount, }).stringify()
}

///|
/// Build the raw IPC payload for a title update request.
pub fn set_title_message(title : String) -> String {
  @ipc.RequestFrame(@shared.SetTitleRequest::{ title, }).stringify()
}
