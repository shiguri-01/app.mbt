set shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

default:
    @just --list

# Check every workspace member on its supported targets.
check:
    moon check --target all

# Run every workspace member's native tests.
test:
    cmd.exe /C tools\msvc-native.cmd moon test --target native -v

# Run the basic webview example.
run-webview-example:
    cmd.exe /C tools\msvc-native.cmd moon run webview/src/examples/basic --target native

# Run the desktop framework counter example.
run-counter-example:
    cmd.exe /C tools\msvc-native.cmd moon run examples/src/counter/host --target native

# Refresh generated package interfaces.
info:
    moon info --target all

# Format MoonBit package files and sources.
fmt:
    moon fmt

# Fast local verification that does not open a GUI window.
verify: check test
