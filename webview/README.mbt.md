# shiguri-01/webview

Low-level MoonBit bindings to [webview/webview](https://github.com/webview/webview) through MoonBit native FFI.

Use this module when you need direct access to the native webview lifecycle,
JavaScript binding API, or native window handle.
For application-level desktop apps, prefer `shiguri-01/desktop`,
which builds typed IPC, resources, dialogs, and lifecycle handling on top of this module.

The module provides:

- `WebView::new`, `WebView::run`, `WebView::terminate`, and `WebView::destroy` for lifecycle management.
- `WebView::navigate`, `WebView::set_html`, `WebView::init`, and `WebView::eval` for content and JavaScript execution.
- `WebView::bind`, `WebView::return_`, and `WebView::unbind` for raw JavaScript-to-native calls.
- Window controls such as `set_title`, `set_size`, `show_window`, `hide_window`,
  `focus_window`, `minimize_window`, `maximize_window`, and `restore_window`.
- `WebView::on_window_event` for close, focus, minimize, maximize, and restore events.
- `WebView::native_window` for integrations that need the platform window handle.

Typed JSON protocol helpers are intentionally not part of this module.
Use `shiguri-01/desktop/ipc` for the higher-level request/reply protocol.

## Example

```mbt check
fn main {
  try! @webview.WebView::new(debug=true)
    ..set_title("MoonBit webview")
    ..set_size(800, 600)
    ..set_html("<h1>Hello from MoonBit</h1>")
    ..run()
}
```

Run the example package with:

```bash
moon run src/examples/basic --target native
```

Running the example opens a native GUI window.

## Native Build Notes

The package uses `src` as its MoonBit source directory.
Public MoonBit bindings live in `src/*.mbt`, the MoonBit-to-C++ bridge lives in `src/webview_stub.cc`,
and vendored native headers live in `src/vendor`.

Runnable packages must link the C++ runtime and platform libraries.
On Windows, the bundled package configuration uses `cl` for the C++ stub
and links the WebView2-related platform libraries.

## License and Credits

License: Apache-2.0.

Native credits: `webview/webview` (MIT) and Microsoft WebView2 SDK header (Microsoft license and notices).
Vendored license and notice files are included under `src/vendor`.
