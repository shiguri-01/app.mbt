///|
/// Portable representation of a native dialog button choice.
pub(all) enum DialogChoice {
  ChoiceOk
  ChoiceCancel
  ChoiceYes
  ChoiceNo
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Event emitted after a native dialog closes.
pub(all) enum DialogEvent {
  DialogClosed(DialogChoice)
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Host-to-frontend event channel for dialog results.
pub let event_endpoint : @ipc.IpcEvent[DialogEvent] = @ipc.IpcEvent::named(
  "dialog.event",
)

///|
/// Endpoint that shows an informational dialog.
pub let show_info_endpoint : @ipc.IpcEndpoint[Unit, DialogEvent] = @ipc.IpcEndpoint::named(
  "dialog.show_info",
)

///|
/// Endpoint that shows a warning dialog.
pub let show_warning_endpoint : @ipc.IpcEndpoint[Unit, DialogEvent] = @ipc.IpcEndpoint::named(
  "dialog.show_warning",
)

///|
/// Endpoint that shows a question dialog.
pub let ask_question_endpoint : @ipc.IpcEndpoint[Unit, DialogEvent] = @ipc.IpcEndpoint::named(
  "dialog.ask_question",
)
