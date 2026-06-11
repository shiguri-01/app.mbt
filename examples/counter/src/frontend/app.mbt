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
async fn CounterModel::increment(self : CounterModel, amount : Int) -> Unit {
  let response = self.client.request(@shared.increment_endpoint, { amount, })
  self.handle_count_response(response)
}

///|
async fn CounterModel::reset(self : CounterModel) -> Unit {
  let response = self.client.request(@shared.reset_endpoint, ())
  self.handle_count_response(response)
}

///|
fn main {
  let model = { count: 0, view: element_by_id("count"), client: Client() }
  element_by_id("inc").on_click_async(() => model.increment(1))
  element_by_id("dec").on_click_async(() => model.increment(-1))
  element_by_id("reset").on_click_async(() => model.reset())
  model.render()
}
