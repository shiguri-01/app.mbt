///|
fn binding_payload(req : String) -> String raise @ipc.IpcError {
  let json = @json.parse(req) catch {
    err => raise @ipc.IpcError::DecodeError(err.to_string())
  }
  match json {
    Array(args) =>
      match args.get(0) {
        Some(String(raw)) => raw
        Some(_) =>
          raise @ipc.IpcError::DecodeError(
            "desktop bridge first argument must be a string",
          )
        None =>
          raise @ipc.IpcError::DecodeError(
            "desktop bridge call must include one argument",
          )
      }
    _ =>
      raise @ipc.IpcError::DecodeError(
        "desktop bridge request must be a JSON array",
      )
  }
}

///|
fn[T : ToJson] ok_response(value : T) -> String {
  let response : @ipc.Response[T] = Ok(value)
  response.to_json().stringify()
}

///|
fn err_response(err : @ipc.IpcError) -> String {
  let response : @ipc.Response[Json] = Err(err)
  response.to_json().stringify()
}

///|
fn desktop_err_response(err : DesktopError) -> String {
  err_response(@ipc.IpcError::HandlerError(desktop_error_to_string(err)))
}

///|
fn[T : FromJson, R : ToJson] binding_response(
  req : String,
  handler : (T) -> R raise DesktopError,
) -> String {
  let raw = binding_payload(req) catch { err => return err_response(err) }
  let envelope = @ipc.parse_envelope(raw) catch {
    err => return err_response(err)
  }
  let command : T = envelope.decode() catch { err => return err_response(err) }
  let value = handler(command) catch { err => return desktop_err_response(err) }
  ok_response(value)
}

///|
fn[T : FromJson, R : ToJson] binding_async_response(
  req : String,
  handler : async (T) -> R,
) -> String {
  let raw = binding_payload(req) catch { err => return err_response(err) }
  let envelope = @ipc.parse_envelope(raw) catch {
    err => return err_response(err)
  }
  let command : T = envelope.decode() catch { err => return err_response(err) }
  let response = run_async_response(() => {
    let value = handler(command) catch {
      err => return Err(@ipc.IpcError::HandlerError(error_to_string(err)))
    }
    Ok(value)
  })
  response.to_json().stringify()
}

///|
fn[T : FromJson] binding_deferred_request(
  view : @webview.WebView,
  id : String,
  req : String,
  handler : (T, ResponseSender) -> Unit raise DesktopError,
) -> Unit raise DesktopError {
  let sender = ResponseSender::new(view, id)
  let raw = binding_payload(req) catch {
    err => {
      sender.reject(err)
      return
    }
  }
  let envelope = @ipc.parse_envelope(raw) catch {
    err => {
      sender.reject(err)
      return
    }
  }
  let command : T = envelope.decode() catch {
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
///
/// The async handler runs to completion inside a runtime-owned async driver.
/// This keeps async internals behind the desktop runtime while still exposing
/// async application handlers.
pub fn[T : FromJson, R : ToJson] Window::handle(
  self : Window,
  name : String,
  handler : async (T) -> R,
) -> Unit raise DesktopError {
  self.view.bind(name, (id, req) => {
    let result = binding_async_response(req, handler)
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
/// The handler receives a `ResponseSender`. It should arrange work and return
/// quickly, then call `sender.resolve(...)` or `sender.reject(...)` when the
/// result is ready.
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
/// Bind a typed synchronous IPC handler to this window.
///
/// JavaScript calls the binding with one argument: an `Envelope` JSON string.
/// The webview binding promise resolves with a serialized `Response[R]`.
pub fn[T : FromJson, R : ToJson] Window::handle_sync(
  self : Window,
  name : String,
  handler : (T) -> R raise DesktopError,
) -> Unit raise DesktopError {
  self.view.bind(name, (id, req) => {
    let result = binding_response(req, handler)
    self.view.return_(id, 0, result) catch {
      _ => ()
    }
  }) catch {
    err => raise_webview(err)
  }
}
