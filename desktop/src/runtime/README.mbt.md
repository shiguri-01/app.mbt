# desktop/runtime

Native desktop application runtime backed by `shiguri-01/webview`.

This package owns the application event loop, host windows, content loading,
typed async IPC handler registration, native dialogs, and window lifecycle
callbacks.

Applications normally create windows from `App::create_window` and use a shared
`IpcEndpoint[T, R]` with `Window::handle_ipc_endpoint` to register an async
command handler.

```mbt nocheck
@desktop.run(on_startup=app => {
  let window = app.create_window(
    WindowOptions(
      key="main",
      title="MoonBit Counter",
      width=640,
      height=420,
      load=Html(html),
    ),
  )
  window.handle_ipc_endpoint(@shared.increment_endpoint, handler=request => {
    @async.sleep(1)
    handle_increment(request)
  })
})
```

The runtime decodes `RequestFrame.payload` as the application command type,
runs the async handler, and returns a `ResponseFrame[R]` to the webview binding
promise. Handler errors are mapped to `IpcError::HandlerError`; decode failures
are returned as `IpcResponse::Err`.

`Window::emit_event_endpoint` sends a typed host-to-frontend event through a
shared `IpcEvent[E]`. `Window::handle_deferred` and `ResponseSender` remain
available for work that must complete after the webview binding callback has
returned.

Window lifecycle, restoration, content loading, message dialogs, and file
dialogs are unchanged from the higher-level `desktop` package overview.
