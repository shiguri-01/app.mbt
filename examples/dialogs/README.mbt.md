# shiguri-01/desktop-dialog-example

Runnable application module demonstrating native message dialogs through `shiguri-01/desktop`.

This example is not a reusable library.
It focuses on frontend-triggered host commands that open native dialogs and return portable button results.

## What It Demonstrates

- Calling `Window::show_message_dialog` from a native host IPC handler.
- Using `MessageDialogKind`, `MessageDialogButtons`, and `MessageDialogResult` as portable dialog types.
- Returning native dialog results through typed request/reply IPC.
- Keeping the dialog protocol in a shared package used by host and frontend code.

## Module Layout

- `src/shared`: dialog choices, result payloads, and endpoint names.
- `src/host`: native dialog calls and IPC handler registration.
- `src/frontend`: minimal DOM UI and frontend IPC calls.

## Implemented Behavior

- Info dialog command.
- Warning dialog command.
- Question dialog command that reports the selected button.

## Run

```powershell
just run-dialogs-example
```

## License and Credits

License: Apache-2.0.

Native credits: `webview/webview` (MIT), Microsoft WebView2 SDK header (Microsoft license and notices),
Native File Dialog Extended (Zlib).
