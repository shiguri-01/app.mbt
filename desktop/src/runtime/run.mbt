///|
/// Run a single-window desktop application.
///
/// `on_ready` runs before loading content and entering the blocking native
/// webview event loop so applications can register IPC handlers first.
pub fn run(
  title~ : String,
  width? : Int = 800,
  height? : Int = 600,
  debug? : Bool = false,
  load? : Load,
  on_ready~ : async (Window) -> Unit,
) -> Unit raise DesktopError {
  let options = WindowOptions(title~, width~, height~, debug~, load?)
  run_with_options(options, on_ready~)
}

///|
/// Run a single-window application from an options value.
pub fn run_with_options(
  options : WindowOptions,
  on_ready~ : async (Window) -> Unit,
) -> Unit raise DesktopError {
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
  match @async_driver.run_unit(() => on_ready(window)) {
    Some(Ok(_)) => ()
    Some(Err(err)) => raise_error_as_desktop(err)
    None =>
      raise InvalidState("async setup finished without producing a result")
  }
  match options.load {
    Some(load) => load.apply(window)
    None => ()
  }
  view.run() catch {
    err => raise_webview(err)
  }
}
