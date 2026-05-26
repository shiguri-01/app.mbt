///|
/// Native desktop window managed by the runtime.
pub struct Window {
  priv view : @webview.WebView
}

///|
/// Options used by `run`.
pub struct WindowOptions {
  title : String
  width : Int
  height : Int
  debug : Bool
  load : Load?
} derive(Debug, Eq)

///|
/// Create window options for `run_with_options`.
pub fn WindowOptions::WindowOptions(
  title~ : String,
  width? : Int = 800,
  height? : Int = 600,
  debug? : Bool = false,
  load? : Load,
) -> WindowOptions {
  { title, width, height, debug, load }
}

///|
/// Set the native window title.
pub fn Window::set_title(
  self : Window,
  title : String,
) -> Unit raise DesktopError {
  self.view.set_title(title) catch {
    err => raise_webview(err)
  }
}

///|
/// Evaluate JavaScript in the current page.
pub fn Window::eval(self : Window, js : String) -> Unit raise DesktopError {
  self.view.eval(js) catch {
    err => raise_webview(err)
  }
}

///|
/// Replace the current page with an HTML string.
pub fn Window::set_html(
  self : Window,
  html : String,
) -> Unit raise DesktopError {
  self.view.set_html(html) catch {
    err => raise_webview(err)
  }
}

///|
/// Navigate the webview to a URL.
pub fn Window::navigate(self : Window, url : String) -> Unit raise DesktopError {
  self.view.navigate(url) catch {
    err => raise_webview(err)
  }
}

///|
/// Remove a JavaScript bridge binding.
pub fn Window::unbind(self : Window, name : String) -> Unit raise DesktopError {
  self.view.unbind(name) catch {
    err => raise_webview(err)
  }
}

///|
/// Stop the native event loop.
pub fn Window::terminate(self : Window) -> Unit raise DesktopError {
  self.view.terminate() catch {
    err => raise_webview(err)
  }
}
