# shiguri-01/webview

Low-level MoonBit bindings to [webview/webview](https://github.com/webview/webview) through MoonBit native FFI.

Use this module when you need direct access to a native webview window,
JavaScript execution, JavaScript-to-native calls, window events, or the native
window handle.

The module provides:

- Webview lifecycle management.
- HTML and URL loading.
- JavaScript initialization and evaluation.
- JavaScript-to-native bindings.
- Native window controls and window events.
- Access to the platform-native window handle.

## Example

```mbt check
fn main {
  try! @webview.WebView(debug=true)
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

## Native Build Notes

Runnable packages must link the C++ runtime and platform libraries.
On Windows, the bundled package configuration uses `cl` for the C++ stub
and links the WebView2-related platform libraries.

## License and Credits

License: Apache-2.0.

Native credits: `webview/webview` (MIT) and Microsoft WebView2 SDK header (Microsoft license and notices).
Vendored license and notice files are included under `src/vendor`.
