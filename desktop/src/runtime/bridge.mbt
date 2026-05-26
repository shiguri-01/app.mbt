///|
/// Default JavaScript bridge name used by the desktop runtime and frontend
/// client examples.
pub fn default_bridge_name() -> String {
  @ipc.default_bridge_name()
}

///|
pub fn default_event_name() -> String {
  @ipc.default_event_name()
}

///|
/// Bind an async IPC handler on the default bridge.
pub fn[T : FromJson, R : ToJson] Window::handle_ipc_default(
  self : Window,
  policy~ : @ipc.IpcPolicy[T],
  handler~ : async (T) -> R,
) -> Unit raise DesktopError {
  self.handle_ipc(default_bridge_name(), policy~, handler~)
}

///|
/// Bind a deferred IPC handler on the default bridge.
pub fn[T : FromJson] Window::handle_deferred_default(
  self : Window,
  handler : (T, ResponseSender) -> Unit raise DesktopError,
) -> Unit raise DesktopError {
  self.handle_deferred(default_bridge_name(), handler)
}

///|
pub fn[T : ToJson] Window::emit_event_default(
  self : Window,
  event : T,
) -> Unit raise DesktopError {
  self.emit_event(default_event_name(), event)
}
