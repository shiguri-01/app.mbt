///|
pub fn increment_message(amount : Int) -> String {
  @ipc.RequestFrame(@shared.IncrementRequest::{ amount, }).stringify()
}

///|
pub fn set_title_message(title : String) -> String {
  @ipc.RequestFrame(@shared.SetTitleRequest::{ title, }).stringify()
}
