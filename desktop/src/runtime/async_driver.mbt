///|
fn[R] run_async_response(
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
fn run_async_setup(
  on_ready : async (Window) -> Unit,
  window : Window,
) -> Unit raise DesktopError {
  let result : Ref[Result[Unit, Error]?] = Ref(None)
  @async.run_async_main(() => {
    on_ready(window) catch {
      err => {
        result.val = Some(Err(err))
        return
      }
    }
    result.val = Some(Ok(()))
  })
  match result.val {
    Some(Ok(_)) => ()
    Some(Err(err)) => raise_error_as_desktop(err)
    None =>
      raise InvalidState("async setup finished without producing a result")
  }
}
