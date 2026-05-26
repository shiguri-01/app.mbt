///|
/// IPC capability policy for a typed application command protocol.
pub struct IpcPolicy[T] {
  classify : (T) -> CommandId
  allowed : Set[CommandId]?
  max_payload_bytes : Int
}

///|
pub fn[T] IpcPolicy::allow(
  classify~ : (T) -> CommandId,
  allowed~ : Array[CommandId],
  max_payload_bytes? : Int = 65536,
) -> IpcPolicy[T] {
  { classify, allowed: Some(Set::from_array(allowed)), max_payload_bytes }
}

///|
pub fn[T, R] IpcPolicy::allow_endpoint(
  classify~ : (T) -> CommandId,
  endpoint : IpcEndpoint[T, R],
  max_payload_bytes? : Int = 65536,
) -> IpcPolicy[T] {
  IpcPolicy::allow(
    classify~,
    allowed=[endpoint.command_id()],
    max_payload_bytes~,
  )
}

///|
pub fn[T, R] IpcPolicy::allow_endpoints(
  classify~ : (T) -> CommandId,
  endpoints~ : Array[IpcEndpoint[T, R]],
  max_payload_bytes? : Int = 65536,
) -> IpcPolicy[T] {
  IpcPolicy::allow(
    classify~,
    allowed=[ for endpoint in endpoints => endpoint.command_id() ],
    max_payload_bytes~,
  )
}

///|
pub fn[T] IpcPolicy::allow_all(
  classify~ : (T) -> CommandId,
  max_payload_bytes? : Int = 65536,
) -> IpcPolicy[T] {
  { classify, allowed: None, max_payload_bytes }
}

///|
pub fn[T] IpcPolicy::check(
  self : IpcPolicy[T],
  command : T,
) -> Unit raise IpcError {
  let command_id = (self.classify)(command)
  match self.allowed {
    None => ()
    Some(allowed) =>
      if !allowed.contains(command_id) {
        raise UnauthorizedCommand(command_id)
      }
  }
}
