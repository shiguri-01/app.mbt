///|
pub(all) enum FileDialogEvent {
  Selected(Array[String])
  Canceled
} derive(Debug, Eq, ToJson, FromJson)

///|
pub let event_endpoint : @ipc.IpcEvent[FileDialogEvent] = @ipc.IpcEvent::default()

///|
pub let open_file_endpoint : @ipc.IpcEndpoint[Unit, FileDialogEvent] = @ipc.IpcEndpoint::named(
  "file_dialog.open_file",
)

///|
pub let open_files_endpoint : @ipc.IpcEndpoint[Unit, FileDialogEvent] = @ipc.IpcEndpoint::named(
  "file_dialog.open_files",
)

///|
pub let save_file_endpoint : @ipc.IpcEndpoint[Unit, FileDialogEvent] = @ipc.IpcEndpoint::named(
  "file_dialog.save_file",
)

///|
pub let open_folder_endpoint : @ipc.IpcEndpoint[Unit, FileDialogEvent] = @ipc.IpcEndpoint::named(
  "file_dialog.open_folder",
)
