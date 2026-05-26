# Desktop File Dialog Example

Native file dialog example for `shiguri-01/desktop`.

Build the frontend and run the host:

```powershell
just run-file-dialogs-example
```

The app demonstrates:

- `Window::open_file_dialog`
- `Window::open_files_dialog`
- `Window::save_file_dialog`
- `Window::open_folder_dialog`

`Window::save_file_dialog` only returns a destination path. This example writes
a small text file after the dialog returns so the save flow is visible end to
end.
