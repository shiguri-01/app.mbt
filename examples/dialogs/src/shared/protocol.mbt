///|
pub(all) enum DialogCommand {
  ShowInfo
  ShowWarning
  AskQuestion
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) enum DialogChoice {
  ChoiceOk
  ChoiceCancel
  ChoiceYes
  ChoiceNo
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) enum DialogEvent {
  DialogClosed(DialogChoice)
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn command_id(command : DialogCommand) -> @ipc.CommandId {
  match command {
    ShowInfo => @ipc.CommandId("dialog.show_info")
    ShowWarning => @ipc.CommandId("dialog.show_warning")
    AskQuestion => @ipc.CommandId("dialog.ask_question")
  }
}
