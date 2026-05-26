# desktop/runtime/async_driver

Native-only adapter between desktop IPC handlers and MoonBit async execution.

This package intentionally owns the direct dependency on `moonbitlang/async`.
The public `desktop/runtime` package should expose handler APIs and error
mapping, while this package stays responsible for how async work is driven.

## Current behavior

`run_response` executes one async IPC handler to completion and returns a typed
`Response[T]`. `run_unit` does the same for setup code and reports whether the
async entry point completed, raised, or failed to produce a result.

This means `Window::handle` can use MoonBit async APIs from handlers today, but
the webview binding callback remains occupied until the handler completes.
Long-running work that must finish after the callback returns should use
`Window::handle_deferred` and `ResponseSender` instead.

## Direction

Keep this package as the boundary for async runtime integration. If MoonBit
async gains a public external event-loop hook, replace this package's driver so
`Window::handle` can schedule request tasks without blocking the webview
callback path. Do not import async internals from application code or from the
public runtime API surface.
