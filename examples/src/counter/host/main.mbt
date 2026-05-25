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
  let html =
    #|<!doctype html>
    #|<meta charset="utf-8">
    #|<title>MoonBit Counter</title>
    #|<h1>MoonBit Counter</h1>
    #|<p>This example is loaded by the desktop runtime.</p>
    #|
  @desktop.run(
    title="MoonBit Counter",
    width=640,
    height=420,
    load=Html(html),
    on_ready=window => {
      window.set_title("MoonBit Counter")
      let (count, event) = handle_command(
        0,
        @shared.CounterAppCommand::Counter(
          @shared.CounterCommand::Increment(amount=1),
        ),
      )
      ignore(count)
      window.eval("console.log(" + event.to_json().stringify().escape() + ")")
    },
  ) catch {
    _ => println("desktop runtime failed")
  }
}
