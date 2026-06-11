///|
test "file dialog endpoint carries command id" {
  assert_true(
    open_files_endpoint.command_id() == CommandId("file_dialog.open_files"),
  )
}

///|
test "file dialog event can be encoded as json" {
  let event = FileDialogEvent::Selected(["a.txt", "b.txt"])
  let json = event.to_json()
  let decoded : FileDialogEvent = @json.from_json(json)
  assert_true(decoded == event)
}
