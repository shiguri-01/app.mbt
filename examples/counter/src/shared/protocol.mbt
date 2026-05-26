///|
pub(all) struct IncrementRequest {
  amount : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct SetTitleRequest {
  title : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct CountChangedReply {
  count : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct WindowTitleChangedReply {
  title : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub let increment_endpoint : @ipc.IpcEndpoint[
  IncrementRequest,
  CountChangedReply,
] = @ipc.IpcEndpoint::named("counter.increment")

///|
pub let reset_endpoint : @ipc.IpcEndpoint[Unit, CountChangedReply] = @ipc.IpcEndpoint::named(
  "counter.reset",
)

///|
pub let set_title_endpoint : @ipc.IpcEndpoint[
  SetTitleRequest,
  WindowTitleChangedReply,
] = @ipc.IpcEndpoint::named("window.set_title")
