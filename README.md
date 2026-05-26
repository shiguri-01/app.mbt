# app.mbt

MoonBit workspace for building small desktop applications with a native webview
host and typed IPC between host and frontend code.

## Workspace

This repository is a `moon.work` workspace with five members:

- `desktop`: higher-level desktop app framework.
- `webview`: native FFI bindings to `webview/webview`.
- `examples/counter`: sample app that uses `desktop` as an external package.
- `examples/dialogs`: native message dialog sample app.
- `examples/file-dialogs`: native file dialog sample app.

`desktop` is split into focused packages:

- `desktop/src/ipc`: target-agnostic frames, responses, and IPC policies.
- `desktop/src/runtime`: app lifecycle, native windows, and IPC handlers.
- `desktop/src/frontend`: JS-target client helpers for frontend code.

## Status

The project can build prototype desktop apps today. The runtime is centered on
an `App` owner that manages the native event loop, one or more windows, window
ids, close/focus/minimize/maximize operations, lifecycle callbacks, and optional
startup window restoration. It also supports typed async request/response IPC,
command allowlists, payload size limits, host-to-frontend events, and deferred
responses through `ResponseSender`.

Async IPC handlers currently run inside the webview callback path. Use
`Window::handle_ipc_default` for ordinary typed commands and
`Window::handle_deferred` only for host work that must complete later without
blocking that callback.

## Common Commands

```powershell
just check
just test
just run-counter-example
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
