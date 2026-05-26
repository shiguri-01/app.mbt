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

- `desktop/src/ipc`: target-agnostic typed envelopes and responses.
- `desktop/src/runtime`: native host window and IPC handler registration.
- `desktop/src/frontend`: JS-target client helpers for frontend code.

## Status

The project can build prototype desktop apps today. It supports typed request
and response IPC, one-way frontend events, synchronous handlers, async handlers,
and deferred responses through `ResponseSender`.

The main remaining design constraint is async integration. Current async
handlers run inside the webview callback path; `Window::handle_deferred` is the
recommended API for host work that should complete later without blocking that
callback.

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
- `desktop/src/ipc/README.mbt.md`: IPC envelopes, requests, responses, errors.
- `desktop/src/runtime/README.mbt.md`: runtime window and host handlers.
- `desktop/src/frontend/README.mbt.md`: JS frontend client helpers.
- `webview/README.mbt.md`: low-level webview bindings.
