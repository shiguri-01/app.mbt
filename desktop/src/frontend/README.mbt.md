# desktop/frontend

JS-target helpers for calling a desktop runtime bridge from frontend code.

`Client` builds typed `RequestFrame` values and sends them through a JavaScript
bridge function such as `globalThis.moonbitDesktop`. It is UI-library agnostic;
DOM, Rabbita, Luna, or another layer can decide when to call it.

Use `request` for async frontend code. The endpoint value should come from the
application shared package, so the command and reply types are chosen by the
protocol rather than by each call site.

```mbt nocheck
///|
let client = @frontend.Client()

///|
let response = client.request(@shared.increment_endpoint, @shared.IncrementRequest::{
  amount: 1,
})
```

Host-to-frontend events use `listen`, which installs a typed listener from an
`IpcEvent[E]` descriptor.
