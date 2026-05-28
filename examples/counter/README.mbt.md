# shiguri-01/desktop-counter-example

Runnable minimal application module for `shiguri-01/desktop`.

This example is not a reusable library.
It shows the smallest useful split between a shared protocol package,
a native host package, and a JS-target frontend package.

## What It Demonstrates

- Defining shared `IpcEndpoint[T, R]` values and JSON protocol types.
- Registering typed host handlers with `IpcRouter::handle`.
- Calling host endpoints from JS-target MoonBit code with `Client::request`.
- Loading frontend assets through `resource_text` with a development fallback.
- Keeping simple application state in the native host.

## Module Layout

- `src/shared`: request/reply types and endpoint names used by both sides.
- `src/host`: native window setup, resource loading, and IPC handlers.
- `src/frontend`: minimal DOM UI and frontend IPC calls.

## Implemented Behavior

- Increment the counter.
- Reset the counter.
- Send a title update request through the same typed IPC pattern.

## Run

```powershell
just run-counter-example
```

## License and Credits

License: Apache-2.0.

Native credits: `webview/webview` (MIT), Microsoft WebView2 SDK header (Microsoft license and notices),
Native File Dialog Extended (Zlib).
