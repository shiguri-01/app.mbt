///|
/// Opaque handle to a native webview instance.
pub type WebView

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
