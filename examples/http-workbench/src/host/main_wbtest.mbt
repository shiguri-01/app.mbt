///|
test "method mapping covers all variants" {
  assert_true(method_to_request_method(Get) == @http.RequestMethod::Get)
  assert_true(method_to_request_method(Post) == @http.RequestMethod::Post)
  assert_true(method_to_request_method(Put) == @http.RequestMethod::Put)
  assert_true(method_to_request_method(Patch) == @http.RequestMethod::Patch)
  assert_true(method_to_request_method(Delete) == @http.RequestMethod::Delete)
  assert_true(method_to_request_method(Head) == @http.RequestMethod::Head)
  assert_true(method_to_request_method(Options) == @http.RequestMethod::Options)
}

///|
async test "missing state file produces default state" {
  let dir = @fs.tmpdir(prefix="http-workbench-test")
  let state = load_state_from_path(dir + "/missing.json")
  assert_true(state == @core.default_state())
}
