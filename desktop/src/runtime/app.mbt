///|
struct AppState {
  mut next_window_id : Int
  mut windows : Array[Window]
  mut event_loop_view : @webview.WebView?
  mut running : Bool
  mut startup_complete : Bool
  mut quitting : Bool
  mut quit_notified : Bool
  options : AppOptions
  lifecycle : AppLifecycle
}

///|
/// Desktop application owner. An `App` owns the native event loop and all
/// windows created during the run.
pub struct App {
  priv state : AppState
}

///|
/// Application runtime options.
pub struct AppOptions {
  quit_when_last_window_closed : Bool
  restore_windows : Bool
  state_store : WindowStateStore?
}

///|
/// Build application options.
pub fn AppOptions::AppOptions(
  quit_when_last_window_closed? : Bool = true,
  restore_windows? : Bool = false,
  state_store? : WindowStateStore,
) -> AppOptions {
  { quit_when_last_window_closed, restore_windows, state_store }
}

///|
/// Return the default application options.
pub fn AppOptions::default() -> AppOptions {
  AppOptions()
}

///|
/// Create an application owner without starting the native event loop.
pub fn App::App(
  options? : AppOptions = AppOptions::default(),
  lifecycle? : AppLifecycle,
) -> App {
  let lifecycle = match lifecycle {
    Some(lifecycle) => lifecycle
    None => AppLifecycle::empty()
  }
  {
    state: {
      next_window_id: 1,
      windows: [],
      event_loop_view: None,
      running: false,
      startup_complete: false,
      quitting: false,
      quit_notified: false,
      options,
      lifecycle,
    },
  }
}

///|
fn App::next_id(self : App) -> WindowId {
  let id = self.state.next_window_id
  self.state.next_window_id = id + 1
  WindowId(id)
}

///|
fn App::register_window(self : App, window : Window) -> Unit {
  self.state.windows.push(window)
  match self.state.event_loop_view {
    Some(_) => ()
    None => self.state.event_loop_view = Some(window.raw_view())
  }
}

///|
fn App::unregister_window(self : App, id : WindowId) -> Unit {
  let kept = []
  for window in self.state.windows {
    if window.id() != id {
      kept.push(window)
    }
  }
  self.state.windows = kept
}

///|
fn App::live_windows(self : App) -> Array[Window] {
  let live = []
  for window in self.state.windows {
    if !window.is_closed() {
      live.push(window)
    }
  }
  live
}

///|
/// Return all live windows owned by this application.
pub fn App::windows(self : App) -> Array[Window] {
  self.live_windows()
}

///|
/// Find a live window by runtime id.
pub fn App::window(self : App, id : WindowId) -> Window? {
  for window in self.state.windows {
    if window.id() == id && !window.is_closed() {
      return Some(window)
    }
  }
  None
}

///|
fn App::first_live_window(self : App) -> Window? {
  for window in self.state.windows {
    if !window.is_closed() {
      return Some(window)
    }
  }
  None
}

///|
fn App::snapshot_windows(self : App) -> Array[WindowSnapshot] {
  let snapshots = []
  for window in self.state.windows {
    match window.snapshot() {
      Some(snapshot) => snapshots.push(snapshot)
      None => ()
    }
  }
  snapshots
}

///|
/// Persist restorable window state through the configured state store.
pub fn App::save_window_state(self : App) -> Unit raise DesktopError {
  match self.state.options.state_store {
    Some(store) => (store.save_windows)(self.snapshot_windows())
    None => ()
  }
}

///|
/// Recreate windows from the configured state store.
pub fn App::restore_windows(
  self : App,
  lifecycle? : WindowLifecycle,
) -> Array[Window] raise DesktopError {
  match self.state.options.state_store {
    Some(store) => {
      let restored = []
      for snapshot in (store.load_windows)() {
        let window = self.create_window(snapshot.to_options(), lifecycle?)
        if snapshot.maximized {
          window.maximize()
        } else if snapshot.minimized {
          window.minimize()
        }
        if !snapshot.visible {
          window.hide()
        }
        restored.push(window)
      }
      restored
    }
    None => []
  }
}

///|
fn App::run_startup(
  self : App,
  on_startup : async (App) -> Unit,
) -> Unit raise DesktopError {
  match @async_driver.run_unit(() => on_startup(self)) {
    Some(Ok(_)) => ()
    Some(Err(err)) => raise_error_as_desktop(err)
    None =>
      raise InvalidState("async startup finished without producing a result")
  }
}

///|
fn App::run_app_lifecycle(
  self : App,
  reason : QuitReason,
) -> CloseDecision raise DesktopError {
  match self.state.lifecycle.before_quit {
    Some(before_quit) =>
      match run_async_value(() => before_quit(self, reason)) {
        Some(Ok(decision)) => decision
        Some(Err(err)) => {
          raise_error_as_desktop(err)
          abort("unreachable")
        }
        None =>
          raise InvalidState(
            "async before_quit finished without producing a result",
          )
      }
    None => Allow
  }
}

///|
fn App::load_pending_windows(self : App) -> Unit raise DesktopError {
  for window in self.state.windows {
    window.load_initial_content()
  }
}

///|
/// Create and register a native window.
pub fn App::create_window(
  self : App,
  options : WindowOptions,
  lifecycle? : WindowLifecycle,
) -> Window raise DesktopError {
  let lifecycle = match lifecycle {
    Some(lifecycle) => lifecycle
    None => WindowLifecycle::empty()
  }
  let view = @webview.WebView::new(debug=options.debug) catch {
    err => {
      raise_webview(err)
      abort("unreachable")
    }
  }
  let window = Window::make(
    self.state,
    self.next_id(),
    options,
    lifecycle,
    view,
  )
  self.register_window(window)
  window.configure_native_window()
  window.run_created_lifecycle()
  window.run_ready_lifecycle()
  if self.state.startup_complete {
    window.load_initial_content()
  }
  window
}

///|
/// Ask lifecycle hooks whether the app may quit, then close all windows.
pub fn App::request_quit(self : App) -> Unit raise DesktopError {
  if self.state.quitting {
    return
  }
  if self.run_app_lifecycle(Requested) is Prevent {
    return
  }
  self.state.quitting = true
  let windows = self.live_windows()
  for window in windows {
    if !window.request_close_with_reason(AppQuit) {
      self.state.quitting = false
      return
    }
  }
  self.save_window_state()
  self.quit()
}

///|
/// Close all live windows and stop the native event loop.
pub fn App::quit(self : App) -> Unit raise DesktopError {
  self.state.quitting = true
  self.save_window_state()
  for window in self.live_windows() {
    window.close()
  }
  match self.first_live_window() {
    Some(window) => window.stop_event_loop()
    None => ()
  }
  self.notify_quit()
  self.state.running = false
}

///|
fn App::notify_quit(self : App) -> Unit {
  if self.state.quit_notified {
    return
  }
  self.state.quit_notified = true
  match self.state.lifecycle.on_quit {
    Some(on_quit) => on_quit(self)
    None => ()
  }
}

///|
fn App::quit_after_last_window(self : App) -> Unit raise DesktopError {
  if self.state.quitting || self.state.options.quit_when_last_window_closed {
    self.quit()
  }
}

///|
fn App::will_quit_after_closing(self : App, window : Window) -> Bool {
  if self.state.quitting || !self.state.options.quit_when_last_window_closed {
    return false
  }
  let live = self.live_windows()
  if live.length() != 1 {
    false
  } else {
    match live.get(0) {
      Some(live_window) => live_window.id() == window.id()
      None => false
    }
  }
}

///|
/// Start the native event loop for this application.
pub fn App::run(
  self : App,
  on_startup~ : async (App) -> Unit,
) -> Unit raise DesktopError {
  if self.state.running {
    raise InvalidState("application is already running")
  }
  self.state.running = true
  if self.state.options.restore_windows {
    ignore(self.restore_windows())
  }
  self.run_startup(on_startup)
  self.state.startup_complete = true
  self.load_pending_windows()
  match self.state.event_loop_view {
    Some(view) => run_event_loop_view(view)
    None => ()
  }
  self.save_window_state()
  self.notify_quit()
  self.state.running = false
}

///|
/// Run a desktop application. The callback receives the `App` owner and should
/// create one or more windows before returning.
pub fn run(
  options? : AppOptions = AppOptions::default(),
  lifecycle? : AppLifecycle,
  on_startup~ : async (App) -> Unit,
) -> Unit raise DesktopError {
  App(options~, lifecycle?).run(on_startup~)
}
