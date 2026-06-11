///|
async fn counter_html() -> String {
  guard @env.current_dir() is Some(cwd) else {
    fail("could not determine current directory")
  }
  let html = match (@desktop.resource_text("index.html") catch { _ => None }) {
    Some(html) => html
    None => @fs.read_file(cwd + "/examples/counter/static/index.html").text()
  }
  let frontend = match
    (@desktop.resource_text("frontend.js") catch { _ => None }) {
    Some(frontend) => frontend
    None =>
      @fs.read_file(
        cwd +
        "/_build/js/debug/build/shiguri-01/desktop-counter-example/frontend/frontend.js",
      ).text()
  }
  html.replace(old="__MOONBIT_COUNTER_FRONTEND__", new=frontend)
}

///|
fn load_counter_html() -> Result[String, String] {
  let result : Ref[Result[String, String]?] = Ref(None)
  @async.run_async_main(() => {
    let html = counter_html() catch {
      err => {
        result.val = Some(Err("\{to_repr(err)}"))
        return
      }
    }
    result.val = Some(Ok(html))
  })
  match result.val {
    Some(result) => result
    None => Err("counter frontend loader finished without a result")
  }
}

///|
fn handle_command(
  count : Int,
  request : @shared.IncrementRequest,
) -> (Int, @shared.CountChangedReply) {
  let next = count + request.amount
  (next, { count: next })
}

///|
fn main {
  let html = match load_counter_html() {
    Ok(html) => html
    Err(message) => {
      println(
        "failed to load counter frontend; run `just build-counter-example-frontend` first",
      )
      println(message)
      return
    }
  }
  @desktop.run(on_startup=app => {
    let window = app.create_window(
      WindowOptions(
        key="main",
        title="MoonBit Counter",
        width=640,
        height=420,
        load=Html(html),
      ),
    )
    window.set_title("MoonBit Counter")
    let count = Ref(0)
    let router = @desktop.IpcRouter()
      .handle(@shared.increment_endpoint, handler=request => {
        @async.sleep(1)
        let (next, event) = handle_command(count.val, request)
        count.val = next
        event
      })
      .handle(@shared.reset_endpoint, handler=_request => {
        @async.sleep(1)
        count.val = 0
        { count: 0 }
      })
      .handle(@shared.set_title_endpoint, handler=request => {
        title: request.title,
      })
    window.mount_ipc(router)
  }) catch {
    err => println("desktop runtime failed: \{to_repr(err)}")
  }
}
