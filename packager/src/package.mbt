///|
fn run(command : String) -> Unit raise PackError {
  println("> \{command}")
  require_status(command, ffi_run_command(@utf8.encode(command)))
}

///|
fn make_dirs(path : String) -> Unit raise PackError {
  require_status("create directory \{path}", ffi_make_dirs(@utf8.encode(path)))
}

///|
fn copy_file(from : String, to : String) -> Unit raise PackError {
  require_status(
    "copy \{from} to \{to}",
    ffi_copy_file(@utf8.encode(from), @utf8.encode(to)),
  )
}

///|
fn copy_tree(from : String, to : String) -> Unit raise PackError {
  require_status(
    "copy \{from} to \{to}",
    ffi_copy_tree(@utf8.encode(from), @utf8.encode(to)),
  )
}

///|
fn frontend_js_path(manifest : AppManifest) -> String {
  build_artifact_path("js", manifest.module_name, manifest.frontend, ".js")
}

///|
fn host_exe_path(manifest : AppManifest) -> String {
  build_artifact_path("native", manifest.module_name, manifest.host, ".exe")
}

///|
fn package_app(manifest_path : String) -> Unit raise PackError {
  let manifest = read_manifest(manifest_path)
  println("Packaging \{manifest.name} \{manifest.version}")
  run("moon build \{manifest.frontend} --target js")
  run(
    "cmd.exe /C tools\\msvc-native.cmd moon build \{manifest.host} --target native",
  )
  let resources = join_path(manifest.dist, "resources")
  make_dirs(manifest.dist)
  make_dirs(resources)
  copy_tree(manifest.static_dir, resources)
  copy_file(frontend_js_path(manifest), join_path(resources, "frontend.js"))
  copy_file(
    host_exe_path(manifest),
    join_path(manifest.dist, manifest.executable),
  )
  copy_file(manifest_path, join_path(manifest.dist, "desktop.app.json"))
  println("Wrote portable bundle: \{manifest.dist}")
}
