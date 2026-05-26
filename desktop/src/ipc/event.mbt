///|
/// A typed event that does not require a response.
pub struct Event[T] {
  body : T
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn[T] Event::Event(body : T) -> Event[T] {
  { body, }
}

///|
pub fn[T : ToJson] Event::to_envelope(self : Event[T]) -> Envelope {
  Envelope(self.body)
}
