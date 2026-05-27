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
fn[T : FromJson] decode_endpoint_command(
  raw : String,
  max_payload_bytes : Int,
) -> T raise @ipc.IpcError {
  if payload_too_large(raw, max_payload_bytes) {
    raise PayloadTooLarge(size=raw.length(), limit=max_payload_bytes)
  }
  let frame = @ipc.parse_request_frame(raw)
  frame.decode()
}

///|
fn[T : FromJson, R : ToJson] binding_endpoint_response(
  req : String,
  max_payload_bytes : Int,
  handler : async (T) -> R,
) -> String {
  let raw = binding_payload(req) catch { err => return err_response(err) }
  let command : T = decode_endpoint_command(raw, max_payload_bytes) catch {
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
fn[T : FromJson, R : ToJson] Window::bind_ipc_endpoint(
  self : Window,
  endpoint : @ipc.IpcEndpoint[T, R],
  max_payload_bytes? : Int = 65536,
  handler~ : async (T) -> R,
) -> Unit raise DesktopError {
  self.view.bind(endpoint.name(), (id, req) => {
    let result = binding_endpoint_response(req, max_payload_bytes, handler)
    self.view.return_(id, 0, result) catch {
      _ => ()
    }
  }) catch {
    err => raise_webview(err)
  }
}

///|
fn[T : ToJson] Window::emit_raw(
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

///|
pub fn[T : ToJson] Window::emit(
  self : Window,
  endpoint : @ipc.IpcEvent[T],
  event : T,
) -> Unit raise DesktopError {
  self.emit_raw(endpoint.name(), event)
}
