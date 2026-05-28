# shiguri-01/desktop/shell

Low-level native shell integrations for `shiguri-01/desktop/runtime`.

Most application code should use the higher-level `Window` methods from `shiguri-01/desktop/runtime`.
Use this package directly only when you already have a `shiguri-01/webview.NativeWindow`
and need to call the native dialog layer without the full desktop runtime.

## APIs

- `show_message_dialog` displays a native modal message dialog.
- `open_file_dialog` selects one existing file.
- `open_files_dialog` selects multiple existing files.
- `save_file_dialog` returns a destination path for saving.
- `open_folder_dialog` selects a directory.

Dialog configuration uses portable enums:

- `MessageDialogKind`: `Info`, `Warning`, `Error`, or `Question`.
- `MessageDialogButtons`: `Ok`, `OkCancel`, `YesNo`, or `YesNoCancel`.
- `MessageDialogResult`: `Ok`, `Cancel`, `Yes`, or `No`.

File dialogs use `FileFilter` values.
Extensions should not include a leading dot.

```mbt check
///|
/// Call this from code that already has a native webview window handle.
pub fn select_image(
  native_window : @webview.NativeWindow,
) -> String? raise @shell.ShellError {
  @shell.open_file_dialog(native_window, filters=[
    { name: "Images", extensions: ["png", "jpg", "jpeg"] },
  ])
}
```

## Platform Notes

On Windows, message dialogs use `TaskDialogIndirect` when available
and fall back to `MessageBoxW` when the task dialog entry point cannot be loaded.
File, save, and folder dialogs use Native File Dialog Extended and the modern `IFileDialog` API.

Unsupported platforms raise `ShellError::UnsupportedPlatform`.

## License and Credits

License: Apache-2.0.

Native credits: Native File Dialog Extended (Zlib).
Vendored files and `NFD_LICENSE.txt` are included in this package.
