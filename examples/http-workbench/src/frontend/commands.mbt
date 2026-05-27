///|
fn load_state_cmd(
  emit : @rabbita.Emit[Msg],
  client : @desktop.Client,
) -> @rabbita.Cmd {
  @desktop_rabbita.request_cmd(
    client~,
    endpoint=@contract.load_state_endpoint,
    body=(),
    on_response=response => emit(StateLoaded(response)),
  )
}

///|
fn save_state_cmd(
  emit : @rabbita.Emit[Msg],
  client : @desktop.Client,
  state : @contract.WorkbenchState,
) -> @rabbita.Cmd {
  @desktop_rabbita.request_cmd(
    client~,
    endpoint=@contract.save_state_endpoint,
    body=state,
    on_response=response => emit(StateSaved(response)),
  )
}

///|
fn send_http_cmd(
  emit : @rabbita.Emit[Msg],
  client : @desktop.Client,
  request : @contract.SavedRequest,
) -> @rabbita.Cmd {
  @desktop_rabbita.request_cmd(
    client~,
    endpoint=@contract.send_http_endpoint,
    body=@contract.SendHttpRequest::{ request, },
    on_response=response => emit(RequestSent(response)),
  )
}
