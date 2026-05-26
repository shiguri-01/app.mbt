///|
pub fn info_message() -> String {
  let client = @desktop.Client()
  client.event(@shared.DialogCommand::ShowInfo)
}

///|
pub fn question_message() -> String {
  let client = @desktop.Client()
  client.event(@shared.DialogCommand::AskQuestion)
}
