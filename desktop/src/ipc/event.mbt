///|
/// A typed event that does not require a response.
pub(all) struct Event[T] {
  body : T
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn[T : ToJson] Event::to_envelope(self : Event[T]) -> Envelope {
  Envelope(self.body)
}
