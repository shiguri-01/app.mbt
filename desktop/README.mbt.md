# desktop

Typed MoonBit desktop application framework.

The framework keeps the native host, frontend helper, and shared IPC protocol
as separate packages:

- `ipc`: target-agnostic JSON envelopes for typed commands and events.
- `runtime`: native host runtime backed by `shiguri-01/webview`.
- `frontend`: JS-target helper package that does not depend on a UI library.

Applications define their own nested enum protocol and derive `ToJson` /
`FromJson` for it.

On Windows, native builds use `moonbitlang/async` and the bundled webview C++
stub. Run native test/build/run commands from a Visual Studio C++ environment
or through the repository `just` tasks, which call `vcvarsall.bat x64`.
