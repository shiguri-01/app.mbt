///|
test "enabled headers skip disabled and blank names" {
  let headers = [
    @contract.Header::{
      name: "Accept",
      value: "application/json",
      enabled: true,
    },
    { name: "  ", value: "ignored", enabled: true },
    { name: "X-Skip", value: "ignored", enabled: false },
  ]
  let result = enabled_headers(headers)
  assert_true(result["Accept"] == "application/json")
  assert_true(!result.contains("X-Skip"))
  assert_true(result.length() == 1)
}

///|
test "saved request upsert assigns a fresh id for draft" {
  let (_, request) = upsert_saved_request([], default_request(), new_id="req-1")
  assert_true(request.id == "req-1")
  assert_true(request.name == "New request")
}

///|
test "default state includes starter requests" {
  let state = default_state()
  assert_true(state.saved_requests.length() == 2)
  assert_true(state.saved_requests[0].name == "GET httpbin")
  assert_true(state.active_draft.id == "draft")
}
