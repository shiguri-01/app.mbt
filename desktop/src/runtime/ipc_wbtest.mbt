///|
enum TestCommand {
  Increment(amount~ : Int)
} derive(Debug, Eq, ToJson, FromJson)

///|
enum TestEvent {
  CountChanged(Int)
} derive(Debug, Eq, ToJson, FromJson)

///|
fn[T : ToJson] bridge_request(body : T) -> String {
  let raw = @ipc.Envelope(body, id="req-1").stringify()
  Json::array([Json::string(raw)]).stringify()
}

///|
test "binding payload extracts first bridge argument" {
  let raw = @ipc.Envelope(Increment(amount=3)).stringify()
  let req = Json::array([Json::string(raw)]).stringify()
  assert_eq(binding_payload(req), raw)
}

///|
test "binding response returns typed ok response" {
  let req = bridge_request(Increment(amount=4))
  let raw = binding_response(req, command => {
    match command {
      Increment(amount~) => CountChanged(amount + 1)
    }
  })
  let response : @ipc.Response[TestEvent] = @json.from_json(@json.parse(raw))
  assert_true(response == Ok(CountChanged(5)))
}

///|
test "binding response reports decode error" {
  let raw = binding_response("[1]", (_ : TestCommand) => CountChanged(0))
  let response : @ipc.Response[TestEvent] = @json.from_json(@json.parse(raw))
  assert_true(response is Err(DecodeError(_)))
}
