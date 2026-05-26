///|
enum TestCommand {
  Increment(amount~ : Int)
} derive(Debug, Eq, ToJson, FromJson)

///|
test "client event serializes envelope without request id" {
  let raw = Client().event(Increment(amount=2))
  let envelope = @ipc.parse_envelope(raw)
  let decoded : TestCommand = envelope.decode()
  assert_true(decoded == Increment(amount=2))
  assert_true(envelope.id is None)
}

///|
test "client request envelope increments ids" {
  let client = Client()
  let (client, first) = client.request(Increment(amount=1))
  let (_, second) = client.request(Increment(amount=2))
  let first_envelope = @ipc.parse_envelope(first)
  let second_envelope = @ipc.parse_envelope(second)
  assert_true(first_envelope.id == Some("req-0"))
  assert_true(second_envelope.id == Some("req-1"))
}
