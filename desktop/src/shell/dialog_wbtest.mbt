///|
test "dialog result status mapping" {
  assert_true(dialog_result_from_status(1) is Ok)
  assert_true(dialog_result_from_status(2) is Cancel)
  assert_true(dialog_result_from_status(3) is Yes)
  assert_true(dialog_result_from_status(4) is No)
}

///|
test "dialog result status errors" {
  debug_inspect(
    try? dialog_result_from_status(-1),
    content="Err(InvalidWindow)",
  )
  debug_inspect(
    try? dialog_result_from_status(-2),
    content="Err(UnsupportedPlatform)",
  )
  debug_inspect(
    try? dialog_result_from_status(-3),
    content="Err(DialogFailed(\"message dialog failed\"))",
  )
  debug_inspect(
    try? dialog_result_from_status(99),
    content="Err(UnknownDialogResult(99))",
  )
}
