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

# Build the MoonBit JS frontend for the counter desktop example.
build-counter-example-frontend:
    moon build examples/counter/src/frontend --target js

# Run the desktop framework counter example.
run-counter-example: build-counter-example-frontend
    cmd.exe /C tools\msvc-native.cmd moon run examples/counter/src/host --target native

# Package the counter example as a portable Windows app directory.
package-counter-example:
    cmd.exe /C tools\msvc-native.cmd moon run packager/src --target native -- package examples/counter/desktop.app.json

# Install frontend dependencies for the HTTP/API Workbench example.
install-http-workbench-frontend:
    npm.cmd --prefix examples/http-workbench install

# Build the Rabbita + Vite frontend for the HTTP/API Workbench example.
build-http-workbench-frontend:
    npm.cmd --prefix examples/http-workbench run build

# Run the desktop framework HTTP/API Workbench example.
run-http-workbench-example: build-http-workbench-frontend
    cmd.exe /C tools\msvc-native.cmd moon run examples/http-workbench/src/host --target native

# Package the HTTP/API Workbench example as a portable Windows app directory.
package-http-workbench-example: build-http-workbench-frontend
    cmd.exe /C tools\msvc-native.cmd moon run packager/src --target native -- package examples/http-workbench/desktop.app.json

# Build the MoonBit JS frontend for the dialogs desktop example.
build-dialogs-example-frontend:
    moon build examples/dialogs/src/frontend --target js

# Run the native message dialog example.
run-dialogs-example: build-dialogs-example-frontend
    cmd.exe /C tools\msvc-native.cmd moon run examples/dialogs/src/host --target native

# Build the MoonBit JS frontend for the file dialogs desktop example.
build-file-dialogs-example-frontend:
    moon build examples/file-dialogs/src/frontend --target js

# Run the native file dialog example.
run-file-dialogs-example: build-file-dialogs-example-frontend
    cmd.exe /C tools\msvc-native.cmd moon run examples/file-dialogs/src/host --target native

# Refresh generated package interfaces.
info:
    moon info --target all

# Format MoonBit package files and sources.
fmt:
    moon fmt

# Fast local verification that does not open a GUI window.
verify: check test
