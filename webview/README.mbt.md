# shiguri-01/webview

MoonBit bindings for [webview/webview](https://github.com/webview/webview) through the native C FFI.

The module uses `src` as its MoonBit source directory. The public MoonBit API lives in `src/*.mbt`, the MoonBit-to-C++ bridge is `src/webview_stub.cc`, and vendored native headers live in `src/vendor`.

## Status

Implemented:

- `WebView::new`
- `WebView::destroy`
- `WebView::run`
- `WebView::terminate`
- `WebView::set_title`
- `WebView::set_size`
- `WebView::navigate`
- `WebView::set_html`
- `WebView::init`
- `WebView::eval`
- `version_number`

Not implemented yet:

- `webview_bind`
- `webview_unbind`
- `webview_return`
- typed JSON helpers for JavaScript callbacks

## Native Files

`src/vendor/webview.h` is generated from upstream `webview/webview` using its amalgamation script. On Windows, upstream also requires `WebView2.h`; this repository includes `src/vendor/WebView2.h` from the `Microsoft.Web.WebView2` NuGet package so the bundled header can compile without a separate SDK install.

The runnable package must link the C++ runtime and platform libraries. The example in `src/examples/basic/moon.pkg` uses:

```moonbit
options(
  "is-main": true,
  link: {
    "native": {
      "cc-link-flags": "-lstdc++ -ladvapi32 -lole32 -lshell32 -lshlwapi -luser32 -lversion",
    },
  },
)
```

The library package compiles its stub with `g++`, while leaving MoonBit-generated C files on the default C compiler.

## Example

```mbt check
fn main {
  let view = try! @webview.WebView::new(debug=true)
  try! view.set_title("MoonBit webview")
  try! view.set_size(800, 600)
  try! view.set_html("<h1>Hello from MoonBit</h1>")
  try! view.run()
}
```

Run the example with:

```bash
moon run src/examples/basic --target native
```

Running the example opens a native GUI window.
