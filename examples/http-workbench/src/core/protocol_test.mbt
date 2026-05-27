///|
test "workbench endpoints carry stable command ids" {
  assert_true(
    load_state_endpoint.command_id() == @ipc.CommandId("workbench.load_state"),
  )
  assert_true(
    save_state_endpoint.command_id() == @ipc.CommandId("workbench.save_state"),
  )
  assert_true(
    send_http_endpoint.command_id() == @ipc.CommandId("workbench.send_http"),
  )
}

///|
test "workbench state json roundtrip" {
  let state = WorkbenchState::{
    saved_requests: [default_request()],
    recent_history: [
      HistoryEntry::{
        id: "hist-1",
        name: "GET httpbin",
        http_method: Get,
        url: "https://httpbin.org/get",
        status: Some(200),
        error: None,
        duration_ms: 12L,
        created_at_ms: 1234L,
      },
    ],
    active_draft: default_request(),
  }
  let decoded : WorkbenchState = @json.from_json(state.to_json())
  assert_true(decoded == state)
}

///|
test "send request and reply json roundtrip" {
  let request = SendHttpRequest::{ request: default_request() }
  let reply = SendHttpReply::{
    status: Some(200),
    status_text: "OK",
    headers: [ResponseHeader::{ name: "content-type", value: "text/plain" }],
    body: "ok",
    duration_ms: 8L,
    error: None,
  }
  let decoded_request : SendHttpRequest = @json.from_json(request.to_json())
  let decoded_reply : SendHttpReply = @json.from_json(reply.to_json())
  assert_true(decoded_request == request)
  assert_true(decoded_reply == reply)
}
