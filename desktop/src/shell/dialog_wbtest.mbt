///|
test "dialog result status mapping" {
  assert_true(dialog_result_from_status(1) is Ok)
  assert_true(dialog_result_from_status(2) is Cancel)
  assert_true(dialog_result_from_status(3) is Yes)
  assert_true(dialog_result_from_status(4) is No)
}

///|
test "dialog result status errors" {
  try dialog_result_from_status(-1) catch {
    error => debug_inspect(error, content="InvalidWindow")
  } noraise {
    _ => fail("expected InvalidWindow")
  }
  try dialog_result_from_status(-2) catch {
    error => debug_inspect(error, content="UnsupportedPlatform")
  } noraise {
    _ => fail("expected UnsupportedPlatform")
  }
  try dialog_result_from_status(-3) catch {
    error =>
      debug_inspect(error, content="DialogFailed(\"message dialog failed\")")
  } noraise {
    _ => fail("expected DialogFailed")
  }
  try dialog_result_from_status(99) catch {
    error => debug_inspect(error, content="UnknownDialogResult(99)")
  } noraise {
    _ => fail("expected UnknownDialogResult")
  }
}

///|
test "file filter validation accepts extension groups" {
  let filter = FileFilter::{ name: "Images", extensions: ["png", "jpg"] }
  validate_file_filter(filter)
}

///|
test "file filter validation rejects dotted extensions" {
  let filter = FileFilter::{ name: "Images", extensions: [".png"] }
  try validate_file_filter(filter) catch {
    error =>
      debug_inspect(
        error,
        content=(
          #|InvalidFileFilter("filter extension must not contain separators, wildcards, or dots")
        ),
      )
  } noraise {
    _ => fail("expected InvalidFileFilter")
  }
}
