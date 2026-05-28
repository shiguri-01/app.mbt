///|
/// Collection of IPC endpoint bindings that can be mounted on a window.
pub struct IpcRouter {
  priv routes : Array[(Window) -> Unit raise DesktopError]
}

///|
/// Create an empty IPC router.
pub fn IpcRouter::IpcRouter() -> IpcRouter {
  { routes: [] }
}

///|
/// Add a typed async handler for an IPC endpoint.
pub fn[T : FromJson, R : ToJson] IpcRouter::handle(
  self : IpcRouter,
  endpoint : @ipc.IpcEndpoint[T, R],
  max_payload_bytes? : Int = 65536,
  handler~ : async (T) -> R,
) -> IpcRouter {
  self.routes.push(window => {
    window.bind_ipc_endpoint(endpoint, max_payload_bytes~, handler~)
  })
  self
}

///|
/// Install all routes from an IPC router on this window.
pub fn Window::mount_ipc(
  self : Window,
  router : IpcRouter,
) -> Unit raise DesktopError {
  for route in router.routes {
    route(self)
  }
}
