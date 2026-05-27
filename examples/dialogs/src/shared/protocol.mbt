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
pub let event_endpoint : @ipc.IpcEvent[DialogEvent] = @ipc.IpcEvent::named(
  "dialog.event",
)

///|
pub let show_info_endpoint : @ipc.IpcEndpoint[Unit, DialogEvent] = @ipc.IpcEndpoint::named(
  "dialog.show_info",
)

///|
pub let show_warning_endpoint : @ipc.IpcEndpoint[Unit, DialogEvent] = @ipc.IpcEndpoint::named(
  "dialog.show_warning",
)

///|
pub let ask_question_endpoint : @ipc.IpcEndpoint[Unit, DialogEvent] = @ipc.IpcEndpoint::named(
  "dialog.ask_question",
)
