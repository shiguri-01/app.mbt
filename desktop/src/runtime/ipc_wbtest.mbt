///|
enum TestCommand {
  Increment(amount~ : Int)
} derive(Debug, Eq, ToJson, FromJson)

///|
enum TestEvent {
  CountChanged(Int)
} derive(Debug, Eq, ToJson, FromJson)

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
test "binding endpoint response returns typed ok response" {
  let req = bridge_request(Increment(amount=4))
  let raw = binding_endpoint_response(req, 65536, command => {
    match command {
      Increment(amount~) => CountChanged(amount + 1)
    }
  })
  let frame : @ipc.ResponseFrame[TestEvent] = @json.from_json(@json.parse(raw))
  assert_true(frame.response == Ok(CountChanged(5)))
}

///|
test "binding endpoint response reports decode error" {
  let raw = binding_endpoint_response("[1]", 65536, (_ : TestCommand) => {
    CountChanged(0)
  })
  let frame : @ipc.ResponseFrame[TestEvent] = @json.from_json(@json.parse(raw))
  assert_true(frame.response is Err(DecodeError(_)))
}

///|
test "binding endpoint response reports payload size limit" {
  let raw = binding_endpoint_response(bridge_request(Increment(amount=1)), 1, (
    _ : TestCommand,
  ) => CountChanged(1))
  let frame : @ipc.ResponseFrame[TestEvent] = @json.from_json(@json.parse(raw))
  assert_true(frame.response is Err(PayloadTooLarge(size=_, limit=1)))
}
