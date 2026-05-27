# app.mbt

MoonBit workspace for building small desktop applications with a native webview
host and typed IPC between host and frontend code.

## Workspace

This repository is a `moon.work` workspace with six members:

- `desktop`: higher-level desktop app framework.
- `webview`: native FFI bindings to `webview/webview`.
- `packager`: native packager for desktop application bundles.
- `examples/counter`: sample app that uses `desktop` as an external package.
- `examples/dialogs`: native message dialog sample app.
- `examples/file-dialogs`: native file dialog sample app.

`desktop` is split into focused packages:

- `desktop/src/ipc`: target-agnostic endpoints, frames, responses, and errors.
- `desktop/src/runtime`: app lifecycle, native windows, and IPC handlers.
- `desktop/src/frontend`: JS-target client helpers for frontend code.

## Status

The project can build prototype desktop apps today. The runtime is centered on
an `App` owner that manages the native event loop, one or more windows, window
ids, close/focus/minimize/maximize operations, lifecycle callbacks, and optional
startup window restoration. It also supports typed async request/response IPC,
payload size limits, and host-to-frontend events.

Async IPC handlers currently run inside the webview callback path. Define
shared `IpcEndpoint[T, R]` values, register them on an `IpcRouter`, and mount
the router on a window.

## Common Commands

```powershell
just check
just test
just run-counter-example
just package-counter-example
just run-dialogs-example
just run-file-dialogs-example
```

On Windows, native commands require a Visual Studio C++ environment. The `just`
tasks call `tools/msvc-native.cmd` for commands that need MSVC.

## Documentation

- `desktop/README.mbt.md`: desktop framework overview.
- `desktop/src/ipc/README.mbt.md`: IPC frames, policies, responses, errors.
- `desktop/src/runtime/README.mbt.md`: runtime window and host handlers.
- `desktop/src/frontend/README.mbt.md`: JS frontend client helpers.
- `webview/README.mbt.md`: low-level webview bindings.
- `packager/README.mbt.md`: desktop application packaging.

## Third-Party Native Code

This workspace includes a small amount of third-party C/C++ code for native
desktop integration:

- `webview/src/vendor/webview.h` is generated from
  [`webview/webview`](https://github.com/webview/webview) and is distributed
  under the MIT License. See `webview/src/vendor/webview.LICENSE.txt`.
- `webview/src/vendor/WebView2.h` comes from the Microsoft WebView2 SDK and is
  distributed under Microsoft's WebView2 license and notices. See
  `webview/src/vendor/WebView2.LICENSE.txt` and
  `webview/src/vendor/WebView2.NOTICE.txt`.
- `desktop/src/shell/nfd.h` and `desktop/src/shell/nfd_win.cpp` come from
  [Native File Dialog Extended](https://github.com/btzy/nativefiledialog-extended)
  and are distributed under the Zlib License. See
  `desktop/src/shell/NFD_LICENSE.txt`.
