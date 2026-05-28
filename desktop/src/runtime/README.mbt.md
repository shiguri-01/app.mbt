# shiguri-01/desktop/runtime

Native host runtime for `shiguri-01/desktop` applications.

Use this package from a native host package.
It owns the application event loop, webview windows, resource lookup, typed async IPC handler registration,
native dialogs, window lifecycle callbacks, and optional window restoration.

## Host Flow

1. Start the runtime with `run`.
2. Create one or more windows with `App::create_window`.
3. Register shared endpoints on an `IpcRouter`.
4. Mount the router on a `Window`.
5. Load HTML from a string, URL, development file, or packaged resource.

```mbt check
///|
/// Pass this value to `App::create_window` from the runtime startup callback.
pub fn main_window_options() -> @runtime.WindowOptions {
  @runtime.WindowOptions(
    key="main",
    title="MoonBit Desktop",
    width=800,
    height=600,
    load=@runtime.Load::Html("<h1>Hello</h1>"),
  )
}
```

## Main APIs

- `run` and `App::run` own the native event loop.
- `App::create_window`, `App::windows`, `App::window`, `App::request_quit`, and `App::quit` manage application state.
- `WindowOptions`, `Load`, `Window`, and `WindowId` describe and control native windows.
- `IpcRouter::handle` maps `IpcEndpoint[T, R]` values to async host handlers.
- `Window::emit` sends typed host-to-frontend events.
- `resource_text`, `resource_bytes`, `resource_path`, and `resource_dir` load development or packaged resources.
- `Window::show_message_dialog`, `Window::open_file_dialog`, `Window::open_files_dialog`,
  `Window::save_file_dialog`, and `Window::open_folder_dialog` expose native dialogs.
- `AppLifecycle` and `WindowLifecycle` provide quit, ready, focus, close, and window-state hooks.

## Resources

Packaged applications can load resources by logical path.
Embedded single-exe resources are checked first;
if none are present, the runtime falls back to a `resources` directory next to the executable.
This lets the same host code run from a development checkout and from a packaged bundle.

## Lifecycle Notes

`WindowId` values are runtime-only identifiers.
Use stable `WindowOptions.key` values if a window should be restored across launches.
A `before_close` lifecycle hook can return `Prevent` to keep a dirty document window open.

IPC handlers are async and run to completion through the runtime async driver.
Decode failures become IPC errors before the handler runs; raised handler errors become `IpcError::HandlerError`.
