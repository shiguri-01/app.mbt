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
  endpoint : @ipc.IpcEndpoint[Unit, @shared.DialogEvent],
) -> Unit {
  self.status.set_text("Waiting for native dialog...")
  self.client.request_endpoint_with_callback(endpoint, (), (
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
  element_by_id("info").on_click(() => {
    model.send_command(@shared.show_info_endpoint)
  })
  element_by_id("warning").on_click(() => {
    model.send_command(@shared.show_warning_endpoint)
  })
  element_by_id("question").on_click(() => {
    model.send_command(@shared.ask_question_endpoint)
  })
}
