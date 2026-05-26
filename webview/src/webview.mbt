///|
/// Create a new top-level webview window.
pub fn WebView::new(debug? : Bool = false) -> WebView raise WebViewError {
  let view = ffi_create(debug)
  if view.is_valid() {
    view
  } else {
    raise CreationFailed
  }
}

///|
/// Return whether this handle currently owns a live native webview.
pub fn WebView::is_valid(self : WebView) -> Bool {
  ffi_is_valid(self)
}

///|
/// Return the borrowed native top-level window handle for this webview.
///
/// The returned handle is opaque and only valid while this `WebView` remains
/// alive. It is intended for higher-level native shell integrations such as
/// dialogs and menus.
pub fn WebView::native_window(
  self : WebView,
) -> NativeWindow raise WebViewError {
  if ffi_has_native_window(self) {
    ffi_get_native_window(self)
  } else {
    raise InvalidState
  }
}

///|
/// Destroy the native webview if it has not already been destroyed.
pub fn WebView::destroy(self : WebView) -> Unit raise WebViewError {
  check_status(ffi_destroy(self))
}

///|
/// Run the GUI event loop until the webview is terminated.
pub fn WebView::run(self : WebView) -> Unit raise WebViewError {
  let status = ffi_run(self)
  // Keep the external object alive for the whole blocking native run call.
  ignore(self.is_valid())
  check_status(status)
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
/// Bind a JavaScript function to a native MoonBit callback.
///
/// The callback receives the webview request id and the raw JSON argument array
/// supplied by `webview_bind`.
pub fn WebView::bind(
  self : WebView,
  name : String,
  handler : (String, String) -> Unit,
) -> Unit raise WebViewError {
  check_status(
    ffi_bind(
      self,
      @utf8.encode(name),
      (callback, id, req) => callback(id, req),
      (id, req) => handler(@utf8.decode_lossy(id), @utf8.decode_lossy(req)),
    ),
  )
}

///|
/// Remove a JavaScript binding created by `bind`.
pub fn WebView::unbind(
  self : WebView,
  name : String,
) -> Unit raise WebViewError {
  check_status(ffi_unbind(self, @utf8.encode(name)))
}

///|
/// Resolve or reject a JavaScript binding call.
///
/// `result` must be a JSON value, or the empty string for JavaScript
/// `undefined`.
pub fn WebView::return_(
  self : WebView,
  id : String,
  status : Int,
  result : String,
) -> Unit raise WebViewError {
  check_status(ffi_return(self, @utf8.encode(id), status, @utf8.encode(result)))
}

///|
/// Schedule a callback on the native GUI event-loop thread.
///
/// This is the safe way to return to webview APIs from work that completes
/// outside the binding callback path.
pub fn WebView::dispatch(
  self : WebView,
  handler : () -> Unit,
) -> Unit raise WebViewError {
  check_status(ffi_dispatch(self, callback => callback(), handler))
}

///|
/// Close the native top-level window without asking the runtime to confirm.
pub fn WebView::close_window(self : WebView) -> Unit raise WebViewError {
  check_status(ffi_close_window(self))
}

///|
/// Focus the native top-level window.
pub fn WebView::focus_window(self : WebView) -> Unit raise WebViewError {
  check_status(ffi_focus_window(self))
}

///|
/// Minimize the native top-level window.
pub fn WebView::minimize_window(self : WebView) -> Unit raise WebViewError {
  check_status(ffi_minimize_window(self))
}

///|
/// Maximize the native top-level window.
pub fn WebView::maximize_window(self : WebView) -> Unit raise WebViewError {
  check_status(ffi_maximize_window(self))
}

///|
/// Restore the native top-level window from minimized or maximized state.
pub fn WebView::restore_window(self : WebView) -> Unit raise WebViewError {
  check_status(ffi_restore_window(self))
}

///|
/// Show the native top-level window.
pub fn WebView::show_window(self : WebView) -> Unit raise WebViewError {
  check_status(ffi_show_window(self))
}

///|
/// Hide the native top-level window.
pub fn WebView::hide_window(self : WebView) -> Unit raise WebViewError {
  check_status(ffi_hide_window(self))
}

///|
/// Return whether the native top-level window has been closed.
pub fn WebView::is_window_closed(self : WebView) -> Bool {
  ffi_is_window_closed(self)
}

///|
/// Register a native top-level window event callback.
pub fn WebView::on_window_event(
  self : WebView,
  handler : (WindowEvent) -> Unit,
) -> Unit raise WebViewError {
  check_status(
    ffi_set_window_event_handler(self, (callback, code) => callback(code), code => {
      match WindowEvent::from_int(code) {
        Some(event) => handler(event)
        None => ()
      }
    }),
  )
}

///|
/// Return the bundled webview library version string.
pub fn version_number() -> String {
  @utf8.decode_lossy(ffi_version_number())
}
