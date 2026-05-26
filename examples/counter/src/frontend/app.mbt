///|
struct CounterModel {
  mut count : Int
  view : Element
  client : @desktop.Client
}

///|
fn CounterModel::send_command(
  self : CounterModel,
  command : @shared.CounterAppCommand,
) -> Unit {
  self.client.request_with_callback_default(command, (
    response : @ipc.IpcResponse[@shared.CounterEvent],
  ) => {
    match response {
      Ok(CountChanged(count)) => {
        self.count = count
        self.render()
      }
      Ok(WindowTitleChanged(title)) => set_document_title(title)
      Err(_) => ()
    }
  })
}

///|
fn CounterModel::render(self : CounterModel) -> Unit {
  let count_text = self.count.to_string()
  self.view.set_text(count_text)
  set_document_title("MoonBit Counter (" + count_text + ")")
}

///|
fn CounterModel::increment(self : CounterModel, amount : Int) -> Unit {
  let command = @shared.CounterAppCommand::Counter(Increment(amount~))
  self.send_command(command)
}

///|
fn CounterModel::reset(self : CounterModel) -> Unit {
  let command = @shared.CounterAppCommand::Counter(Reset)
  self.send_command(command)
}

///|
fn main {
  let model = { count: 0, view: element_by_id("count"), client: Client() }
  element_by_id("inc").on_click(() => model.increment(1))
  element_by_id("dec").on_click(() => model.increment(-1))
  element_by_id("reset").on_click(() => model.reset())
  model.render()
}
