# desktop

Typed MoonBit desktop application framework.

The framework keeps the native host, frontend helper, and shared IPC protocol
as separate packages:

- `ipc`: target-agnostic JSON envelopes for typed commands and events.
- `runtime`: native host runtime backed by `shiguri-01/webview`.
- `frontend`: JS-target helper package that does not depend on a UI library.

Applications define their own nested enum protocol and derive `ToJson` /
`FromJson` for it.

Package-level README files contain the API-oriented details:

- `src/ipc/README.mbt.md`: typed envelopes, requests, responses, and errors.
- `src/runtime/README.mbt.md`: native window runtime and async host handlers.

## Async IPC direction

The runtime uses async host handlers today. Non-blocking async IPC still needs
a public external-event-loop hook from `moonbitlang/async`. The experiment,
current adapter, and proposed integration contract are documented in
`../docs/async-integration.md`.

On Windows, native builds use `moonbitlang/async` and the bundled webview C++
stub. Run native test/build/run commands from a Visual Studio C++ environment
or through the repository `just` tasks, which call `vcvarsall.bat x64`.
