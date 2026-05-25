///|
/// Native desktop window managed by the runtime.
pub struct Window {
  view : @webview.WebView
}

///|
/// Options used by `run`.
pub(all) struct WindowOptions {
  title : String
  width : Int
  height : Int
  debug : Bool
  load : Load?
} derive(Debug, Eq)

///|
pub fn WindowOptions::new(
  title~ : String,
  width? : Int = 800,
  height? : Int = 600,
  debug? : Bool = false,
  load? : Load,
) -> WindowOptions {
  { title, width, height, debug, load }
}

///|
pub fn Window::set_title(
  self : Window,
  title : String,
) -> Unit raise DesktopError {
  self.view.set_title(title) catch {
    err => raise_webview(err)
  }
}

///|
pub fn Window::eval(self : Window, js : String) -> Unit raise DesktopError {
  self.view.eval(js) catch {
    err => raise_webview(err)
  }
}

///|
pub fn Window::terminate(self : Window) -> Unit raise DesktopError {
  self.view.terminate() catch {
    err => raise_webview(err)
  }
}
