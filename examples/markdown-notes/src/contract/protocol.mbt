///|
pub(all) struct StartupState {
  recent_files : Array[String]
  last_file : String?
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct AppState {
  recent_files : Array[String]
  last_file : String?
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct OpenFileRequest {
  path : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct OpenDocument {
  path : String
  name : String
  content : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct OpenDialogReply {
  document : OpenDocument?
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct SavedFile {
  path : String
  name : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct SaveFileRequest {
  path : String?
  content : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct SaveFileReply {
  file : SavedFile?
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct DirtyState {
  dirty : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub let load_startup_state_endpoint : @ipc.IpcEndpoint[Unit, StartupState] = @ipc.IpcEndpoint::named(
  "markdown_notes.load_startup_state",
)

///|
pub let open_file_dialog_endpoint : @ipc.IpcEndpoint[Unit, OpenDialogReply] = @ipc.IpcEndpoint::named(
  "markdown_notes.open_file_dialog",
)

///|
pub let open_file_endpoint : @ipc.IpcEndpoint[OpenFileRequest, OpenDocument] = @ipc.IpcEndpoint::named(
  "markdown_notes.open_file",
)

///|
pub let save_file_endpoint : @ipc.IpcEndpoint[SaveFileRequest, SaveFileReply] = @ipc.IpcEndpoint::named(
  "markdown_notes.save_file",
)

///|
pub let save_file_as_endpoint : @ipc.IpcEndpoint[SaveFileRequest, SaveFileReply] = @ipc.IpcEndpoint::named(
  "markdown_notes.save_file_as",
)

///|
pub let set_dirty_endpoint : @ipc.IpcEndpoint[DirtyState, Unit] = @ipc.IpcEndpoint::named(
  "markdown_notes.set_dirty",
)
