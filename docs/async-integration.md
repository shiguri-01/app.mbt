# Async IPC integration

This document records the current design boundary for async desktop IPC.

## Current behavior

The runtime exposes async host handlers through `Window::handle`. The handler
participates in typed IPC:

- frontend code sends an `Envelope` JSON string through a webview binding
- the native runtime decodes the envelope payload as an application command
- the host handler returns an application response value
- the runtime serializes `Response[R]` and resolves the webview promise

The current async driver runs each handler to completion before returning from
the webview callback. This is not the final non-blocking event-loop integration,
but it gives applications async typed handlers now and keeps the workaround
inside `desktop/runtime`.

## What the experiment showed

An experimental `Window::handle_async` was tried with `moonbitlang/async` by
spawning the handler from the webview callback.

The result was:

- a callback that only spawned an async task did not complete while
  `webview.run()` was blocking
- manually rescheduling ready async coroutines was enough for an immediately
  ready handler to complete
- handlers that used `@async.sleep` also needed the async event loop to be
  polled after the timer was registered

So the bridge itself is not the problem. The currently implemented bridge uses
a runtime-owned async driver per callback. This makes async application
handlers work now, but the UI callback is still occupied until the handler
finishes. The missing piece for non-blocking async IPC is an official way for
an external native event loop to drive the MoonBit async scheduler and its
timer or IO polling.

## Required async runtime hook

The desktop runtime should not patch or depend on `moonbitlang/async/internal`.
It needs a public integration surface in `moonbitlang/async`, roughly:

```mbt nocheck
pub fn reschedule_ready() -> Unit

pub fn poll_once(timeout_ms? : Int = 0) -> Unit

pub fn has_pending_tasks() -> Bool

pub fn next_timer_timeout_ms() -> Int?
```

The exact names are not important. The important contract is:

- host code can ask the async runtime to run ready continuations
- host code can poll timers and IO without taking over the process
- host code can know whether another tick should be scheduled
- no application code imports async internals

## Intended public API

The current public API already uses the intended async handler shape:

```mbt nocheck
pub fn run(
  title~ : String,
  width? : Int = 800,
  height? : Int = 600,
  debug? : Bool = false,
  load? : Load,
  on_ready~ : async (Window) -> Unit,
) -> Unit raise DesktopError

pub fn[T : FromJson, R : ToJson] Window::handle(
  self : Window,
  name : String,
  handler : async (T) -> R,
) -> Unit raise DesktopError
```

`Window::handle_sync` remains as an explicit escape hatch for handlers that
must complete without entering the async driver.

## Runtime algorithm

The current runtime-owned algorithm is:

1. Register a webview binding for `name`.
2. When the binding fires, decode the request envelope.
3. Run the typed async handler through the runtime-owned async driver.
4. When the task completes, call `webview_return(id, status, response_json)`.

The future non-blocking runtime-owned algorithm should replace step 3 with:

1. Spawn a request task.
2. Tick the async runtime enough to run ready work.
3. If timers or IO are pending, schedule another tick from the webview/native
   side instead of blocking the UI thread.
4. When the task completes, call `webview_return(id, status, response_json)`.

In that future version, the webview callback should return quickly. In the
current adapter version, long handlers still occupy the callback path.

## Error model

The frontend should always receive a typed `Response[R]` when the native bridge
accepted the request:

- decode failures become `Err(DecodeError(...))`
- application failures become `Err(HandlerError(...))`
- transport-level failures become `Err(TransportClosed(...))` on the frontend

This keeps transport errors distinct from application errors and leaves room
for request cancellation or timeout variants later.

## Open decisions

- Whether cancellation is per request id or exposed only as frontend timeout.
- Whether long-running CPU work should be a separate worker API instead of
  sharing the async handler path.
- How asset loading should integrate with dev servers and production bundles
  while keeping the framework independent from any specific frontend bundler.
