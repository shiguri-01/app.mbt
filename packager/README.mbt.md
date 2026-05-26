# app-packager

MoonBit-native packager for `shiguri-01/desktop` applications.

```powershell
cmd.exe /C tools\msvc-native.cmd moon run packager/src --target native -- package examples/counter/desktop.app.json
```

The first backend creates a portable Windows directory with the host executable
and a `resources` directory next to it.
