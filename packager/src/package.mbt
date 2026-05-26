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
fn remove_path(path : String) -> Unit raise PackError {
  require_status("remove \{path}", ffi_remove_path(@utf8.encode(path)))
}

///|
fn embed_resources(
  exe : String,
  static_dir : String,
  frontend_js : String,
) -> Unit raise PackError {
  require_status(
    "embed resources into \{exe}",
    ffi_embed_resources(
      @utf8.encode(exe),
      @utf8.encode(static_dir),
      @utf8.encode(frontend_js),
    ),
  )
}

///|
fn set_windows_subsystem(
  exe : String,
  subsystem : String,
) -> Unit raise PackError {
  require_status(
    "set Windows subsystem for \{exe}",
    ffi_set_windows_subsystem(@utf8.encode(exe), @utf8.encode(subsystem)),
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
fn package_dir(
  manifest : AppManifest,
  manifest_path : String,
) -> Unit raise PackError {
  let resources = join_path(manifest.dist, "resources")
  let exe = join_path(manifest.dist, manifest.executable)
  make_dirs(manifest.dist)
  remove_path(resources)
  make_dirs(resources)
  copy_tree(manifest.static_dir, resources)
  copy_file(frontend_js_path(manifest), join_path(resources, "frontend.js"))
  copy_file(host_exe_path(manifest), exe)
  set_windows_subsystem(exe, manifest.windows_subsystem_kind())
  copy_file(manifest_path, join_path(manifest.dist, "desktop.app.json"))
  println("Wrote portable bundle: \{manifest.dist}")
}

///|
fn package_single_exe(manifest : AppManifest) -> Unit raise PackError {
  make_dirs(manifest.dist)
  remove_path(join_path(manifest.dist, "resources"))
  remove_path(join_path(manifest.dist, "desktop.app.json"))
  let exe = join_path(manifest.dist, manifest.executable)
  copy_file(host_exe_path(manifest), exe)
  set_windows_subsystem(exe, manifest.windows_subsystem_kind())
  embed_resources(exe, manifest.static_dir, frontend_js_path(manifest))
  println("Wrote single executable: \{exe}")
}

///|
fn package_app(manifest_path : String) -> Unit raise PackError {
  let manifest = read_manifest(manifest_path)
  println("Packaging \{manifest.name} \{manifest.version}")
  run("moon build \{manifest.frontend} --target js")
  run(
    "cmd.exe /C tools\\msvc-native.cmd moon build \{manifest.host} --target native",
  )
  match manifest.bundle_kind() {
    "dir" => package_dir(manifest, manifest_path)
    "single-exe" => package_single_exe(manifest)
    other => fail_with("unknown bundle kind: \{other}")
  }
}
