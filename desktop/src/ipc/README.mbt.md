# desktop/ipc

Target-agnostic IPC transport helpers.

Applications define shared command endpoint values and request/reply types in
their own shared package, then derive or implement `ToJson` / `FromJson` for
those protocol types. The framework owns the outer wire format through
`RequestFrame`, `ResponseFrame[T]`, and `IpcResponse[T]`.

```mbt nocheck
///|
pub(all) struct IncrementRequest {
  amount : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct CountChangedReply {
  count : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub let increment_endpoint : @ipc.IpcEndpoint[
  IncrementRequest,
  CountChangedReply,
] = @ipc.IpcEndpoint::named("counter.increment")
```

`IpcEndpoint[T, R]` is a typed command/capability descriptor. It owns the
command id string and binds one request type to one response type, so frontend
and runtime code use the same `T` and `R` pair instead of each side choosing
types independently.

`IpcPolicy[T]` remains available for lower-level enum-aggregated bridges. It
stores a plain `classify : (T) -> CommandId` function and an optional allowlist.

`default_event_name()` returns `moonbitDesktopEvent` for host-to-frontend
events.
