///|
pub struct IpcRouter {
  priv routes : Array[(Window) -> Unit raise DesktopError]
}

///|
pub fn IpcRouter::IpcRouter() -> IpcRouter {
  { routes: [] }
}

///|
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
pub fn Window::mount_ipc(
  self : Window,
  router : IpcRouter,
) -> Unit raise DesktopError {
  for route in router.routes {
    route(self)
  }
}
