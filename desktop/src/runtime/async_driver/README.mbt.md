# shiguri-01/desktop/runtime/async_driver

Native-only adapter between desktop IPC handlers and MoonBit async execution.

This is a support package for `shiguri-01/desktop/runtime`.
Application code normally should not import it directly.
Its purpose is to keep the runtime's direct dependency on `moonbitlang/async` behind a small boundary.

## APIs

- `run_response` executes an async IPC handler to completion and returns a typed `IpcResponse[T]`.
- `run_unit` executes async setup code and reports whether it completed, raised, or failed to produce a result.

`IpcRouter::handle` uses this package internally so host handlers can call MoonBit async APIs.

## Current Behavior

Async work is driven to completion from the webview callback path.
This is simple and predictable, but long-running handlers still occupy that callback until they finish.

If MoonBit async gains a public external event-loop hook, this package is the intended replacement point.
Keep async-driver details out of application code and out of the public runtime API where possible.
