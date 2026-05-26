///|
test "dialog command can be encoded as json" {
  let command = DialogCommand::AskQuestion
  let json = command.to_json()
  let decoded : DialogCommand = @json.from_json(json)
  assert_true(decoded == command)
}

///|
test "dialog event can be encoded as json" {
  let event = DialogEvent::DialogClosed(ChoiceYes)
  let json = event.to_json()
  let decoded : DialogEvent = @json.from_json(json)
  assert_true(decoded == event)
}
