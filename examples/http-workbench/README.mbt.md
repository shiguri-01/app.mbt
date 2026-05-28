# shiguri-01/desktop-http-workbench-example

Runnable desktop HTTP client example for `shiguri-01/desktop`.

This example is not a reusable library.
It shows a larger application shape with typed async host commands, native HTTP requests,
persisted JSON state, and a Rabbita frontend.

## What It Demonstrates

- Typed async host commands with `IpcEndpoint[T, R]` and `IpcRouter::handle`.
- Native HTTP requests through `moonbitlang/async/http`.
- Shared protocol types that derive `ToJson` and `FromJson` for IPC and persistence.
- Frontend command integration through `frontend/rabbita.request_cmd`.
- Loading packaged frontend assets with `resource_text` and a development fallback.

## Module Layout

- `src/contract`: shared IPC protocol and persisted state types.
- `src/core`: pure request and state operations with focused tests.
- `src/host`: native resource loading, state file IO, and HTTP execution.
- `src/frontend`: Rabbita UI, commands, and update logic.

## Implemented Behavior

- Save HTTP request drafts with editable method, URL, headers, and body.
- Execute HTTP requests in the native host.
- Report response status, headers, body, timing, and errors.
- Persist saved requests, recent history, and the active draft as JSON.

## Run

Install frontend dependencies once:

```sh
npm --prefix examples/http-workbench install
```

Then run the desktop app.
The `just` task builds the frontend before starting the native host:

```sh
just run-http-workbench-example
```

## License and Credits

License: Apache-2.0.

Native credits: `webview/webview` (MIT), Microsoft WebView2 SDK header (Microsoft license and notices),
Native File Dialog Extended (Zlib).
External MoonBit packages: Rabbita, `moonbitlang/async`.
