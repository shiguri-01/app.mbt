///|
test "method mapping covers all variants" {
  assert_true(method_to_request_method(Get) == Get)
  assert_true(method_to_request_method(Post) == Post)
  assert_true(method_to_request_method(Put) == Put)
  assert_true(method_to_request_method(Patch) == Patch)
  assert_true(method_to_request_method(Delete) == Delete)
  assert_true(method_to_request_method(Head) == Head)
  assert_true(method_to_request_method(Options) == Options)
}

///|
async test "missing state file produces default state" {
  let dir = @fs.tmpdir(prefix="http-workbench-test")
  let state = load_state_from_path(dir + "/missing.json")
  assert_true(state == @core.default_state())
}
