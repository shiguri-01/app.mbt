# shiguri-01/desktop/frontend/rabbita

Rabbita `Cmd` adapter for `shiguri-01/desktop/frontend`.

Use this package from Rabbita frontend packages that need to call typed desktop IPC endpoints.
It wraps `Client::request_callback` so the JavaScript promise returned by the desktop bridge
re-enters Rabbita through its scheduler.

## API

`request_cmd` creates a Rabbita command from:

- a `Client`;
- an `IpcEndpoint[T, R]`;
- a request body `T`;
- an `on_response` function that turns `IpcResponse[R]` into the next Rabbita command.

```mbt check
///|
struct IncrementRequest {
  amount : Int
} derive(ToJson, FromJson)

///|
struct CountChangedReply {
  count : Int
} derive(ToJson, FromJson)

///|
let increment_endpoint : @ipc.IpcEndpoint[IncrementRequest, CountChangedReply] = @ipc.IpcEndpoint::named(
  "counter.increment",
)

///|
/// Real apps usually map the response to a message command here.
pub fn increment_cmd(client : @frontend.Client) -> @cmd.Cmd {
  request_cmd(client~, endpoint=increment_endpoint, body={ amount: 1 }, on_response=response => {
    match response {
      _ => @cmd.none
    }
  })
}
```

Use `shiguri-01/desktop/frontend` directly when the frontend is not a Rabbita application.
