default:
    @just --list

# Check every workspace member for the native target.
check:
    moon check --target native

# Run every workspace member's native tests.
test:
    moon test --target native -v

# Run the basic webview example.
run-webview-example:
    moon run webview/src/examples/basic --target native

# Refresh generated package interfaces.
info:
    moon info --target native

# Format MoonBit package files and sources.
fmt:
    moon fmt

# Fast local verification that does not open a GUI window.
verify: check test
