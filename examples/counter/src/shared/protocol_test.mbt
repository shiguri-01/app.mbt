///|
test "nested command can be encoded as json" {
  let command = CounterAppCommand::Counter(CounterCommand::Increment(amount=2))
  let json = command.to_json()
  let decoded : CounterAppCommand = @json.from_json(json)
  assert_true(decoded == command)
}
