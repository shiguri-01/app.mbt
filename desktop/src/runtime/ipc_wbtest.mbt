///|
enum TestCommand {
  Increment(amount~ : Int)
} derive(Debug, Eq, ToJson, FromJson)

///|
enum TestEvent {
  CountChanged(Int)
} derive(Debug, Eq, ToJson, FromJson)

///|
fn command_id(command : TestCommand) -> @ipc.CommandId {
  match command {
    Increment(_) => @ipc.CommandId("counter.increment")
  }
}

///|
fn bridge_request(body : TestCommand) -> String {
  let raw = @ipc.RequestFrame(body).stringify()
  Json::array([Json::string(raw)]).stringify()
}

///|
test "binding payload extracts first bridge argument" {
  let raw = @ipc.RequestFrame(Increment(amount=3)).stringify()
  let req = Json::array([Json::string(raw)]).stringify()
  assert_eq(binding_payload(req), raw)
}

///|
test "binding ipc response returns typed ok response" {
  let policy = @ipc.IpcPolicy::allow(classify=command_id, allowed=[
    @ipc.CommandId("counter.increment"),
  ])
  let req = bridge_request(Increment(amount=4))
  let raw = binding_ipc_response(req, policy, command => {
    match command {
      Increment(amount~) => CountChanged(amount + 1)
    }
  })
  let frame : @ipc.ResponseFrame[TestEvent] = @json.from_json(@json.parse(raw))
  assert_true(frame.response == Ok(CountChanged(5)))
}

///|
test "binding ipc response reports decode error" {
  let policy = @ipc.IpcPolicy::allow_all(classify=command_id)
  let raw = binding_ipc_response("[1]", policy, (_ : TestCommand) => {
    CountChanged(0)
  })
  let frame : @ipc.ResponseFrame[TestEvent] = @json.from_json(@json.parse(raw))
  assert_true(frame.response is Err(DecodeError(_)))
}

///|
test "binding ipc response reports unauthorized command" {
  let policy = @ipc.IpcPolicy::allow(classify=command_id, allowed=[
    @ipc.CommandId("counter.reset"),
  ])
  let raw = binding_ipc_response(bridge_request(Increment(amount=1)), policy, (
    _ : TestCommand,
  ) => CountChanged(0))
  let frame : @ipc.ResponseFrame[TestEvent] = @json.from_json(@json.parse(raw))
  assert_true(
    frame.response
    is Err(UnauthorizedCommand(@ipc.CommandId("counter.increment"))),
  )
}
