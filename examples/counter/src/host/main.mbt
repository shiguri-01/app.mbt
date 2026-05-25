///|
async fn counter_html() -> String {
  guard @env.current_dir() is Some(cwd) else {
    fail("could not determine current directory")
  }
  let html = @fs.read_file(cwd + "/examples/counter/static/index.html").text()
  let frontend = @fs.read_file(
    cwd +
    "/_build/js/debug/build/shiguri-01/desktop-counter-example/frontend/frontend.js",
  ).text()
  html.replace(old="__MOONBIT_COUNTER_FRONTEND__", new=frontend)
}

///|
fn handle_command(
  count : Int,
  command : @shared.CounterAppCommand,
) -> (Int, @shared.CounterEvent) {
  match command {
    Counter(Increment(amount~)) => {
      let next = count + amount
      (next, CountChanged(next))
    }
    Counter(Reset) => (0, CountChanged(0))
    Window(SetTitle(title)) => (count, WindowTitleChanged(title))
    Window(Close) => (count, CountChanged(count))
  }
}

///|
async fn main {
  let html = counter_html() catch {
    _ => {
      println(
        "failed to load counter frontend; run `just build-counter-example-frontend` first",
      )
      return
    }
  }
  @desktop.run(
    title="MoonBit Counter",
    width=640,
    height=420,
    load=Html(html),
    on_ready=window => {
      window.set_title("MoonBit Counter")
      let count = Ref(0)
      window.handle_sync("moonbitDesktop", command => {
        let (next, event) = handle_command(count.val, command)
        count.val = next
        event
      })
    },
  ) catch {
    _ => println("desktop runtime failed")
  }
}
