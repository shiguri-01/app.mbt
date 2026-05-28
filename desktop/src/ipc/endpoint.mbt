///|
/// Typed request/response IPC endpoint.
///
/// Put endpoint values in a shared package and use the same value from the
/// runtime and frontend. The type parameters bind an application request type
/// to its response type at compile time.
pub struct IpcEndpoint[T, R] {
  priv command_id : CommandId
  priv request_marker : T?
  priv response_marker : R?
}

///|
/// Create an IPC endpoint with a stable command name.
pub fn[T, R] IpcEndpoint::named(command_id : String) -> IpcEndpoint[T, R] {
  {
    command_id: CommandId(command_id),
    request_marker: None,
    response_marker: None,
  }
}

///|
/// Return the endpoint command name used by the JavaScript bridge.
pub fn[T, R] IpcEndpoint::name(self : IpcEndpoint[T, R]) -> String {
  ignore(self.request_marker)
  ignore(self.response_marker)
  self.command_id.to_string()
}

///|
/// Return the endpoint command id used by policy and routing code.
pub fn[T, R] IpcEndpoint::command_id(self : IpcEndpoint[T, R]) -> CommandId {
  ignore(self.request_marker)
  ignore(self.response_marker)
  self.command_id
}

///|
/// Typed host-to-frontend event endpoint.
pub struct IpcEvent[E] {
  priv name : String
  priv event_marker : E?
}

///|
/// Create a typed host-to-frontend event descriptor.
pub fn[E] IpcEvent::named(name : String) -> IpcEvent[E] {
  { name, event_marker: None }
}

///|
/// Return the event name installed on the frontend bridge.
pub fn[E] IpcEvent::name(self : IpcEvent[E]) -> String {
  ignore(self.event_marker)
  self.name
}
