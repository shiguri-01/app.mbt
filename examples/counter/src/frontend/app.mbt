///|
struct CounterModel {
  mut count : Int
  view : Element
  client : @desktop.Client
}

///|
fn CounterModel::handle_count_response(
  self : CounterModel,
  response : @ipc.IpcResponse[@shared.CountChangedReply],
) -> Unit {
  match response {
    Ok(reply) => {
      self.count = reply.count
      self.render()
    }
    Err(_) => ()
  }
}

///|
fn CounterModel::render(self : CounterModel) -> Unit {
  let count_text = self.count.to_string()
  self.view.set_text(count_text)
  set_document_title("MoonBit Counter (" + count_text + ")")
}

///|
fn CounterModel::increment(self : CounterModel, amount : Int) -> Unit {
  self.client.request_endpoint_with_callback(
    @shared.increment_endpoint,
    @shared.IncrementRequest::{ amount, },
    response => self.handle_count_response(response),
  )
}

///|
fn CounterModel::reset(self : CounterModel) -> Unit {
  self.client.request_endpoint_with_callback(@shared.reset_endpoint, (), response => {
    self.handle_count_response(response)
  })
}

///|
fn main {
  let model = { count: 0, view: element_by_id("count"), client: Client() }
  element_by_id("inc").on_click(() => model.increment(1))
  element_by_id("dec").on_click(() => model.increment(-1))
  element_by_id("reset").on_click(() => model.reset())
  model.render()
}
