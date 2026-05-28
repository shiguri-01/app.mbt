# shiguri-01/desktop/ipc

Target-agnostic protocol primitives for typed desktop IPC.

Use this package from shared protocol code.
It does not talk to JavaScript or native webview APIs by itself.
It defines the endpoint descriptors and JSON frames
that `shiguri-01/desktop/runtime` and `shiguri-01/desktop/frontend` both understand.

## Core Types

- `IpcEndpoint[T, R]` names a request/reply command and binds one request type `T` to one reply type `R`.
- `IpcEvent[E]` names a host-to-frontend event and binds it to one payload type `E`.
- `RequestFrame` wraps an application payload before it crosses the bridge.
- `ResponseFrame[T]` wraps `IpcResponse[T]` after a host handler completes.
- `IpcError` represents decode, encode, handler, transport, version, and payload-size failures.

## Defining a Protocol

Define endpoints and payload types in an application shared package,
then import that package from both host and frontend code.

```mbt check
///|
struct IncrementRequest {
  amount : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
struct CountChangedReply {
  count : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Host code registers this endpoint with `IpcRouter::handle`.
/// Frontend code calls the same endpoint with `Client::request`.
pub let increment_endpoint : @ipc.IpcEndpoint[
  IncrementRequest,
  CountChangedReply,
] = @ipc.IpcEndpoint::named("counter.increment")
```

The command id string is the wire-level capability name.
Keep it stable when a frontend and host may be built or updated separately.

## Encoding Boundary

Most application code should use `IpcRouter::handle` and `Client::request` instead of calling frame helpers directly.
Use `RequestFrame::stringify`, `parse_request_frame`, `response_ok`, and `parse_response_frame`
when writing tests, custom bridge code, or tooling around the IPC protocol.
