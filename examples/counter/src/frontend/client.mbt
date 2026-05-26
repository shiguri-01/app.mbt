///|
pub fn increment_message(amount : Int) -> String {
  let client = @desktop.Client()
  client.frame(@shared.IncrementRequest::{ amount, })
}

///|
pub fn set_title_message(title : String) -> String {
  let client = @desktop.Client()
  client.frame(@shared.SetTitleRequest::{ title, })
}
