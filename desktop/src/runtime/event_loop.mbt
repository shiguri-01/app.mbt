///|
fn run_event_loop_view(view : @webview.WebView) -> Unit raise DesktopError {
  view.run() catch {
    err => raise_webview(err)
  }
}
