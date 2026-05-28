///|
/// Request to add `amount` to the counter.
pub(all) struct IncrementRequest {
  amount : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Request to replace the native window title.
pub(all) struct SetTitleRequest {
  title : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Reply containing the current counter value.
pub(all) struct CountChangedReply {
  count : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Reply containing the title applied by the host.
pub(all) struct WindowTitleChangedReply {
  title : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Endpoint for incrementing the counter.
pub let increment_endpoint : @ipc.IpcEndpoint[
  IncrementRequest,
  CountChangedReply,
] = @ipc.IpcEndpoint::named("counter.increment")

///|
/// Endpoint for resetting the counter to zero.
pub let reset_endpoint : @ipc.IpcEndpoint[Unit, CountChangedReply] = @ipc.IpcEndpoint::named(
  "counter.reset",
)

///|
/// Endpoint for updating the native window title.
pub let set_title_endpoint : @ipc.IpcEndpoint[
  SetTitleRequest,
  WindowTitleChangedReply,
] = @ipc.IpcEndpoint::named("window.set_title")
