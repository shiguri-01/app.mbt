///|
pub(all) enum CounterCommand {
  Increment(amount~ : Int)
  Reset
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) enum WindowCommand {
  SetTitle(String)
  Close
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) enum CounterAppCommand {
  Counter(CounterCommand)
  Window(WindowCommand)
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) enum CounterEvent {
  CountChanged(Int)
  WindowTitleChanged(String)
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn command_id(command : CounterAppCommand) -> @ipc.CommandId {
  match command {
    Counter(Increment(_)) => @ipc.CommandId("counter.increment")
    Counter(Reset) => @ipc.CommandId("counter.reset")
    Window(SetTitle(_)) => @ipc.CommandId("window.set_title")
    Window(Close) => @ipc.CommandId("window.close")
  }
}
