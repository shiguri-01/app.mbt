///|
struct DialogModel {
  status : Element
  client : @desktop.Client
}

///|
fn describe_choice(choice : @shared.DialogChoice) -> String {
  match choice {
    ChoiceOk => "OK"
    ChoiceCancel => "Cancel"
    ChoiceYes => "Yes"
    ChoiceNo => "No"
  }
}

///|
fn DialogModel::send_command(
  self : DialogModel,
  command : @shared.DialogCommand,
) -> Unit {
  self.status.set_text("Waiting for native dialog...")
  self.client.request_with_callback_default(command, (
    response : @ipc.IpcResponse[@shared.DialogEvent],
  ) => {
    match response {
      Ok(DialogClosed(choice)) =>
        self.status.set_text("Selected: " + describe_choice(choice))
      Err(err) => self.status.set_text("Dialog failed: \{to_repr(err)}")
    }
  })
}

///|
fn main {
  let model = { status: element_by_id("status"), client: Client() }
  element_by_id("info").on_click(() => model.send_command(ShowInfo))
  element_by_id("warning").on_click(() => model.send_command(ShowWarning))
  element_by_id("question").on_click(() => model.send_command(AskQuestion))
}
