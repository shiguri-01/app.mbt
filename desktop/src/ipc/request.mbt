///|
/// A typed request that expects a reply.
pub(all) struct Request[T] {
  id : String
  body : T
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn[T : ToJson] Request::to_envelope(self : Request[T]) -> Envelope {
  Envelope::new(self.body, id=self.id)
}

///|
/// A typed response to a request.
pub(all) enum Response[T] {
  Ok(T)
  Err(IpcError)
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn[T : ToJson] Response::to_envelope(
  self : Response[T],
  id : String,
) -> Envelope {
  Envelope::new(self, id~)
}
