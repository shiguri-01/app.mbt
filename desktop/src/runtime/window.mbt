///|
/// Native desktop window managed by the runtime.
pub struct Window {
  priv id : WindowId
  priv key : String?
  priv app_state : AppState
  priv view : @webview.WebView
  priv lifecycle : WindowLifecycle
  priv mut title : String
  priv width : Int
  priv height : Int
  priv resizable : Bool
  priv min_width : Int?
  priv min_height : Int?
  priv mut visible : Bool
  priv mut minimized : Bool
  priv mut maximized : Bool
  priv mut closed : Bool
  priv mut close_pending : Bool
  priv mut initial_load : Load?
  priv mut initial_load_applied : Bool
}

///|
/// Options used when creating a window.
pub struct WindowOptions {
  key : String?
  title : String
  width : Int
  height : Int
  debug : Bool
  resizable : Bool
  visible : Bool
  min_width : Int?
  min_height : Int?
  load : Load?
} derive(Debug, Eq)

///|
/// Create window options for `App::create_window`.
pub fn WindowOptions::WindowOptions(
  key? : String,
  title~ : String,
  width? : Int = 800,
  height? : Int = 600,
  debug? : Bool = false,
  resizable? : Bool = true,
  visible? : Bool = true,
  min_width? : Int,
  min_height? : Int,
  load? : Load,
) -> WindowOptions {
  {
    key,
    title,
    width,
    height,
    debug,
    resizable,
    visible,
    min_width,
    min_height,
    load,
  }
}

///|
fn WindowSnapshot::to_options(self : WindowSnapshot) -> WindowOptions {
  WindowOptions(
    key=self.key,
    title=self.title,
    width=self.width,
    height=self.height,
    visible=self.visible,
    load?=self.load,
  )
}

///|
fn Window::make(
  app_state : AppState,
  id : WindowId,
  options : WindowOptions,
  lifecycle : WindowLifecycle,
  view : @webview.WebView,
) -> Window {
  {
    id,
    key: options.key,
    app_state,
    view,
    lifecycle,
    title: options.title,
    width: options.width,
    height: options.height,
    resizable: options.resizable,
    min_width: options.min_width,
    min_height: options.min_height,
    visible: options.visible,
    minimized: false,
    maximized: false,
    closed: false,
    close_pending: false,
    initial_load: options.load,
    initial_load_applied: false,
  }
}

///|
fn Window::raw_view(self : Window) -> @webview.WebView {
  self.view
}

///|
/// Return this window's runtime-only id.
pub fn Window::id(self : Window) -> WindowId {
  self.id
}

///|
/// Return this window's stable restoration key, when one was configured.
pub fn Window::key(self : Window) -> String? {
  self.key
}

///|
fn Window::snapshot(self : Window) -> WindowSnapshot? {
  if self.closed {
    None
  } else {
    match self.key {
      Some(key) =>
        Some({
          key,
          title: self.title,
          width: self.width,
          height: self.height,
          maximized: self.maximized,
          minimized: self.minimized,
          visible: self.visible,
          load: self.initial_load,
        })
      None => None
    }
  }
}

///|
fn Window::configure_native_window(self : Window) -> Unit raise DesktopError {
  self.set_title(self.title)
  self.view.set_size(
    self.width,
    self.height,
    hint=if self.visible && !self.maximized && !self.minimized {
      if self.is_resizable() {
        None
      } else {
        Fixed
      }
    } else {
      None
    },
  ) catch {
    err => raise_webview(err)
  }
  match (self.min_width, self.min_height) {
    (Some(width), Some(height)) =>
      self.view.set_size(width, height, hint=Min) catch {
        err => raise_webview(err)
      }
    _ => ()
  }
  if !self.visible {
    self.hide()
  }
}

///|
fn Window::is_resizable(self : Window) -> Bool {
  self.resizable
}

///|
fn Window::app(self : Window) -> App {
  { state: self.app_state }
}

///|
/// Set the native window title.
pub fn Window::set_title(
  self : Window,
  title : String,
) -> Unit raise DesktopError {
  self.title = title
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
  self.initial_load = Some(Html(html))
  self.initial_load_applied = true
}

///|
/// Navigate the webview to a URL.
pub fn Window::navigate(self : Window, url : String) -> Unit raise DesktopError {
  self.view.navigate(url) catch {
    err => raise_webview(err)
  }
  self.initial_load = Some(Url(url))
  self.initial_load_applied = true
}

///|
/// Remove a JavaScript bridge binding.
pub fn Window::unbind(self : Window, name : String) -> Unit raise DesktopError {
  self.view.unbind(name) catch {
    err => raise_webview(err)
  }
}

///|
/// Close this window immediately.
pub fn Window::close(self : Window) -> Unit raise DesktopError {
  if self.closed {
    return
  }
  self.view.close_window() catch {
    err => raise_webview(err)
  }
  self.mark_closed()
}

///|
/// Request a programmatic close, allowing lifecycle hooks to prevent it.
pub fn Window::request_close(self : Window) -> Unit raise DesktopError {
  ignore(self.request_close_with_reason(Programmatic))
}

///|
fn Window::request_close_with_reason(
  self : Window,
  reason : CloseReason,
) -> Bool raise DesktopError {
  if self.closed {
    return true
  }
  if self.close_pending {
    return false
  }
  let app = self.app()
  if app.will_quit_after_closing(self) {
    if app.run_app_lifecycle(LastWindowClosed) is Prevent {
      return false
    }
  }
  self.close_pending = true
  let decision = self.run_before_close(reason) catch {
    err => {
      self.close_pending = false
      raise_error_as_desktop(err)
      abort("unreachable")
    }
  }
  match decision {
    Allow => {
      self.close() catch {
        err => {
          self.close_pending = false
          raise_error_as_desktop(err)
          abort("unreachable")
        }
      }
      true
    }
    Prevent => {
      self.close_pending = false
      false
    }
  }
}

///|
/// Focus the native top-level window.
pub fn Window::focus(self : Window) -> Unit raise DesktopError {
  self.view.focus_window() catch {
    err => raise_webview(err)
  }
}

///|
/// Minimize the native top-level window.
pub fn Window::minimize(self : Window) -> Unit raise DesktopError {
  self.minimized = true
  self.maximized = false
  self.view.minimize_window() catch {
    err => raise_webview(err)
  }
}

///|
/// Maximize the native top-level window.
pub fn Window::maximize(self : Window) -> Unit raise DesktopError {
  self.maximized = true
  self.minimized = false
  self.view.maximize_window() catch {
    err => raise_webview(err)
  }
}

///|
/// Restore the native top-level window from minimized or maximized state.
pub fn Window::restore(self : Window) -> Unit raise DesktopError {
  self.maximized = false
  self.minimized = false
  self.view.restore_window() catch {
    err => raise_webview(err)
  }
}

///|
/// Show the native top-level window.
pub fn Window::show(self : Window) -> Unit raise DesktopError {
  self.visible = true
  self.view.show_window() catch {
    err => raise_webview(err)
  }
}

///|
/// Hide the native top-level window.
pub fn Window::hide(self : Window) -> Unit raise DesktopError {
  self.visible = false
  self.view.hide_window() catch {
    err => raise_webview(err)
  }
}

///|
/// Return whether this window has been closed.
pub fn Window::is_closed(self : Window) -> Bool {
  self.closed || self.view.is_window_closed()
}

///|
fn Window::run_created_lifecycle(self : Window) -> Unit raise DesktopError {
  match self.lifecycle.on_created {
    Some(on_created) =>
      match @async_driver.run_unit(() => on_created(self)) {
        Some(Ok(_)) => ()
        Some(Err(err)) => raise_error_as_desktop(err)
        None =>
          raise InvalidState(
            "async on_created finished without producing a result",
          )
      }
    None => ()
  }
}

///|
fn Window::run_ready_lifecycle(self : Window) -> Unit raise DesktopError {
  match self.lifecycle.on_ready {
    Some(on_ready) =>
      match @async_driver.run_unit(() => on_ready(self)) {
        Some(Ok(_)) => ()
        Some(Err(err)) => raise_error_as_desktop(err)
        None =>
          raise InvalidState(
            "async on_ready finished without producing a result",
          )
      }
    None => ()
  }
}

///|
fn Window::run_before_close(
  self : Window,
  reason : CloseReason,
) -> CloseDecision raise DesktopError {
  match self.lifecycle.before_close {
    Some(before_close) =>
      match run_async_value(() => before_close(self, reason)) {
        Some(Ok(decision)) => decision
        Some(Err(err)) => {
          raise_error_as_desktop(err)
          abort("unreachable")
        }
        None =>
          raise InvalidState(
            "async before_close finished without producing a result",
          )
      }
    None => Allow
  }
}

///|
fn Window::load_initial_content(self : Window) -> Unit raise DesktopError {
  if self.initial_load_applied {
    return
  }
  self.initial_load_applied = true
  match self.initial_load {
    Some(load) => load.apply(self)
    None => ()
  }
}

///|
fn Window::stop_event_loop(self : Window) -> Unit raise DesktopError {
  self.view.terminate() catch {
    err => raise_webview(err)
  }
}

///|
fn Window::mark_closed(self : Window) -> Unit raise DesktopError {
  if self.closed {
    return
  }
  self.closed = true
  self.close_pending = false
  let app = self.app()
  app.unregister_window(self.id)
  match self.lifecycle.on_closed {
    Some(on_closed) => on_closed(self)
    None => ()
  }
  app.save_window_state()
  if app.windows().length() == 0 {
    app.quit_after_last_window()
  }
}
