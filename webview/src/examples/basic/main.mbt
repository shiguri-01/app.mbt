///|
/// Entry point for the CLI or runnable program in this template.
/// Keep main focused; move logic into the library package.
/// Run with `moon run src/examples/basic` from the project root.
fn main {
  try! @webview.WebView::new(debug=true)
  ..set_title("hello")
  ..set_size(800, 600)
  ..set_html("<h1>Hello from MoonBit</h1>")
  .run()
}
