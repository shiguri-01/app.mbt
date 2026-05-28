# shiguri-01/desktop-markdown-notes-example

Runnable Markdown editor example for `shiguri-01/desktop`.

This example is not a reusable library.
It demonstrates a document-style desktop app with native file dialogs, local state persistence,
lifecycle hooks, Markdown rendering, and a Luna frontend.

## What It Demonstrates

- Typed document commands with `IpcEndpoint[T, R]` and `IpcRouter::handle`.
- Native open/save workflows with `Window::open_file_dialog` and `Window::save_file_dialog`.
- Dirty-document close handling through `WindowLifecycle::before_close`.
- Frontend asset loading through `resource_text` with a development fallback.
- Luna UI, `mizchi/markdown`, and browser bindings in the JS frontend.

## Module Layout

- `src/contract`: shared IPC protocol and startup state types.
- `src/core`: pure document and recent-file helpers with focused tests.
- `src/host`: native resource loading, file IO, dialogs, and lifecycle hooks.
- `src/frontend`: Luna UI, editor shell, sidebar, and preview workspace.

## Implemented Behavior

- Open Markdown files.
- Save and save-as Markdown files.
- Restore recent files and the last opened file on startup.
- Track dirty state and prevent accidental close when needed.
- Edit Markdown while rendering a preview.

## Run

Install frontend dependencies once:

```sh
npm --prefix examples/markdown-notes install
```

Then run the desktop app.
The `just` task builds the frontend before starting the native host:

```sh
just run-markdown-notes-example
```

## License and Credits

License: Apache-2.0.

Native credits: `webview/webview` (MIT), Microsoft WebView2 SDK header (Microsoft license and notices),
Native File Dialog Extended (Zlib).
External MoonBit packages: Luna, Markdown, browser bindings, signals, async.
