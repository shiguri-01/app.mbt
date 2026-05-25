name = "shiguri-01/desktop-counter-example"

version = "0.1.0"

readme = "README.mbt.md"

repository = ""

license = "Apache-2.0"

keywords = [ ]

description = "Counter example for shiguri-01/desktop"

preferred_target = "native"

supported_targets = "+js+native"

import {
  "moonbitlang/async@0.18.1",
  "shiguri-01/desktop@0.1.0",
}

options(
  source: "src",
)
