# desktop/runtime

Native desktop application runtime backed by `shiguri-01/webview`.

This package owns the application event loop, host windows, content loading,
host-side IPC handler registration, and window lifecycle callbacks.
Applications normally create windows from `App::create_window` and use
`Window::handle` to register typed async IPC handlers.

```mbt nocheck
@desktop.run(on_startup=app => {
  let window = app.create_window(
    WindowOptions(
      key="main",
      title="MoonBit Counter",
      width=640,
      height=420,
      load=Html(html),
    ),
  )
    window.handle("moonbitDesktop", command => {
      @async.sleep(1)
      handle_command(command)
    })
})
```

## Application lifecycle

`App` is the event-loop owner. Single-window and multi-window applications use
the same startup shape:

```mbt nocheck
@desktop.run(on_startup=app => {
  let main = app.create_window(WindowOptions(key="main", title="Main"))
  let tools = app.create_window(WindowOptions(key="tools", title="Tools"))
  main.focus()
  tools.minimize()
})
```

Each window receives a runtime-only `WindowId`. Use `WindowOptions.key` and
`WindowSnapshot.key` for persistent restoration.

`WindowLifecycle::before_close` handles user close requests and programmatic
`Window::request_close` calls. Return `Prevent` to keep the window open, or
`Allow` to close it:

```mbt nocheck
///|
let lifecycle = WindowLifecycle(before_close=(window, reason) => {
  let answer = window.show_message_dialog(
    "Close this window?",
    title="Confirm",
    kind=Question,
    buttons=YesNo,
  )
  if answer is Yes {
    Allow
  } else {
    Prevent
  }
})

///|
let window = app.create_window(
  WindowOptions(key="main", title="Main"),
  lifecycle,
)
```

For startup restore, provide a `WindowStateStore` and call
`App::restore_windows` from startup. The runtime saves snapshots when windows
close and after the event loop exits:

```mbt nocheck
let store = WindowStateStore(
  load_windows=() => load_snapshots(),
  save_windows=snapshots => save_snapshots(snapshots),
)
@desktop.run(options=AppOptions(state_store=store), on_startup=app => {
  ignore(app.restore_windows())
})
```

## IPC handlers

`Window::handle` accepts an async typed handler:

```mbt nocheck
pub fn[T : FromJson, R : ToJson] Window::handle(
  self : Window,
  name : String,
  handler : async (T) -> R,
) -> Unit raise DesktopError
```

The runtime decodes the frontend envelope payload as `T`, runs the handler
through a runtime-owned async driver, and returns `Response[R]` to the webview
binding promise.

`Window::handle_sync` is still available for low-level callbacks that must not
enter the async driver:

```mbt nocheck
window.handle_sync("moonbitDesktop", command => handle_command(command))
```

`Window::handle_deferred` is the non-blocking integration point for work that
finishes outside the webview binding callback. The handler receives a
`ResponseSender`, returns quickly, and completes the JavaScript promise later
with `sender.resolve(...)` or `sender.reject(...)`:

```mbt nocheck
window.handle_deferred("moonbitDesktop", (command, sender) => {
  enqueue_work(command, result => sender.resolve(result))
})
```

The sender schedules the final `webview_return` through `WebView::dispatch`,
so completion paths can return to the GUI event-loop thread before touching the
native webview API. A sender is one-shot; a second `resolve` or `reject` raises
`DesktopError::InvalidState`.

## Async driver boundary

The current async driver runs each IPC handler to completion before returning
from the webview callback. This means MoonBit async APIs such as timers and
async file operations are usable from handlers, but long handlers still occupy
the UI callback path.

That compromise is isolated behind `runtime/async_driver`. Application code
should choose `Window::handle` for short async handlers and
`Window::handle_deferred` for work that should complete later.

## Content loading

`Load::Html` embeds an HTML string directly. `Load::Url` navigates the webview
to a URL. The runtime does not depend on any frontend bundler; applications can
load frontend output from a dev server, generated HTML, or bundled assets.

## Native dialogs

`Window::show_message_dialog` shows a native modal message dialog owned by the
current window:

```mbt nocheck
window.show_message_dialog(
  "The export has finished.",
  title="Export",
  kind=Info,
  buttons=Ok,
)
```

The dialog API exposes portable enum values for kind, button set, and result.
Platform handles, Win32 flags, and OS-specific result codes stay inside
`desktop/shell`.

`Window::open_file_dialog`, `Window::open_files_dialog`,
`Window::save_file_dialog`, and `Window::open_folder_dialog` show native file
dialogs owned by the current window. They return `None` when the user cancels:

```mbt nocheck
///|
let path = window.open_file_dialog(filters=[
  { name: "Images", extensions: ["png", "jpg", "jpeg"] },
])

///|
let folder = window.open_folder_dialog()
```
