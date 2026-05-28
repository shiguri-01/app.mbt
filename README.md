# app.mbt

MoonBit workspace for building desktop applications with a native webview host,
typed IPC, JS-target frontend code, and packaged frontend assets.

The main module is `shiguri-01/desktop`.
It provides the runtime, IPC protocol helpers, frontend client, native dialogs,
and Rabbita integration used by the examples in this repository.

## Modules

Library and tool modules:

- `shiguri-01/desktop`: desktop application framework.
- `shiguri-01/webview`: low-level native webview bindings.
- `shiguri-01/desktop-packager`: native packaging command for desktop apps.

Runnable example modules:

- `desktop-counter-example`: minimal typed IPC.
- `desktop-dialog-example`: native message dialogs.
- `desktop-file-dialog-example`: native file and folder dialogs.
- `desktop-http-workbench-example`: async HTTP from the native host.
- `desktop-markdown-notes-example`: Markdown editor with local files,
  lifecycle hooks, and frontend state.

Each directory with a `moon.mod` is a separate MoonBit module.
Module README files are written as the public documentation entry points for those modules.

## `shiguri-01/desktop` Packages

- `shiguri-01/desktop/ipc`: endpoint descriptors, JSON frames, responses, and IPC errors.
- `shiguri-01/desktop/runtime`: native app lifecycle, windows, resources, async IPC handlers, and dialogs.
- `shiguri-01/desktop/frontend`: JS-target frontend IPC client.
- `shiguri-01/desktop/frontend/rabbita`: Rabbita `Cmd` adapter for frontend IPC calls.
- `shiguri-01/desktop/shell`: low-level native shell dialog integrations.

Most application code uses three packages: a shared protocol package that imports `ipc`,
a native host package that imports `runtime`, and a JS-target frontend package that imports `frontend`.

## License and Credits

License: Apache-2.0.

Native credits: `webview/webview` (MIT), Microsoft WebView2 SDK header
(Microsoft license and notices), Native File Dialog Extended (Zlib).
Vendored license and notice files are included next to the native sources.
