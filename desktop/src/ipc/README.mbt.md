# desktop/ipc

Target-agnostic IPC transport helpers.

Applications define shared command and reply enums in their own shared package
and derive or implement `ToJson` / `FromJson` for those protocol types. The
framework owns the outer wire format through `RequestFrame`,
`ResponseFrame[T]`, and `IpcResponse[T]`.

```mbt nocheck
///|
pub(all) enum AppCommand {
  Counter(CounterCommand)
  Window(WindowCommand)
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) enum AppReply {
  CountChanged(Int)
  WindowTitleChanged(String)
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn command_id(command : AppCommand) -> @ipc.CommandId {
  match command {
    Counter(Increment(_)) => @ipc.CommandId("counter.increment")
    Counter(Reset) => @ipc.CommandId("counter.reset")
    Window(SetTitle(_)) => @ipc.CommandId("window.set_title")
    Window(Close) => @ipc.CommandId("window.close")
  }
}
```

`IpcPolicy[T]` stores a plain `classify : (T) -> CommandId` function and an
optional allowlist. Runtime code applies the policy after decoding the command
and before running the async handler.

`default_bridge_name()` returns `moonbitDesktop` for frontend-to-host requests.
`default_event_name()` returns `moonbitDesktopEvent` for host-to-frontend
events.
