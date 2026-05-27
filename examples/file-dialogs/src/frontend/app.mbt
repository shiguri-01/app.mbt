///|
struct FileDialogModel {
  status : Element
  client : @desktop.Client
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
async fn FileDialogModel::send_command(
  self : FileDialogModel,
  endpoint : @ipc.IpcEndpoint[Unit, @shared.FileDialogEvent],
) -> Unit {
  self.status.set_text("Waiting for native file dialog...")
  let response : @ipc.IpcResponse[@shared.FileDialogEvent] = self.client.request(
    endpoint,
    (),
  )
  match response {
    Ok(Selected(paths)) => self.status.set_text(describe_paths(paths))
    Ok(Canceled) => self.status.set_text("Canceled.")
    Err(err) => self.status.set_text("File dialog failed: \{to_repr(err)}")
  }
}

///|
fn main {
  let model = { status: element_by_id("status"), client: Client() }
  element_by_id("open-file").on_click_async(() => {
    model.send_command(@shared.open_file_endpoint)
  })
  element_by_id("open-files").on_click_async(() => {
    model.send_command(@shared.open_files_endpoint)
  })
  element_by_id("save-file").on_click_async(() => {
    model.send_command(@shared.save_file_endpoint)
  })
  element_by_id("open-folder").on_click_async(() => {
    model.send_command(@shared.open_folder_endpoint)
  })
}
