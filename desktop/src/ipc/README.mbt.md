# desktop/ipc

Target-agnostic typed IPC protocol helpers.

Applications define their own command and event enums, derive JSON traits, and
send them through `Envelope`.

```mbt nocheck
///|
pub(all) enum AppCommand {
  Counter(CounterCommand)
  Window(WindowCommand)
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) enum CounterCommand {
  Increment(amount~ : Int)
  Reset
} derive(Debug, Eq, ToJson, FromJson)
```

Nested enums are the preferred way to group commands. They keep routing typed
without falling back to stringly-typed command names.

`default_bridge_name()` returns the framework's conventional JavaScript bridge
name, `moonbitDesktop`. Runtime and frontend packages use it for their
`*_default` helpers.

## Transport shape

`Envelope` is the transport-level JSON value. Its `payload` contains the
application command or event:

```mbt nocheck
///|
let command = AppCommand::Counter(CounterCommand::Increment(amount=1))

///|
let envelope = @ipc.Envelope(command, id="req-1")

///|
let decoded : AppCommand = envelope.decode()
```

`Response[T]` is used for request replies:

```mbt nocheck
///|
let response : Response[CounterEvent] = Ok(CounterEvent::CountChanged(1))
```

Errors that cross the IPC boundary are represented as `IpcError`. Transport
failures stay distinct from application handler failures.
