///|
test "file dialog command can be encoded as json" {
  let command = FileDialogCommand::OpenFiles
  let json = command.to_json()
  let decoded : FileDialogCommand = @json.from_json(json)
  assert_true(decoded == command)
}

///|
test "file dialog event can be encoded as json" {
  let event = FileDialogEvent::Selected(["a.txt", "b.txt"])
  let json = event.to_json()
  let decoded : FileDialogEvent = @json.from_json(json)
  assert_true(decoded == event)
}
