name = "shiguri-01/webview"

version = "0.1.0"

readme = "README.mbt.md"

repository = "https://github.com/shiguri-01/app.mbt"

license = "Apache-2.0"

keywords = [ "webview" ]

description = "Low-level MoonBit bindings to webview/webview"

preferred_target = "native"

supported_targets = "+native"

options(
  source: "src",
  exclude: [ "src/examples" ],
)
