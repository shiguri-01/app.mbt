///|
/// HTTP method supported by the workbench request model.
pub(all) enum HttpMethod {
  Get
  Post
  Put
  Patch
  Delete
  Head
  Options
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Render the method as an uppercase HTTP verb.
pub fn HttpMethod::to_string(self : HttpMethod) -> String {
  match self {
    Get => "GET"
    Post => "POST"
    Put => "PUT"
    Patch => "PATCH"
    Delete => "DELETE"
    Head => "HEAD"
    Options => "OPTIONS"
  }
}

///|
/// Parse an uppercase HTTP verb, defaulting to `Get` for unknown input.
pub fn HttpMethod::parse(value : String) -> HttpMethod {
  match value {
    "POST" => Post
    "PUT" => Put
    "PATCH" => Patch
    "DELETE" => Delete
    "HEAD" => Head
    "OPTIONS" => Options
    _ => Get
  }
}

///|
/// Editable request header row.
pub(all) struct Header {
  name : String
  value : String
  enabled : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Saved or draft HTTP request.
pub(all) struct SavedRequest {
  id : String
  name : String
  http_method : HttpMethod
  url : String
  headers : Array[Header]
  body : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Summary of a completed HTTP request.
pub(all) struct HistoryEntry {
  id : String
  name : String
  http_method : HttpMethod
  url : String
  status : Int?
  error : String?
  duration_ms : Int64
  created_at_ms : Int64
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Header returned by an HTTP response.
pub(all) struct ResponseHeader {
  name : String
  value : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// IPC request for sending one HTTP request.
pub(all) struct SendHttpRequest {
  request : SavedRequest
} derive(Debug, Eq, ToJson, FromJson)

///|
/// IPC reply containing either response data or an error message.
pub(all) struct SendHttpReply {
  status : Int?
  status_text : String
  headers : Array[ResponseHeader]
  body : String
  duration_ms : Int64
  error : String?
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Reply returned after persisting workbench state.
pub(all) struct SaveStateReply {
  saved : Bool
  message : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Persisted workbench state shared by host and frontend.
pub(all) struct WorkbenchState {
  saved_requests : Array[SavedRequest]
  recent_history : Array[HistoryEntry]
  active_draft : SavedRequest
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Endpoint for loading persisted workbench state.
pub let load_state_endpoint : @ipc.IpcEndpoint[Unit, WorkbenchState] = @ipc.IpcEndpoint::named(
  "workbench.load_state",
)

///|
/// Endpoint for saving workbench state.
pub let save_state_endpoint : @ipc.IpcEndpoint[WorkbenchState, SaveStateReply] = @ipc.IpcEndpoint::named(
  "workbench.save_state",
)

///|
/// Endpoint for executing an HTTP request from the native host.
pub let send_http_endpoint : @ipc.IpcEndpoint[SendHttpRequest, SendHttpReply] = @ipc.IpcEndpoint::named(
  "workbench.send_http",
)
