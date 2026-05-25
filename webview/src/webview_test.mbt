///|
test "version number is available" {
  let version = @webview.version_number()
  assert_true(version.length() > 0)
}

///|
test "size hint constructors are public" {
  let hints : Array[@webview.SizeHint] = [
    @webview.SizeHint::None,
    @webview.SizeHint::Min,
    @webview.SizeHint::Max,
    @webview.SizeHint::Fixed,
  ]
  assert_eq(hints.length(), 4)
}
