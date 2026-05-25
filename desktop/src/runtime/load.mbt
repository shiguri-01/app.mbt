///|
/// Initial content loaded into a desktop window.
pub(all) enum Load {
  Url(String)
  Html(String)
} derive(Debug, Eq)

///|
fn Load::apply(self : Load, window : Window) -> Unit raise DesktopError {
  match self {
    Url(url) => window.view.navigate(url) catch { err => raise_webview(err) }
    Html(html) => window.view.set_html(html) catch { err => raise_webview(err) }
  }
}
