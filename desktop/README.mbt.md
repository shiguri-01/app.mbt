# desktop

Typed MoonBit desktop application framework.

The framework keeps the native host, frontend helper, and shared IPC protocol
as separate packages:

- `ipc`: target-agnostic JSON frames, responses, and command policies.
- `runtime`: native host runtime backed by `shiguri-01/webview`.
- `frontend`: JS-target helper package that does not depend on a UI library.

Applications define their own nested enum protocol and derive `ToJson` /
`FromJson` for it.

Native applications start with `@desktop.run`, receive an `App`, and create one
or more windows with `App::create_window`. Native code should use
`Window::handle_ipc_default` with an `IpcPolicy`; frontend code can use
`Client::request_async_default` or the callback helper.

For long-running host work that must finish after the callback returns,
`Window::handle_deferred` remains available as a lower-level escape hatch.

`WindowId` values are runtime-only. Use `WindowOptions.key` and
`WindowSnapshot.key` for persistent startup restoration.

Package-level README files contain the API-oriented details:

- `src/ipc/README.mbt.md`: typed frames, policies, responses, and errors.
- `src/runtime/README.mbt.md`: native window runtime and async host handlers.
- `src/runtime/async_driver/README.mbt.md`: native async driver boundary.
- `src/shell/README.mbt.md`: native shell helpers such as message and file
  dialogs.
- `src/frontend/README.mbt.md`: JS-target client helpers for frontend code.

## Async IPC direction

The runtime uses async host handlers today. `Window::handle_ipc` runs each
handler to completion inside a runtime-owned async driver, so MoonBit async APIs
are usable but long handlers still occupy the webview callback path.

For work that must complete after the callback returns, use
`Window::handle_deferred` and `ResponseSender`. Lower-level async driver
details are kept in `src/runtime/async_driver`.

On Windows, native builds use the bundled webview C++ stub. Run native
test/build/run commands from a Visual Studio C++ environment or through the
repository `just` tasks, which call `vcvarsall.bat x64`.
