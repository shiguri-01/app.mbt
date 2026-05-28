set shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

default:
    @just --list

# Core workspace tasks.

# Check every workspace member on every supported target.
check:
    moon check --target all

# Run every workspace member's tests on every supported target.
test:
    cmd.exe /C tools\msvc-native.cmd moon test --target all -v

# Format all MoonBit package files and sources in the workspace.
fmt:
    moon fmt

# Check formatting without changing source files.
fmt-check:
    moon fmt --check

# Refresh generated package interfaces for every supported target.
info:
    moon info --target all

# Run the full non-GUI workspace verification suite.
verify: check test fmt-check

# Example tasks.

prepare-example-http-workbench:
    npm.cmd --prefix examples/http-workbench install

prepare-example-markdown-notes:
    npm.cmd --prefix examples/markdown-notes install

build-example-webview:
    cmd.exe /C tools\msvc-native.cmd moon build webview/src/examples/basic --target native

build-example-counter: _build-example-counter-frontend
    cmd.exe /C tools\msvc-native.cmd moon build examples/counter/src/host --target native

build-example-dialogs: _build-example-dialogs-frontend
    cmd.exe /C tools\msvc-native.cmd moon build examples/dialogs/src/host --target native

build-example-file-dialogs: _build-example-file-dialogs-frontend
    cmd.exe /C tools\msvc-native.cmd moon build examples/file-dialogs/src/host --target native

build-example-http-workbench: _build-example-http-workbench-frontend
    cmd.exe /C tools\msvc-native.cmd moon build examples/http-workbench/src/host --target native

build-example-markdown-notes: _build-example-markdown-notes-frontend
    cmd.exe /C tools\msvc-native.cmd moon build examples/markdown-notes/src/host --target native

# Run examples. These recipes open GUI windows.
run-example-webview:
    cmd.exe /C tools\msvc-native.cmd moon run webview/src/examples/basic --target native

run-example-counter: _build-example-counter-frontend
    cmd.exe /C tools\msvc-native.cmd moon run examples/counter/src/host --target native

run-example-dialogs: _build-example-dialogs-frontend
    cmd.exe /C tools\msvc-native.cmd moon run examples/dialogs/src/host --target native

run-example-file-dialogs: _build-example-file-dialogs-frontend
    cmd.exe /C tools\msvc-native.cmd moon run examples/file-dialogs/src/host --target native

run-example-http-workbench: _build-example-http-workbench-frontend
    cmd.exe /C tools\msvc-native.cmd moon run examples/http-workbench/src/host --target native

run-example-markdown-notes: _build-example-markdown-notes-frontend
    cmd.exe /C tools\msvc-native.cmd moon run examples/markdown-notes/src/host --target native

package-example-counter:
    cmd.exe /C tools\msvc-native.cmd moon run packager/src --target native -- package examples/counter/desktop.app.json

package-example-http-workbench: _build-example-http-workbench-frontend
    cmd.exe /C tools\msvc-native.cmd moon run packager/src --target native -- package examples/http-workbench/desktop.app.json

package-example-markdown-notes: _build-example-markdown-notes-frontend
    cmd.exe /C tools\msvc-native.cmd moon run packager/src --target native -- package examples/markdown-notes/desktop.app.json

_build-example-counter-frontend:
    moon build examples/counter/src/frontend --target js

_build-example-dialogs-frontend:
    moon build examples/dialogs/src/frontend --target js

_build-example-file-dialogs-frontend:
    moon build examples/file-dialogs/src/frontend --target js

_build-example-http-workbench-frontend:
    npm.cmd --prefix examples/http-workbench run build

_build-example-markdown-notes-frontend:
    npm.cmd --prefix examples/markdown-notes run build
