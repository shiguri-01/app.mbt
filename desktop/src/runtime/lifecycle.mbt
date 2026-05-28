///|
/// Runtime-only window id. Persist `WindowSnapshot.key` instead.
pub(all) struct WindowId {
  priv value : Int
} derive(Debug, Eq)

///|
fn WindowId::WindowId(value : Int) -> WindowId {
  { value, }
}

///|
fn[T] run_async_value(handler : async () -> T) -> Result[T, Error]? {
  let result : Ref[Result[T, Error]?] = Ref(None)
  @async.run_async_main(() => {
    let value = handler() catch {
      err => {
        result.val = Some(Err(err))
        return
      }
    }
    result.val = Some(Ok(value))
  })
  result.val
}

///|
/// Return the numeric value of this runtime-only window id.
pub fn WindowId::to_int(self : WindowId) -> Int {
  self.value
}

///|
/// Decision returned by lifecycle hooks that can veto close or quit.
pub(all) enum CloseDecision {
  Allow
  Prevent
} derive(Debug, Eq)

///|
/// Reason a window close was requested.
pub(all) enum CloseReason {
  User
  AppQuit
  Programmatic
  SystemShutdown
} derive(Debug, Eq)

///|
/// Reason an application quit was requested.
pub(all) enum QuitReason {
  Requested
  LastWindowClosed
  Programmatic
} derive(Debug, Eq)

///|
/// Per-window lifecycle callbacks.
pub struct WindowLifecycle {
  on_created : (async (Window) -> Unit)?
  on_ready : (async (Window) -> Unit)?
  on_focus : ((Window) -> Unit)?
  on_blur : ((Window) -> Unit)?
  on_minimize : ((Window) -> Unit)?
  on_maximize : ((Window) -> Unit)?
  on_restore : ((Window) -> Unit)?
  before_close : (async (Window, CloseReason) -> CloseDecision)?
  on_closed : ((Window) -> Unit)?
}

///|
/// Build per-window lifecycle callbacks.
pub fn WindowLifecycle::WindowLifecycle(
  on_created? : async (Window) -> Unit,
  on_ready? : async (Window) -> Unit,
  on_focus? : (Window) -> Unit,
  on_blur? : (Window) -> Unit,
  on_minimize? : (Window) -> Unit,
  on_maximize? : (Window) -> Unit,
  on_restore? : (Window) -> Unit,
  before_close? : async (Window, CloseReason) -> CloseDecision,
  on_closed? : (Window) -> Unit,
) -> WindowLifecycle {
  {
    on_created,
    on_ready,
    on_focus,
    on_blur,
    on_minimize,
    on_maximize,
    on_restore,
    before_close,
    on_closed,
  }
}

///|
fn WindowLifecycle::empty() -> WindowLifecycle {
  WindowLifecycle()
}

///|
/// Application-level lifecycle callbacks.
pub struct AppLifecycle {
  before_quit : (async (App, QuitReason) -> CloseDecision)?
  on_quit : ((App) -> Unit)?
}

///|
/// Build application-level lifecycle callbacks.
pub fn AppLifecycle::AppLifecycle(
  before_quit? : async (App, QuitReason) -> CloseDecision,
  on_quit? : (App) -> Unit,
) -> AppLifecycle {
  { before_quit, on_quit }
}

///|
fn AppLifecycle::empty() -> AppLifecycle {
  AppLifecycle()
}

///|
/// Serializable window state used by application-provided session stores.
pub(all) struct WindowSnapshot {
  key : String
  title : String
  width : Int
  height : Int
  maximized : Bool
  minimized : Bool
  visible : Bool
  load : Load?
} derive(Debug, Eq)

///|
/// Application-provided storage for startup window restoration.
pub struct WindowStateStore {
  load_windows : () -> Array[WindowSnapshot] raise DesktopError
  save_windows : (Array[WindowSnapshot]) -> Unit raise DesktopError
}

///|
/// Build a state store from load and save callbacks.
pub fn WindowStateStore::WindowStateStore(
  load_windows~ : () -> Array[WindowSnapshot] raise DesktopError,
  save_windows~ : (Array[WindowSnapshot]) -> Unit raise DesktopError,
) -> WindowStateStore {
  { load_windows, save_windows }
}
