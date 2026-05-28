///|
/// State loaded before the frontend starts.
pub(all) struct StartupState {
  recent_files : Array[String]
  last_file : String?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Application state mirrored into the frontend.
pub(all) struct AppState {
  recent_files : Array[String]
  last_file : String?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Request to open a file by path.
pub(all) struct OpenFileRequest {
  path : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Open Markdown document returned by the host.
pub(all) struct OpenDocument {
  path : String
  name : String
  content : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Reply from the native open-file dialog flow.
pub(all) struct OpenDialogReply {
  document : OpenDocument?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// File metadata returned after saving.
pub(all) struct SavedFile {
  path : String
  name : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Request to save Markdown content.
pub(all) struct SaveFileRequest {
  path : String?
  content : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Reply from save and save-as operations.
pub(all) struct SaveFileReply {
  file : SavedFile?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Dirty-state notification from the frontend.
pub(all) struct DirtyState {
  dirty : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Endpoint for loading startup state.
pub let load_startup_state_endpoint : @ipc.IpcEndpoint[Unit, StartupState] = @ipc.IpcEndpoint::named(
  "markdown_notes.load_startup_state",
)

///|
/// Endpoint for opening the native file picker.
pub let open_file_dialog_endpoint : @ipc.IpcEndpoint[Unit, OpenDialogReply] = @ipc.IpcEndpoint::named(
  "markdown_notes.open_file_dialog",
)

///|
/// Endpoint for opening a known file path.
pub let open_file_endpoint : @ipc.IpcEndpoint[OpenFileRequest, OpenDocument] = @ipc.IpcEndpoint::named(
  "markdown_notes.open_file",
)

///|
/// Endpoint for saving to the current file path.
pub let save_file_endpoint : @ipc.IpcEndpoint[SaveFileRequest, SaveFileReply] = @ipc.IpcEndpoint::named(
  "markdown_notes.save_file",
)

///|
/// Endpoint for choosing a file path before saving.
pub let save_file_as_endpoint : @ipc.IpcEndpoint[SaveFileRequest, SaveFileReply] = @ipc.IpcEndpoint::named(
  "markdown_notes.save_file_as",
)

///|
/// Endpoint for updating the host dirty-state flag.
pub let set_dirty_endpoint : @ipc.IpcEndpoint[DirtyState, Unit] = @ipc.IpcEndpoint::named(
  "markdown_notes.set_dirty",
)
