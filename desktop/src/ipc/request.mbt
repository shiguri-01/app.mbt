///|
/// A typed request that expects a reply.
pub struct Request[T] {
  id : String
  body : T
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn[T] Request::Request(body : T, id~ : String) -> Request[T] {
  { id, body }
}

///|
pub fn[T : ToJson] Request::to_envelope(self : Request[T]) -> Envelope {
  Envelope(self.body, id=self.id)
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
  Envelope(self, id~)
}
