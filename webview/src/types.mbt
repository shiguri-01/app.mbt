///|
/// Opaque handle to a native webview instance.
pub type WebView

///|
/// Borrowed native top-level window handle associated with a `WebView`.
///
/// This is an opaque platform handle. Callers must not store it beyond the
/// lifetime of the owning `WebView`.
#external
pub type NativeWindow

///|
/// Window size hint used by `WebView::set_size`.
pub(all) enum SizeHint {
  None
  Min
  Max
  Fixed
} derive(Debug, Eq)

///|
fn SizeHint::to_int(self : SizeHint) -> Int {
  match self {
    None => 0
    Min => 1
    Max => 2
    Fixed => 3
  }
}

///|
/// Native top-level window events reported by the host backend.
pub(all) enum WindowEvent {
  CloseRequested
  Closed
  Focused
  Blurred
  Minimized
  Maximized
  Restored
} derive(Debug, Eq)

///|
fn WindowEvent::from_int(code : Int) -> WindowEvent? {
  match code {
    1 => Some(CloseRequested)
    2 => Some(Closed)
    3 => Some(Focused)
    4 => Some(Blurred)
    5 => Some(Minimized)
    6 => Some(Maximized)
    7 => Some(Restored)
    _ => None
  }
}
