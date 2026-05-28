///|
/// Call a desktop IPC endpoint from a Rabbita command.
///
/// The desktop bridge returns a JavaScript Promise. This helper registers
/// callbacks on that Promise and re-enters Rabbita through its scheduler.
pub fn[T : ToJson, R : FromJson] request_cmd(
  client~ : @frontend.Client,
  endpoint~ : @ipc.IpcEndpoint[T, R],
  body~ : T,
  on_response~ : (@ipc.IpcResponse[R]) -> @cmd.Cmd,
) -> @cmd.Cmd {
  @cmd.custom_cmd(scheduler => {
    client.request_callback(endpoint, body, response => {
      scheduler.add(on_response(response))
    })
  })
}
