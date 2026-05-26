///|
struct FileDialogModel {
  status : Element
  mut client : @desktop.Client
}

///|
fn describe_paths(paths : Array[String]) -> String {
  if paths.length() == 0 {
    "No path returned."
  } else {
    paths.join("\n")
  }
}

///|
fn FileDialogModel::send_command(
  self : FileDialogModel,
  command : @shared.FileDialogCommand,
) -> Unit {
  self.status.set_text("Waiting for native file dialog...")
  self.client = self.client.request_with_callback_default(command, (
    response : @ipc.Response[@shared.FileDialogEvent],
  ) => {
    match response {
      Ok(Selected(paths)) => self.status.set_text(describe_paths(paths))
      Ok(Canceled) => self.status.set_text("Canceled.")
      Err(err) => self.status.set_text("File dialog failed: \{to_repr(err)}")
    }
  })
}

///|
fn main {
  let model = { status: element_by_id("status"), client: Client() }
  element_by_id("open-file").on_click(() => model.send_command(OpenFile))
  element_by_id("open-files").on_click(() => model.send_command(OpenFiles))
  element_by_id("save-file").on_click(() => model.send_command(SaveFile))
  element_by_id("open-folder").on_click(() => model.send_command(OpenFolder))
}
