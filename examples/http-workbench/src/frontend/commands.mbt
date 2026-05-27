///|
fn load_state_cmd(
  emit : @rabbita.Emit[Msg],
  client : @desktop.Client,
) -> @rabbita.Cmd {
  @desktop_rabbita.request_cmd(
    client~,
    endpoint=@core.load_state_endpoint,
    body=(),
    on_response=response => emit(StateLoaded(response)),
  )
}

///|
fn save_state_cmd(
  emit : @rabbita.Emit[Msg],
  client : @desktop.Client,
  state : @core.WorkbenchState,
) -> @rabbita.Cmd {
  @desktop_rabbita.request_cmd(
    client~,
    endpoint=@core.save_state_endpoint,
    body=state,
    on_response=response => emit(StateSaved(response)),
  )
}

///|
fn send_http_cmd(
  emit : @rabbita.Emit[Msg],
  client : @desktop.Client,
  request : @core.SavedRequest,
) -> @rabbita.Cmd {
  @desktop_rabbita.request_cmd(
    client~,
    endpoint=@core.send_http_endpoint,
    body=@core.SendHttpRequest::{ request, },
    on_response=response => emit(RequestSent(response)),
  )
}
