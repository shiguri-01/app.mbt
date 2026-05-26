///|
/// Default JavaScript bridge name used by the desktop runtime and frontend
/// client examples.
pub fn default_bridge_name() -> String {
  @ipc.default_bridge_name()
}

///|
/// Bind an async IPC handler on the default bridge.
pub fn[T : FromJson, R : ToJson] Window::handle_default(
  self : Window,
  handler : async (T) -> R,
) -> Unit raise DesktopError {
  self.handle(default_bridge_name(), handler)
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
/// Bind a synchronous IPC handler on the default bridge.
pub fn[T : FromJson, R : ToJson] Window::handle_sync_default(
  self : Window,
  handler : (T) -> R raise DesktopError,
) -> Unit raise DesktopError {
  self.handle_sync(default_bridge_name(), handler)
}
