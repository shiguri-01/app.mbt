# desktop/frontend

JS-target helpers for calling a desktop runtime bridge from frontend code.

`Client` builds typed IPC envelopes and sends them through a JavaScript bridge
function such as `globalThis.moonbitDesktop`. It is UI-library agnostic; DOM,
Rabbita, Luna, or another layer can decide when to call it.

Use `emit_default` for one-way events and `request_with_callback_default` or
`request_async_default` when the host returns a typed `Response[T]`.

```mbt nocheck
///|
let client = @frontend.Client()

///|
let client = client.request_with_callback_default(command, response => {
  match response {
    Ok(event) => handle_event(event)
    Err(err) => handle_error(err)
  }
})
```
