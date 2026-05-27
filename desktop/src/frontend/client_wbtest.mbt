///|
enum TestCommand {
  Increment(amount~ : Int)
} derive(Debug, Eq, ToJson, FromJson)

///|
test "client serializes request frame" {
  let raw = encode_request_frame(Increment(amount=2))
  let frame = @ipc.parse_request_frame(raw)
  let decoded : TestCommand = frame.decode()
  assert_true(decoded == Increment(amount=2))
  assert_true(frame.version == 1)
}
