# desktop

Typed MoonBit desktop application framework.

The framework keeps the native host, frontend helper, and shared IPC protocol
as separate packages:

- `ipc`: target-agnostic JSON envelopes for typed commands and events.
- `runtime`: native host runtime backed by `shiguri-01/webview`.
- `frontend`: JS-target helper package that does not depend on a UI library.

Applications define their own nested enum protocol and derive `ToJson` /
`FromJson` for it.

The default bridge name is `moonbitDesktop`. Native code can use
`Window::handle_default`, `Window::handle_sync_default`, or
`Window::handle_deferred_default`; frontend code can use
`Client::request_with_callback_default` or `Client::request_async_default`.
Use the explicit-name variants when an app needs multiple bridges.

For long-running host work, prefer `Window::handle_deferred`. It decodes the
request in the webview callback, passes a `ResponseSender` to the handler, and
lets the handler complete the JavaScript promise later with `resolve` or
`reject`.

Package-level README files contain the API-oriented details:

- `src/ipc/README.mbt.md`: typed envelopes, requests, responses, and errors.
- `src/runtime/README.mbt.md`: native window runtime and async host handlers.
- `src/runtime/async_driver/README.mbt.md`: native async driver boundary.
- `src/shell/README.mbt.md`: native shell helpers such as message and file
  dialogs.
- `src/frontend/README.mbt.md`: JS-target client helpers for frontend code.

## Async IPC direction

The runtime uses async host handlers today. `Window::handle` runs each handler
to completion inside a runtime-owned async driver, so MoonBit async APIs are
usable but long handlers still occupy the webview callback path.

For work that must complete after the callback returns, use
`Window::handle_deferred` and `ResponseSender`. Lower-level async driver
details are kept in `src/runtime/async_driver`.

On Windows, native builds use the bundled webview C++ stub. Run native
test/build/run commands from a Visual Studio C++ environment or through the
repository `just` tasks, which call `vcvarsall.bat x64`.
