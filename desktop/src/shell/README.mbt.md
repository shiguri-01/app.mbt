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
