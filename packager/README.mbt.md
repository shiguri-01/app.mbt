# desktop-packager

MoonBit-native packager for `shiguri-01/desktop` applications.

```powershell
cmd.exe /C tools\msvc-native.cmd moon run packager/src --target native -- package examples/counter/desktop.app.json
```

The first backend creates a portable Windows directory with the host executable
and a `resources` directory next to it.

Set `bundle` in the manifest:

- `"dir"` keeps the executable and `resources/` side by side.
- `"single-exe"` appends resources to the executable and writes only the `.exe`
  into `dist`.

Packaged Windows executables default to the GUI subsystem so launching them
does not open a terminal. Set `"windows_subsystem": "console"` in the manifest
when a console is desired.
