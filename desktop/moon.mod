name = "shiguri-01/desktop"

version = "0.1.0"

readme = "README.mbt.md"

repository = ""

license = "Apache-2.0"

keywords = [ ]

description = "Typed MoonBit desktop application framework"

preferred_target = "native"

supported_targets = "+js+native"

import {
  "moonbit-community/rabbita@0.12.2",
  "moonbitlang/async@0.18.1",
  "shiguri-01/webview@0.1.1",
}

options(
  source: "src",
)
