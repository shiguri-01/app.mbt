///|
/// Typed request/response IPC endpoint.
///
/// Put endpoint values in a shared package and use the same value from the
/// runtime and frontend. The type parameters bind an application request type
/// to its response type at compile time.
pub struct IpcEndpoint[T, R](CommandId, T?, R?)

///|
pub fn[T, R] IpcEndpoint::named(command_id : String) -> IpcEndpoint[T, R] {
  IpcEndpoint(CommandId(command_id), None, None)
}

///|
pub fn[T, R] IpcEndpoint::default() -> IpcEndpoint[T, R] {
  IpcEndpoint(CommandId(default_bridge_name()), None, None)
}

///|
pub fn[T, R] IpcEndpoint::from_command_id(
  command_id : CommandId,
) -> IpcEndpoint[T, R] {
  IpcEndpoint(command_id, None, None)
}

///|
pub fn[T, R] IpcEndpoint::name(self : IpcEndpoint[T, R]) -> String {
  let IpcEndpoint(command_id, request_marker, response_marker) = self
  ignore(request_marker)
  ignore(response_marker)
  command_id.to_string()
}

///|
pub fn[T, R] IpcEndpoint::command_id(self : IpcEndpoint[T, R]) -> CommandId {
  let IpcEndpoint(command_id, request_marker, response_marker) = self
  ignore(request_marker)
  ignore(response_marker)
  command_id
}

///|
/// Typed host-to-frontend event endpoint.
pub struct IpcEvent[E](String, E?)

///|
pub fn[E] IpcEvent::named(name : String) -> IpcEvent[E] {
  IpcEvent(name, None)
}

///|
pub fn[E] IpcEvent::default() -> IpcEvent[E] {
  IpcEvent(default_event_name(), None)
}

///|
pub fn[E] IpcEvent::name(self : IpcEvent[E]) -> String {
  let IpcEvent(name, event_marker) = self
  ignore(event_marker)
  name
}
