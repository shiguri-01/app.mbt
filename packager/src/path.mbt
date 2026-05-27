///|
fn normalize_path(path : String) -> String {
  path.replace_all(old="\\", new="/")
}

///|
fn join_path(base : String, relative : String) -> String {
  if base == "" {
    relative
  } else if base.has_suffix("/") || base.has_suffix("\\") {
    base + relative
  } else {
    base + "/" + relative
  }
}

///|
fn last_path_segment(path : String) -> String {
  let normalized = normalize_path(path)
  match normalized.rev_split_once("/") {
    Some((_, tail)) => tail.to_owned()
    None => normalized
  }
}

///|
fn build_artifact_path(
  target : String,
  module_name : String,
  package_path : String,
  extension : String,
) -> String {
  let package_name = last_path_segment(package_path)
  join_path(
    "_build",
    join_path(
      target,
      join_path(
        "debug/build",
        join_path(
          module_name,
          join_path(package_name, package_name + extension),
        ),
      ),
    ),
  )
}
