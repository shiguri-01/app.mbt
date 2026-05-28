# shiguri-01/desktop-file-dialog-example

Runnable application module demonstrating native file and folder dialogs through `shiguri-01/desktop`.

This example is not a reusable library.
It shows how frontend commands can ask the native host to open platform dialogs
and return selected paths or cancellation.

## What It Demonstrates

- `Window::open_file_dialog` for selecting one existing file.
- `Window::open_files_dialog` for selecting multiple existing files.
- `Window::save_file_dialog` for choosing a destination path.
- `Window::open_folder_dialog` for selecting a folder.
- `FileFilter` values for native open/save dialog filters.

## Module Layout

- `src/shared`: file dialog result payloads and endpoint names.
- `src/host`: native file dialog calls, filters, and the save-file write flow.
- `src/frontend`: minimal DOM UI and frontend IPC calls.

## Implemented Behavior

- Open one file.
- Open multiple files.
- Select a folder.
- Choose a save destination and write a small text file.

`Window::save_file_dialog` only returns a destination path.
The host package writes a file after the dialog returns so the save flow is visible end to end.

## Run

```powershell
just run-file-dialogs-example
```

## License and Credits

License: Apache-2.0.

Native credits: `webview/webview` (MIT), Microsoft WebView2 SDK header (Microsoft license and notices),
Native File Dialog Extended (Zlib).
