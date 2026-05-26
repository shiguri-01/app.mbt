///|
async fn file_dialog_html() -> String {
  guard @env.current_dir() is Some(cwd) else {
    fail("could not determine current directory")
  }
  let html = @fs.read_file(cwd + "/examples/file-dialogs/static/index.html").text()
  let frontend = @fs.read_file(
    cwd +
    "/_build/js/debug/build/shiguri-01/desktop-file-dialog-example/frontend/frontend.js",
  ).text()
  html.replace(old="__MOONBIT_FILE_DIALOG_FRONTEND__", new=frontend)
}

///|
fn load_file_dialog_html() -> Result[String, String] {
  let result : Ref[Result[String, String]?] = Ref(None)
  @async.run_async_main(() => {
    let html = file_dialog_html() catch {
      err => {
        result.val = Some(Err("\{to_repr(err)}"))
        return
      }
    }
    result.val = Some(Ok(html))
  })
  match result.val {
    Some(result) => result
    None => Err("file dialog frontend loader finished without a result")
  }
}

///|
fn selected_path(path : String?) -> @shared.FileDialogEvent {
  match path {
    None => Canceled
    Some(path) => Selected([path])
  }
}

///|
fn selected_paths(paths : Array[String]?) -> @shared.FileDialogEvent {
  match paths {
    None => Canceled
    Some(paths) => Selected(paths)
  }
}

///|
async fn write_sample_file(path : String) -> Unit {
  let content =
    #|Saved by the MoonBit native file dialog example.
    #|
    #|This file was written after Window::save_file_dialog returned a path.
    #|
  @fs.write_file(path, content, create_mode=CreateOrTruncate)
}

///|
fn write_sample_file_sync(path : String) -> Result[Unit, String] {
  let result : Ref[Result[Unit, String]?] = Ref(None)
  @async.run_async_main(() => {
    write_sample_file(path) catch {
      err => {
        result.val = Some(Err("\{to_repr(err)}"))
        return
      }
    }
    result.val = Some(Ok(()))
  })
  match result.val {
    Some(result) => result
    None => Err("file writer finished without a result")
  }
}

///|
fn save_sample_file(
  window : @desktop.Window,
) -> @shared.FileDialogEvent raise @desktop.DesktopError {
  match
    window.save_file_dialog(filters=filters(), default_name="Untitled.txt") {
    None => Canceled
    Some(path) =>
      match write_sample_file_sync(path) {
        Ok(_) => Selected([path])
        Err(message) =>
          raise @desktop.DesktopError::InvalidState(
            "failed to write selected file: \{message}",
          )
      }
  }
}

///|
fn filters() -> Array[@desktop.FileFilter] {
  [
    { name: "Text", extensions: ["txt", "md", "json"] },
    { name: "Images", extensions: ["png", "jpg", "jpeg", "gif"] },
  ]
}

///|
fn handle_command(
  window : @desktop.Window,
  command : @shared.FileDialogCommand,
) -> @shared.FileDialogEvent raise @desktop.DesktopError {
  match command {
    OpenFile => selected_path(window.open_file_dialog(filters=filters()))
    OpenFiles => selected_paths(window.open_files_dialog(filters=filters()))
    SaveFile => save_sample_file(window)
    OpenFolder => selected_path(window.open_folder_dialog())
  }
}

///|
fn main {
  let html = match load_file_dialog_html() {
    Ok(html) => html
    Err(message) => {
      println(
        "failed to load file dialog frontend; run `just build-file-dialogs-example-frontend` first",
      )
      println(message)
      return
    }
  }
  @desktop.run(
    title="MoonBit File Dialogs",
    width=760,
    height=500,
    load=Html(html),
    on_ready=window => {
      window.handle_sync_default(command => handle_command(window, command))
    },
  ) catch {
    err => println("desktop runtime failed: \{to_repr(err)}")
  }
}
