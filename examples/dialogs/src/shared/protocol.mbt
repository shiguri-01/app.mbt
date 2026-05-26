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
