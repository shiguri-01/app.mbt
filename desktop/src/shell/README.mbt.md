# desktop/shell

Native desktop shell helpers used by `desktop/runtime`.

This package owns platform-specific integrations such as message dialogs. It
accepts opaque native window handles from `shiguri-01/webview`, but callers
should normally use the higher-level `Window` methods from `desktop/runtime`.

```mbt nocheck
window.show_message_dialog(
  "The export has finished.",
  title="Export",
  kind=Info,
  buttons=Ok,
)
```

The public API uses small enums for dialog kinds, button sets, and results so
applications can stay portable across Windows, macOS, and Linux backends.

On Windows, message dialogs use `TaskDialogIndirect` when available. If the
common-controls task dialog entry point cannot be loaded, the backend falls back
to `MessageBoxW` rather than failing an otherwise valid dialog request.

File, save, and folder dialogs are exposed as portable functions returning
`None` when the user cancels. On Windows, these dialogs are backed by Native
File Dialog Extended (NFDe), which uses the modern `IFileDialog` API.

```mbt nocheck
///|
let image = window.open_file_dialog(filters=[
  { name: "Images", extensions: ["png", "jpg", "jpeg"] },
])
```

## Third-Party Credits

The Windows file dialog backend vendors code from
[Native File Dialog Extended](https://github.com/btzy/nativefiledialog-extended):

- `nfd.h`
- `nfd_win.cpp`

NFDe is distributed under the Zlib License. The vendored files retain their
upstream attribution, and the full license text is included in
`NFD_LICENSE.txt`.
