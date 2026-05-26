///|
test "increment request can be encoded as json" {
  let request = IncrementRequest::{ amount: 2 }
  let json = request.to_json()
  let decoded : IncrementRequest = @json.from_json(json)
  assert_true(decoded == request)
}

///|
test "counter endpoint carries command id" {
  assert_true(
    increment_endpoint.command_id() == @ipc.CommandId("counter.increment"),
  )
  assert_true(reset_endpoint.command_id() == @ipc.CommandId("counter.reset"))
}
