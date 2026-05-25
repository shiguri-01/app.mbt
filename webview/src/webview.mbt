///|
/// Create a new top-level webview window.
pub fn WebView::new(debug? : Bool = false) -> WebView raise WebViewError {
  let view = ffi_create(debug)
  if view.is_valid() {
    view
  } else {
    raise WebViewError::CreationFailed
  }
}

///|
/// Return whether this handle currently owns a live native webview.
pub fn WebView::is_valid(self : WebView) -> Bool {
  ffi_is_valid(self)
}

///|
/// Destroy the native webview if it has not already been destroyed.
pub fn WebView::destroy(self : WebView) -> Unit raise WebViewError {
  check_status(ffi_destroy(self))
}

///|
/// Run the GUI event loop until the webview is terminated.
pub fn WebView::run(self : WebView) -> Unit raise WebViewError {
  check_status(ffi_run(self))
}

///|
/// Stop the GUI event loop. This can be called from another thread.
pub fn WebView::terminate(self : WebView) -> Unit raise WebViewError {
  check_status(ffi_terminate(self))
}

///|
/// Set the native window title.
pub fn WebView::set_title(
  self : WebView,
  title : String,
) -> Unit raise WebViewError {
  check_status(ffi_set_title(self, @utf8.encode(title)))
}

///|
/// Set the native window size.
pub fn WebView::set_size(
  self : WebView,
  width : Int,
  height : Int,
  hint? : SizeHint = None,
) -> Unit raise WebViewError {
  check_status(ffi_set_size(self, width, height, hint.to_int()))
}

///|
/// Navigate to a URL or data URI.
pub fn WebView::navigate(
  self : WebView,
  url : String,
) -> Unit raise WebViewError {
  check_status(ffi_navigate(self, @utf8.encode(url)))
}

///|
/// Load an HTML string into the webview.
pub fn WebView::set_html(
  self : WebView,
  html : String,
) -> Unit raise WebViewError {
  check_status(ffi_set_html(self, @utf8.encode(html)))
}

///|
/// Inject JavaScript to run before `window.onload` on future page loads.
pub fn WebView::init(self : WebView, js : String) -> Unit raise WebViewError {
  check_status(ffi_init(self, @utf8.encode(js)))
}

///|
/// Evaluate JavaScript in the current page.
pub fn WebView::eval(self : WebView, js : String) -> Unit raise WebViewError {
  check_status(ffi_eval(self, @utf8.encode(js)))
}

///|
/// Return the bundled webview library version string.
pub fn version_number() -> String {
  @utf8.decode_lossy(ffi_version_number())
}
