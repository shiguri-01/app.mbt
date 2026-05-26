///|
enum TestCommand {
  Parent(TestChildCommand)
} derive(Debug, Eq, ToJson, FromJson)

///|
enum TestChildCommand {
  Increment(amount~ : Int)
} derive(Debug, Eq, ToJson, FromJson)

///|
test "nested enum command round trip through envelope" {
  let command = TestCommand::Parent(Increment(amount=3))
  let envelope = @ipc.Envelope(command, id="req-1")
  let decoded : TestCommand = envelope.decode()
  assert_true(decoded == command)
  assert_true(envelope.id == Some("req-1"))
}

///|
test "parse envelope json" {
  let command = TestCommand::Parent(Increment(amount=4))
  let envelope = @ipc.Envelope(command, id="req-2")
  let parsed = parse_envelope(envelope.stringify())
  let decoded : TestCommand = parsed.decode()
  assert_true(decoded == command)
}

///|
test "event constructor creates envelope" {
  let command = TestCommand::Parent(Increment(amount=5))
  let event = @ipc.Event(command)
  let envelope = event.to_envelope()
  let decoded : TestCommand = envelope.decode()
  assert_true(decoded == command)
  assert_true(envelope.id is None)
}

///|
test "request constructor preserves id in envelope" {
  let command = TestCommand::Parent(Increment(amount=6))
  let request = @ipc.Request(command, id="req-3")
  let envelope = request.to_envelope()
  let decoded : TestCommand = envelope.decode()
  assert_true(decoded == command)
  assert_true(envelope.id == Some("req-3"))
}
