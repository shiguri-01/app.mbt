///|
pub fn info_message() -> String {
  let client = @desktop.Client()
  client.frame(@shared.DialogCommand::ShowInfo)
}

///|
pub fn question_message() -> String {
  let client = @desktop.Client()
  client.frame(@shared.DialogCommand::AskQuestion)
}
