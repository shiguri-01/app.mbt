# desktop/frontend

JS-target helpers for calling a desktop runtime bridge from frontend code.

`Client` builds typed `RequestFrame` values and sends them through a JavaScript
bridge function such as `globalThis.moonbitDesktop`. It is UI-library agnostic;
DOM, Rabbita, Luna, or another layer can decide when to call it.

Use `request_async_default` for async frontend code. `request_with_callback`
exists for callback-driven UI code.

```mbt nocheck
///|
let client = @frontend.Client()

///|
let response : @ipc.IpcResponse[AppReply] = client.request_async_default(
  command,
)
```

Host-to-frontend events use `listen_default`, which installs a typed listener
on `globalThis.moonbitDesktopEvent`.
