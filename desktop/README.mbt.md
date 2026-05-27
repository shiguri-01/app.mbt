# desktop

Typed MoonBit desktop application framework.

The framework keeps the native host, frontend helper, and shared IPC protocol
as separate packages:

- `ipc`: target-agnostic JSON frames, responses, and command policies.
- `runtime`: native host runtime backed by `shiguri-01/webview`.
- `frontend`: JS-target helper package that does not depend on a UI library.

Applications define shared endpoint values and request/reply protocol types,
then derive or implement `ToJson` / `FromJson` for those types.

Native applications start with `@desktop.run`, receive an `App`, and create one
or more windows with `App::create_window`. Native code should use
`IpcRouter::handle` with shared command endpoints such as
`IpcEndpoint[IncrementRequest, CountChangedReply]`, then mount the router with
`Window::mount_ipc`. Frontend code uses `Client::request`.

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

The runtime uses async host handlers today. `IpcRouter::handle` runs each
handler to completion inside a runtime-owned async driver, so MoonBit async APIs
are usable but long handlers still occupy the webview callback path.

On Windows, native builds use the bundled webview C++ stub. Run native
test/build/run commands from a Visual Studio C++ environment or through the
repository `just` tasks, which call `vcvarsall.bat x64`.

## Third-Party Credits

The native desktop implementation uses third-party C/C++ code:

- Window hosting is backed by the `shiguri-01/webview` module. That module
  vendors [`webview/webview`](https://github.com/webview/webview) under the MIT
  License and the Microsoft WebView2 SDK header under Microsoft's WebView2
  license and notices.
- Windows file dialogs in `src/shell` vendor
  [Native File Dialog Extended](https://github.com/btzy/nativefiledialog-extended)
  under the Zlib License. See `src/shell/NFD_LICENSE.txt` and
  `src/shell/README.mbt.md`.
