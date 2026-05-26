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
