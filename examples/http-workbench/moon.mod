name = "shiguri-01/desktop-http-workbench-example"

version = "0.1.0"

import {
  "moonbitlang/async@0.18.1",
  "moonbit-community/rabbita@0.12.2",
  "shiguri-01/desktop@0.1.0",
}

readme = "README.mbt.md"

repository = ""

license = "Apache-2.0"

keywords = [ "desktop", "http", "rabbita", "vite" ]

description = "HTTP/API Workbench desktop example for shiguri-01/desktop"

preferred_target = "native"

supported_targets = "js+native"

options(
  source: "src",
)
