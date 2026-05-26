///|
/// A one-request responder that can complete a webview binding call later.
///
/// `ResponseSender` schedules the final `webview_return` on the GUI event-loop
/// thread, so callers do not need to call webview APIs directly from completion
/// paths. A sender is one-shot: the first response wins, and later attempts
/// raise `DesktopError::InvalidState`.
pub struct ResponseSender {
  priv view : @webview.WebView
  priv id : String
  priv mut completed : Bool
}

///|
fn ResponseSender::ResponseSender(
  view : @webview.WebView,
  id : String,
) -> ResponseSender {
  { view, id, completed: false }
}

///|
fn ResponseSender::return_raw(
  self : ResponseSender,
  raw : String,
) -> Unit raise DesktopError {
  if self.completed {
    raise InvalidState("response for request \{self.id} has already been sent")
  }
  self.completed = true
  self.view.dispatch(() => self.view.return_(self.id, 0, raw) catch { _ => () }) catch {
    err => raise_webview(err)
  }
}

///|
/// Resolve this request with a typed successful IPC response.
pub fn[T : ToJson] ResponseSender::resolve(
  self : ResponseSender,
  value : T,
) -> Unit raise DesktopError {
  self.return_raw(ok_response(value))
}

///|
/// Resolve this request with a typed IPC error response.
pub fn ResponseSender::reject(
  self : ResponseSender,
  err : @ipc.IpcError,
) -> Unit raise DesktopError {
  self.return_raw(err_response(err))
}

///|
fn ResponseSender::reject_desktop(
  self : ResponseSender,
  err : DesktopError,
) -> Unit raise DesktopError {
  self.return_raw(desktop_err_response(err))
}
