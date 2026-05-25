///|
struct CounterModel {
  mut count : Int
  view : Element
  client : @desktop.Client
}

///|
fn CounterModel::send(
  self : CounterModel,
  command : @shared.CounterAppCommand,
) -> Unit {
  post_message(self.client.event(command))
}

///|
fn CounterModel::render(self : CounterModel) -> Unit {
  let count_text = self.count.to_string()
  self.view.set_text(count_text)
  set_document_title("MoonBit Counter (" + count_text + ")")
}

///|
fn CounterModel::increment(self : CounterModel, amount : Int) -> Unit {
  let command = @shared.CounterAppCommand::Counter(
    @shared.CounterCommand::Increment(amount~),
  )
  self.send(command)
  self.count += amount
  self.render()
}

///|
fn CounterModel::reset(self : CounterModel) -> Unit {
  let command = @shared.CounterAppCommand::Counter(
    @shared.CounterCommand::Reset,
  )
  self.send(command)
  self.count = 0
  self.render()
}

///|
fn main {
  let model = {
    count: 0,
    view: element_by_id("count"),
    client: @desktop.Client::new(),
  }
  element_by_id("inc").on_click(() => model.increment(1))
  element_by_id("dec").on_click(() => model.increment(-1))
  element_by_id("reset").on_click(() => model.reset())
  model.render()
}
