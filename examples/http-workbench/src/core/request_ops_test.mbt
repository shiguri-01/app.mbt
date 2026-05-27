///|
test "enabled headers skip disabled and blank names" {
  let headers = [
    @contract.Header::{
      name: "Accept",
      value: "application/json",
      enabled: true,
    },
    @contract.Header::{ name: "  ", value: "ignored", enabled: true },
    @contract.Header::{ name: "X-Skip", value: "ignored", enabled: false },
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
  assert_true(request.name == "Untitled request")
}
