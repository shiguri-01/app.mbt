# shiguri-01/desktop

Typed MoonBit framework for desktop applications with a native webview host and MoonBit frontend code.

Use this module when you want a MoonBit native process to own windows, resources, native dialogs, and host-side logic,
while a JS-target MoonBit frontend calls the host through typed request/reply IPC.

## Packages

- `runtime`: native application runtime. Use it from host packages that create windows,
  mount IPC handlers, read packaged resources, and show native dialogs.
- `frontend`: JS-target IPC client. Use it from frontend packages that call host endpoints or listen for host events.
- `ipc`: target-agnostic protocol primitives. Use it from a shared package
  that defines endpoint values and JSON-serializable request and reply types.
- `shell`: low-level native shell integrations used by the runtime.
  Most application code should call the `Window` methods from `runtime` instead.
- `frontend/rabbita`: Rabbita command adapter for frontend endpoint calls.

## Application Shape

A typical application has three packages:

- A shared protocol package that imports `shiguri-01/desktop/ipc`, defines `IpcEndpoint[T, R]` values,
  and derives or implements `ToJson` and `FromJson` for protocol types.
- A native host package that imports `shiguri-01/desktop/runtime`, starts `@desktop.run`,
  creates windows, and registers `IpcRouter` handlers.
- A JS-target frontend package that imports `shiguri-01/desktop/frontend`
  and calls the same endpoint values with `Client::request` or `Client::request_callback`.

```mbt check
///|
struct IncrementRequest {
  amount : Int
} derive(ToJson, FromJson)

///|
struct CountChangedReply {
  count : Int
} derive(ToJson, FromJson)

///|
/// Host code registers this endpoint with `IpcRouter::handle`.
/// Frontend code calls the same endpoint with `Client::request`.
pub let increment_endpoint : @ipc.IpcEndpoint[
  IncrementRequest,
  CountChangedReply,
] = @ipc.IpcEndpoint::named("counter.increment")
```

## Runtime Model

The native runtime owns the event loop and all `Window` values.
`WindowId` values are runtime identifiers;
use stable `WindowOptions.key` and `WindowSnapshot.key` values if an application needs startup restoration.

IPC handlers are async and run through a runtime-owned driver.
They can call MoonBit async APIs, but long handlers still occupy the webview callback path until they complete.

## Native Builds

Native host packages require a platform C/C++ toolchain for the webview and dialog stubs.
On Windows, use a Visual Studio C++ environment for native check, test, run, and package commands.

## Examples

The workspace includes runnable example modules for the main workflows:

- `desktop-counter-example`: minimal typed IPC.
- `desktop-dialog-example`: native message dialogs.
- `desktop-file-dialog-example`: native file and folder dialogs.
- `desktop-http-workbench-example`: async HTTP from the native host.
- `desktop-markdown-notes-example`: local file editing, lifecycle hooks, and frontend state.

## License and Credits

License: Apache-2.0.

Native credits: `webview/webview` (MIT), Microsoft WebView2 SDK header (Microsoft license and notices),
Native File Dialog Extended (Zlib).
Vendored license and notice files are included next to the native sources.
