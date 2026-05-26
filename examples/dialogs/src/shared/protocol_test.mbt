///|
test "dialog endpoint carries command id" {
  assert_true(
    ask_question_endpoint.command_id() == @ipc.CommandId("dialog.ask_question"),
  )
}

///|
test "dialog event can be encoded as json" {
  let event = DialogEvent::DialogClosed(ChoiceYes)
  let json = event.to_json()
  let decoded : DialogEvent = @json.from_json(json)
  assert_true(decoded == event)
}
