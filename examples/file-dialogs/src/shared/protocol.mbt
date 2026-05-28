///|
/// Result reported by a native file dialog.
pub(all) enum FileDialogEvent {
  Selected(Array[String])
  Canceled
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Host-to-frontend event channel for dialog results.
pub let event_endpoint : @ipc.IpcEvent[FileDialogEvent] = @ipc.IpcEvent::named(
  "file_dialog.event",
)

///|
/// Endpoint that opens a single-file picker.
pub let open_file_endpoint : @ipc.IpcEndpoint[Unit, FileDialogEvent] = @ipc.IpcEndpoint::named(
  "file_dialog.open_file",
)

///|
/// Endpoint that opens a multi-file picker.
pub let open_files_endpoint : @ipc.IpcEndpoint[Unit, FileDialogEvent] = @ipc.IpcEndpoint::named(
  "file_dialog.open_files",
)

///|
/// Endpoint that opens a save-file picker.
pub let save_file_endpoint : @ipc.IpcEndpoint[Unit, FileDialogEvent] = @ipc.IpcEndpoint::named(
  "file_dialog.save_file",
)

///|
/// Endpoint that opens a folder picker.
pub let open_folder_endpoint : @ipc.IpcEndpoint[Unit, FileDialogEvent] = @ipc.IpcEndpoint::named(
  "file_dialog.open_folder",
)
