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
