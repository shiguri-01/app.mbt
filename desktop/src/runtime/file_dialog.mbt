///|
/// A file filter shown in native file open/save dialogs.
///
/// `extensions` must contain extension names without leading dots, such as
/// `["png", "jpg", "jpeg"]`.
pub(all) struct FileFilter {
  name : String
  extensions : Array[String]
} derive(Debug, Eq)

///|
fn FileFilter::to_shell(self : FileFilter) -> @shell.FileFilter {
  { name: self.name, extensions: self.extensions }
}

///|
fn file_filters_to_shell(
  filters : Array[FileFilter]?,
) -> Array[@shell.FileFilter]? {
  match filters {
    None => None
    Some(filters) => Some(filters.map(fn(filter) { filter.to_shell() }))
  }
}

///|
fn shell_open_file_dialog(
  parent : @webview.NativeWindow,
  filters : Array[FileFilter]?,
  default_path? : String,
) -> String? raise @shell.ShellError {
  match file_filters_to_shell(filters) {
    None => @shell.open_file_dialog(parent, default_path?)
    Some(shell_filters) =>
      @shell.open_file_dialog(parent, filters=shell_filters, default_path?)
  }
}

///|
fn shell_open_files_dialog(
  parent : @webview.NativeWindow,
  filters : Array[FileFilter]?,
  default_path? : String,
) -> Array[String]? raise @shell.ShellError {
  match file_filters_to_shell(filters) {
    None => @shell.open_files_dialog(parent, default_path?)
    Some(shell_filters) =>
      @shell.open_files_dialog(parent, filters=shell_filters, default_path?)
  }
}

///|
fn shell_save_file_dialog(
  parent : @webview.NativeWindow,
  filters : Array[FileFilter]?,
  default_path? : String,
  default_name? : String,
) -> String? raise @shell.ShellError {
  match file_filters_to_shell(filters) {
    None => @shell.save_file_dialog(parent, default_path?, default_name?)
    Some(shell_filters) =>
      @shell.save_file_dialog(
        parent,
        filters=shell_filters,
        default_path?,
        default_name?,
      )
  }
}

///|
/// Show a native dialog for selecting one existing file.
pub fn Window::open_file_dialog(
  self : Window,
  filters? : Array[FileFilter],
  default_path? : String,
) -> String? raise DesktopError {
  let parent = self.view.native_window() catch {
    err => {
      raise_webview(err)
      abort("unreachable")
    }
  }
  shell_open_file_dialog(parent, filters, default_path?) catch {
    err => {
      raise_shell(err)
      abort("unreachable")
    }
  }
}

///|
/// Show a native dialog for selecting one or more existing files.
pub fn Window::open_files_dialog(
  self : Window,
  filters? : Array[FileFilter],
  default_path? : String,
) -> Array[String]? raise DesktopError {
  let parent = self.view.native_window() catch {
    err => {
      raise_webview(err)
      abort("unreachable")
    }
  }
  shell_open_files_dialog(parent, filters, default_path?) catch {
    err => {
      raise_shell(err)
      abort("unreachable")
    }
  }
}

///|
/// Show a native dialog for selecting a destination file path.
pub fn Window::save_file_dialog(
  self : Window,
  filters? : Array[FileFilter],
  default_path? : String,
  default_name? : String,
) -> String? raise DesktopError {
  let parent = self.view.native_window() catch {
    err => {
      raise_webview(err)
      abort("unreachable")
    }
  }
  shell_save_file_dialog(parent, filters, default_path?, default_name?) catch {
    err => {
      raise_shell(err)
      abort("unreachable")
    }
  }
}

///|
/// Show a native dialog for selecting one existing folder.
pub fn Window::open_folder_dialog(
  self : Window,
  default_path? : String,
) -> String? raise DesktopError {
  let parent = self.view.native_window() catch {
    err => {
      raise_webview(err)
      abort("unreachable")
    }
  }
  @shell.open_folder_dialog(parent, default_path?) catch {
    err => {
      raise_shell(err)
      abort("unreachable")
    }
  }
}
