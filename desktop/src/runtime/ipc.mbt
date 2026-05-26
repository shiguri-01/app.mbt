///|
fn binding_payload(req : String) -> String raise @ipc.IpcError {
  let json = @json.parse(req) catch {
    err => raise DecodeError(err.to_string())
  }
  match json {
    Array(args) =>
      match args.get(0) {
        Some(String(raw)) => raw
        Some(_) =>
          raise DecodeError("desktop bridge first argument must be a string")
        None =>
          raise DecodeError("desktop bridge call must include one argument")
      }
    _ => raise DecodeError("desktop bridge request must be a JSON array")
  }
}

///|
fn payload_too_large(raw : String, limit : Int) -> Bool {
  limit >= 0 && raw.length() > limit
}

///|
fn err_response(err : @ipc.IpcError) -> String {
  @ipc.response_err(err)
}

///|
fn[T : FromJson] decode_command(
  raw : String,
  policy : @ipc.IpcPolicy[T],
) -> T raise @ipc.IpcError {
  if payload_too_large(raw, policy.max_payload_bytes) {
    raise PayloadTooLarge(size=raw.length(), limit=policy.max_payload_bytes)
  }
  let frame = @ipc.parse_request_frame(raw)
  let command : T = frame.decode()
  policy.check(command)
  command
}

///|
fn[T : FromJson, R : ToJson] binding_ipc_response(
  req : String,
  policy : @ipc.IpcPolicy[T],
  handler : async (T) -> R,
) -> String {
  let raw = binding_payload(req) catch { err => return err_response(err) }
  let command = decode_command(raw, policy) catch {
    err => return err_response(err)
  }
  let response = @async_driver.run_response(() => {
    let value = handler(command) catch {
      err => return Err(HandlerError(error_to_string(err)))
    }
    Ok(value)
  })
  @ipc.ResponseFrame(response).stringify()
}

///|
fn[T : FromJson] binding_deferred_request(
  view : @webview.WebView,
  id : String,
  req : String,
  handler : (T, ResponseSender) -> Unit raise DesktopError,
) -> Unit raise DesktopError {
  let sender = ResponseSender(view, id)
  let raw = binding_payload(req) catch {
    err => {
      sender.reject(err)
      return
    }
  }
  let frame = @ipc.parse_request_frame(raw) catch {
    err => {
      sender.reject(err)
      return
    }
  }
  let command : T = frame.decode() catch {
    err => {
      sender.reject(err)
      return
    }
  }
  handler(command, sender) catch {
    err => sender.reject_desktop(err)
  }
}

///|
/// Bind a typed async IPC handler to this window.
pub fn[T : FromJson, R : ToJson] Window::handle_ipc(
  self : Window,
  name : String,
  policy~ : @ipc.IpcPolicy[T],
  handler~ : async (T) -> R,
) -> Unit raise DesktopError {
  self.view.bind(name, (id, req) => {
    let result = binding_ipc_response(req, policy, handler)
    self.view.return_(id, 0, result) catch {
      _ => ()
    }
  }) catch {
    err => raise_webview(err)
  }
}

///|
/// Bind a typed IPC handler that may respond after the binding callback returns.
///
/// This is a low-level escape hatch. Prefer `Window::handle_ipc` for ordinary
/// request/response commands.
pub fn[T : FromJson] Window::handle_deferred(
  self : Window,
  name : String,
  handler : (T, ResponseSender) -> Unit raise DesktopError,
) -> Unit raise DesktopError {
  self.view.bind(name, (id, req) => {
    binding_deferred_request(self.view, id, req, handler) catch {
      _ => ()
    }
  }) catch {
    err => raise_webview(err)
  }
}

///|
pub fn[T : ToJson] Window::emit_event(
  self : Window,
  name : String,
  event : T,
) -> Unit raise DesktopError {
  let raw = @ipc.RequestFrame(event).stringify()
  let target = Json::string(name).stringify()
  let payload = Json::string(raw).stringify()
  self.eval(
    "(function(){ const fn = globalThis[" +
    target +
    "]; if (typeof fn === 'function') fn(" +
    payload +
    "); })()",
  )
}
