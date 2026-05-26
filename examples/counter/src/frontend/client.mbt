///|
pub fn increment_message(amount : Int) -> String {
  let client = @desktop.Client()
  let command = @shared.CounterAppCommand::Counter(Increment(amount~))
  client.event(command)
}

///|
pub fn set_title_message(title : String) -> String {
  let client = @desktop.Client()
  let command = @shared.CounterAppCommand::Window(SetTitle(title))
  client.event(command)
}
