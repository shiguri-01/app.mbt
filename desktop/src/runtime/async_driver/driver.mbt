///|
/// Run an async IPC handler to completion and return its typed response.
pub fn[R] run_response(
  handler : async () -> @ipc.Response[R],
) -> @ipc.Response[R] {
  let response : Ref[@ipc.Response[R]?] = Ref(None)
  @async.run_async_main(() => response.val = Some(handler()))
  match response.val {
    Some(response) => response
    None =>
      Err(HandlerError("async handler finished without producing a response"))
  }
}

///|
/// Run async setup and capture either completion, a raised error, or no result.
pub fn run_unit(handler : async () -> Unit) -> Result[Unit, Error]? {
  let result : Ref[Result[Unit, Error]?] = Ref(None)
  @async.run_async_main(() => {
    handler() catch {
      err => {
        result.val = Some(Err(err))
        return
      }
    }
    result.val = Some(Ok(()))
  })
  result.val
}
