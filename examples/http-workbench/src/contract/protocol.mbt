///|
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
pub(all) struct Header {
  name : String
  value : String
  enabled : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct SavedRequest {
  id : String
  name : String
  http_method : HttpMethod
  url : String
  headers : Array[Header]
  body : String
} derive(Debug, Eq, ToJson, FromJson)

///|
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
pub(all) struct ResponseHeader {
  name : String
  value : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct SendHttpRequest {
  request : SavedRequest
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct SendHttpReply {
  status : Int?
  status_text : String
  headers : Array[ResponseHeader]
  body : String
  duration_ms : Int64
  error : String?
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct SaveStateReply {
  saved : Bool
  message : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct WorkbenchState {
  saved_requests : Array[SavedRequest]
  recent_history : Array[HistoryEntry]
  active_draft : SavedRequest
} derive(Debug, Eq, ToJson, FromJson)

///|
pub let load_state_endpoint : @ipc.IpcEndpoint[Unit, WorkbenchState] = @ipc.IpcEndpoint::named(
  "workbench.load_state",
)

///|
pub let save_state_endpoint : @ipc.IpcEndpoint[WorkbenchState, SaveStateReply] = @ipc.IpcEndpoint::named(
  "workbench.save_state",
)

///|
pub let send_http_endpoint : @ipc.IpcEndpoint[SendHttpRequest, SendHttpReply] = @ipc.IpcEndpoint::named(
  "workbench.send_http",
)
