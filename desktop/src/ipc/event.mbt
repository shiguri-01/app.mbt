///|
/// A typed event that does not require a response.
pub struct Event[T] {
  body : T
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Create a typed one-way event.
pub fn[T] Event::Event(body : T) -> Event[T] {
  { body, }
}

///|
/// Encode this event as an envelope without a request id.
pub fn[T : ToJson] Event::to_envelope(self : Event[T]) -> Envelope {
  Envelope(self.body)
}
