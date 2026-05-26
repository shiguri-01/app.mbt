///|
/// Errors raised by the desktop runtime.
pub(all) suberror DesktopError {
  WebView(String)
  Ipc(String)
  InvalidState(String)
} derive(Debug, Eq)

///|
fn webview_error_to_string(err : @webview.WebViewError) -> String {
  match err {
    CreationFailed => "webview creation failed"
    MissingDependency => "webview dependency is missing"
    Canceled => "webview operation was canceled"
    InvalidState => "webview is in an invalid state"
    InvalidArgument => "webview received an invalid argument"
    Unspecified => "webview reported an unspecified error"
    Duplicate => "webview item already exists"
    NotFound => "webview item was not found"
    Unknown(code) => "webview reported unknown status \{code}"
  }
}

///|
fn raise_webview(err : @webview.WebViewError) -> Unit raise DesktopError {
  raise WebView(webview_error_to_string(err))
}

///|
fn desktop_error_to_string(err : DesktopError) -> String {
  match err {
    WebView(message) => "webview: \{message}"
    Ipc(message) => "ipc: \{message}"
    InvalidState(message) => "invalid state: \{message}"
  }
}

///|
fn error_to_string(err : Error) -> String {
  match err {
    WebView(message) => desktop_error_to_string(WebView(message))
    Ipc(message) => desktop_error_to_string(Ipc(message))
    InvalidState(message) => desktop_error_to_string(InvalidState(message))
    _ => err.to_string()
  }
}

///|
fn raise_error_as_desktop(err : Error) -> Unit raise DesktopError {
  match err {
    WebView(message) => raise WebView(message)
    Ipc(message) => raise Ipc(message)
    InvalidState(message) => raise InvalidState(message)
    _ => raise InvalidState(error_to_string(err))
  }
}
