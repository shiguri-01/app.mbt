# shiguri-01/desktop/frontend

JS-target client for calling a `shiguri-01/desktop/runtime` host from frontend MoonBit code.

Use this package from frontend packages compiled to JavaScript.
It is UI-library agnostic: DOM code, Rabbita, Luna, or another frontend layer can decide when to call the client.

## Bridge Contract

`Client` sends typed `RequestFrame` values through a JavaScript bridge function named `globalThis.moonbitDesktop`.
The runtime installs that bridge when a host window mounts an IPC router.

The bridge returns a JavaScript `Promise`.
`Client::request` waits for that promise in JS async code.
`Client::request_callback` uses callbacks for UI runtimes that own their own scheduler.

## Main APIs

- `Client::Client` creates a frontend IPC client for the default bridge.
- `Client::request` calls an `IpcEndpoint[T, R]` and returns `IpcResponse[R]`.
- `Client::request_callback` calls an endpoint and reports the response through a callback.
- `Client::listen` installs a typed host-to-frontend event listener for an `IpcEvent[E]`.

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
/// Real apps update frontend state from the typed response.
pub fn request_increment(client : @frontend.Client) -> Unit {
  client.request_callback(increment_endpoint, { amount: 1 }, response => {
    match response {
      Ok(_) => ()
      Err(_) => ()
    }
  })
}
```

## Error Handling

Transport failures and missing bridge functions are returned as `IpcResponse::Err`.
Handler failures, decode failures, and payload-size errors are produced by the native runtime
and use the same `IpcError` type as the shared protocol package.

For Rabbita applications, use `shiguri-01/desktop/frontend/rabbita` instead of calling `request_callback` directly.
