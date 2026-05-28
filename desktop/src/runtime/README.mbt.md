# desktop/runtime

Native desktop application runtime backed by `shiguri-01/webview`.

This package owns the application event loop, host windows, content loading,
typed async IPC handler registration, native dialogs, and window lifecycle
callbacks.

Applications normally create windows from `App::create_window`, register shared
`IpcEndpoint[T, R]` values on an `IpcRouter`, and mount the router on a window.

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
  let router = @desktop.IpcRouter()
    .handle(@shared.increment_endpoint, handler=request => {
      @async.sleep(1)
      handle_increment(request)
    })
  window.mount_ipc(router)
})
```

The runtime decodes `RequestFrame.payload` as the application command type,
runs the async handler, and returns a `ResponseFrame[R]` to the webview binding
promise. Handler errors are mapped to `IpcError::HandlerError`; decode failures
are returned as `IpcResponse::Err`.

`Window::emit` sends a typed host-to-frontend event through a shared
`IpcEvent[E]`.

Window lifecycle, restoration, content loading, message dialogs, and file
dialogs are unchanged from the higher-level `desktop` package overview.

## Content loading

`Load::Html` embeds an HTML string directly. `Load::Url` navigates the webview
to a URL. The runtime does not depend on any frontend bundler; applications can
load frontend output from a dev server, generated HTML, or bundled assets.

Packaged applications can read assets through `resource_text` or
`resource_bytes`. Embedded single-exe resources are checked first, then the
runtime falls back to `resources` next to the executable:

```mbt nocheck
///|
let html = @desktop.resource_text("index.html")
```
