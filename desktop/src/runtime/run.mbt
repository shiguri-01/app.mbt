///|
/// Run a single-window desktop application.
///
/// `on_ready` runs before loading content and entering the blocking native
/// webview event loop so applications can register IPC handlers first.
pub async fn run(
  title~ : String,
  width? : Int = 800,
  height? : Int = 600,
  debug? : Bool = false,
  load? : Load,
  on_ready~ : async (Window) -> Unit raise DesktopError,
) -> Unit raise DesktopError {
  let options = { title, width, height, debug, load }
  run_with_options(options, on_ready~)
}

///|
pub async fn run_with_options(
  options : WindowOptions,
  on_ready~ : async (Window) -> Unit raise DesktopError,
) -> Unit raise DesktopError {
  @async.pause() catch {
    _ => ()
  }
  let view = @webview.WebView::new(debug=options.debug) catch {
    err => {
      raise_webview(err)
      abort("unreachable")
    }
  }
  let window = { view, }
  view.set_title(options.title) catch {
    err => raise_webview(err)
  }
  view.set_size(options.width, options.height) catch {
    err => raise_webview(err)
  }
  on_ready(window)
  match options.load {
    Some(load) => load.apply(window)
    None => ()
  }
  view.run() catch {
    err => raise_webview(err)
  }
}

///|
/// Decode a typed payload and run an async typed handler.
pub async fn[T : FromJson, R] dispatch(
  envelope : @ipc.Envelope,
  handler : async (T) -> R raise DesktopError,
) -> @ipc.Response[R] {
  @async.pause() catch {
    _ => ()
  }
  let command : T = envelope.decode() catch {
    err => {
      raise_ipc(err) catch {
        desktop_err =>
          return Err(
            @ipc.IpcError::HandlerError(desktop_error_to_string(desktop_err)),
          )
      }
      abort("unreachable")
    }
  }
  let response = handler(command) catch {
    err => return Err(@ipc.IpcError::HandlerError(desktop_error_to_string(err)))
  }
  Ok(response)
}
