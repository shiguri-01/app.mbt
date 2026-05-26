///|
let filter_separator : String = "\u{1f}"

///|
fn validate_file_filter(filter : FileFilter) -> Unit raise ShellError {
  if filter.name is "" {
    raise InvalidFileFilter("filter name must not be empty")
  }
  if filter.name.contains(filter_separator) {
    raise InvalidFileFilter("filter name contains a reserved separator")
  }
  if filter.extensions.length() == 0 {
    raise InvalidFileFilter("filter extensions must not be empty")
  }
  for extension in filter.extensions {
    if extension is "" {
      raise InvalidFileFilter("filter extension must not be empty")
    }
    if extension.contains(filter_separator) ||
      extension.contains(",") ||
      extension.contains("*") ||
      extension.contains(".") {
      raise InvalidFileFilter(
        "filter extension must not contain separators, wildcards, or dots",
      )
    }
  }
}

///|
fn encode_filter_names(filters : Array[FileFilter]?) -> Bytes raise ShellError {
  match filters {
    None => @utf8.encode("")
    Some(filters) => {
      let names = []
      for filter in filters {
        validate_file_filter(filter)
        names.push(filter.name)
      }
      @utf8.encode(names.join(filter_separator))
    }
  }
}

///|
fn encode_filter_specs(filters : Array[FileFilter]?) -> Bytes raise ShellError {
  match filters {
    None => @utf8.encode("")
    Some(filters) => {
      let specs = []
      for filter in filters {
        validate_file_filter(filter)
        specs.push(filter.extensions.join(","))
      }
      @utf8.encode(specs.join(filter_separator))
    }
  }
}

///|
fn encode_optional_path(path : String?) -> Bytes {
  match path {
    None => @utf8.encode("")
    Some(path) => @utf8.encode(path)
  }
}

///|
fn file_dialog_result_error(result : FileDialogResult) -> String {
  @utf8.decode_lossy(ffi_file_dialog_result_error(result))
}

///|
fn file_dialog_result_to_path(
  result : FileDialogResult,
) -> String? raise ShellError {
  match ffi_file_dialog_result_status(result) {
    0 => None
    1 => {
      if ffi_file_dialog_result_len(result) == 0 {
        raise DialogFailed("file dialog returned no path")
      }
      Some(@utf8.decode_lossy(ffi_file_dialog_result_path_at(result, 0)))
    }
    -1 => raise InvalidWindow
    -2 => raise UnsupportedPlatform
    -3 => raise DialogFailed(file_dialog_result_error(result))
    code => raise UnknownDialogResult(code)
  }
}

///|
fn file_dialog_result_to_paths(
  result : FileDialogResult,
) -> Array[String]? raise ShellError {
  match ffi_file_dialog_result_status(result) {
    0 => None
    1 => {
      let paths = []
      for index in 0..<ffi_file_dialog_result_len(result) {
        paths.push(
          @utf8.decode_lossy(ffi_file_dialog_result_path_at(result, index)),
        )
      }
      Some(paths)
    }
    -1 => raise InvalidWindow
    -2 => raise UnsupportedPlatform
    -3 => raise DialogFailed(file_dialog_result_error(result))
    code => raise UnknownDialogResult(code)
  }
}

///|
fn show_file_dialog_result(
  parent : @webview.NativeWindow,
  kind : Int,
  filters? : Array[FileFilter],
  default_path? : String,
  default_name? : String,
) -> FileDialogResult raise ShellError {
  ffi_show_file_dialog(
    parent,
    kind,
    encode_filter_names(filters),
    encode_filter_specs(filters),
    encode_optional_path(default_path),
    encode_optional_path(default_name),
  )
}

///|
/// Show a native dialog for selecting one existing file.
pub fn open_file_dialog(
  parent : @webview.NativeWindow,
  filters? : Array[FileFilter],
  default_path? : String,
) -> String? raise ShellError {
  file_dialog_result_to_path(
    show_file_dialog_result(parent, 0, filters?, default_path?),
  )
}

///|
/// Show a native dialog for selecting one or more existing files.
pub fn open_files_dialog(
  parent : @webview.NativeWindow,
  filters? : Array[FileFilter],
  default_path? : String,
) -> Array[String]? raise ShellError {
  file_dialog_result_to_paths(
    show_file_dialog_result(parent, 1, filters?, default_path?),
  )
}

///|
/// Show a native dialog for selecting a destination file path.
pub fn save_file_dialog(
  parent : @webview.NativeWindow,
  filters? : Array[FileFilter],
  default_path? : String,
  default_name? : String,
) -> String? raise ShellError {
  file_dialog_result_to_path(
    show_file_dialog_result(parent, 2, filters?, default_path?, default_name?),
  )
}

///|
/// Show a native dialog for selecting one existing folder.
pub fn open_folder_dialog(
  parent : @webview.NativeWindow,
  default_path? : String,
) -> String? raise ShellError {
  file_dialog_result_to_path(show_file_dialog_result(parent, 3, default_path?))
}
