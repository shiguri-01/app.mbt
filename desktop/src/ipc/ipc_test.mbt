///|
enum TestCommand {
  Parent(TestChildCommand)
} derive(Debug, Eq, ToJson, FromJson)

///|
enum TestChildCommand {
  Increment(amount~ : Int)
} derive(Debug, Eq, ToJson, FromJson)

///|
enum TestReply {
  CountChanged(Int)
} derive(Debug, Eq, ToJson, FromJson)

///|
test "request frame round trip" {
  let command = TestCommand::Parent(Increment(amount=3))
  let frame = @ipc.RequestFrame(command)
  let decoded : TestCommand = frame.decode()
  assert_true(decoded == command)
  assert_true(frame.version == 1)
}

///|
test "parse request frame json" {
  let command = TestCommand::Parent(Increment(amount=4))
  let parsed = parse_request_frame(@ipc.RequestFrame(command).stringify())
  let decoded : TestCommand = parsed.decode()
  assert_true(decoded == command)
}

///|
test "response frame round trip" {
  let frame = @ipc.ResponseFrame(Ok(TestReply::CountChanged(5)))
  let parsed : ResponseFrame[TestReply] = @json.from_json(frame.to_json())
  assert_true(parsed.response == Ok(CountChanged(5)))
}

///|
test "ipc error json round trip" {
  let err = @ipc.IpcError::PayloadTooLarge(size=10, limit=5)
  let decoded : @ipc.IpcError = @json.from_json(err.to_json())
  assert_true(decoded == err)
}

///|
test "policy rejects unauthorized command" {
  let policy = IpcPolicy::allow(
    classify=command => {
      match command {
        Parent(Increment(_)) => CommandId("counter.increment")
      }
    },
    allowed=[CommandId("counter.reset")],
  )
  let result : Result[Unit, IpcError] = try? policy.check(
    TestCommand::Parent(Increment(amount=1)),
  )
  assert_true(
    result
    is Err(
      @ipc.IpcError::UnauthorizedCommand(@ipc.CommandId("counter.increment"))
    ),
  )
}
