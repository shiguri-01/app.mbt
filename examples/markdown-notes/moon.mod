name = "shiguri-01/desktop-markdown-notes-example"

version = "0.1.0"

readme = "README.mbt.md"

repository = ""

license = "Apache-2.0"

keywords = [ "desktop", "markdown", "luna", "vite" ]

description = "Markdown Notes desktop example for shiguri-01/desktop"

preferred_target = "native"

supported_targets = "js+native"

import {
  "moonbitlang/async@0.18.1",
  "mizchi/js@0.10.16",
  "mizchi/luna@0.23.0",
  "mizchi/markdown@0.4.7",
  "mizchi/signals@0.6.4",
  "shiguri-01/desktop@0.1.0",
}

options(
  source: "src",
)
