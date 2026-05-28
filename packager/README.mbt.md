# shiguri-01/desktop-packager

Native packaging command for `shiguri-01/desktop` applications.

Use this module from a repository tool workflow, not from application runtime code.
It reads a `desktop.app.json` manifest, builds the frontend and native host packages,
copies resources, and writes a Windows desktop application bundle.

## What It Produces

The manifest `bundle` field chooses the output shape:

- `"dir"` writes a portable directory with the host executable and a `resources/` directory next to it.
- `"single-exe"` appends resources to the executable and writes one `.exe` into `dist`.

Packaged Windows executables default to the GUI subsystem so launching them does not open a terminal.
Set `"windows_subsystem": "console"` in the manifest when a console is desired.

## Command

```sh
moon run src --target native -- package path/to/desktop.app.json
```

Run the command from the packager module.
On Windows, use a Visual Studio C++ environment.

## Manifest Role

`desktop.app.json` is the boundary between an application module and the packager.
It tells the packager which host package to build, which frontend build command to run,
which generated assets to include, and which bundle shape to write.

## Current Target

The current backend targets Windows native builds and expects a Visual Studio C++ environment.
Cross-platform packaging is outside the current module surface.

## License and Credits

License: Apache-2.0.

Native credits: none vendored in this module.
Packaged applications may include credits from `desktop` and `webview`.
