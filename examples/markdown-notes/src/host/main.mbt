///|
fn state_file_path() -> String {
  @desktop.app_dir() + "/markdown-notes-state.json"
}

///|
fn local_dist_path(relative : String) -> String raise {
  guard @env.current_dir() is Some(cwd) else {
    fail("could not determine current directory")
  }
  cwd + "/examples/markdown-notes/dist/" + relative
}

///|
async fn read_dist_text(relative : String) -> String {
  match (@desktop.resource_text(relative) catch { _ => None }) {
    Some(text) => text
    None => @fs.read_file(local_dist_path(relative)).text()
  }
}

///|
fn load_frontend_html() -> String raise {
  let html_ref : Ref[String?] = Ref(None)
  let error_ref : Ref[String?] = Ref(None)
  @async.run_async_main(() => {
    let html = read_dist_text("index.html") catch {
      err => {
        error_ref.val = Some("\{to_repr(err)}")
        return
      }
    }
    html_ref.val = Some(html)
  })
  match html_ref.val {
    Some(html) => html
    None =>
      match error_ref.val {
        Some(message) => fail(message)
        None => fail("frontend loader finished without a result")
      }
  }
}

///|
fn markdown_filters() -> Array[@desktop.FileFilter] {
  [
    { name: "Markdown", extensions: ["md", "markdown"] },
    { name: "Text", extensions: ["txt"] },
  ]
}

///|
fn default_app_state() -> @contract.AppState {
  @core.app_state_from_startup(@core.default_startup_state())
}

///|
async fn read_app_state(path : String) -> @contract.AppState {
  let raw = @fs.read_file(path).text()
  let json = @json.parse(raw)
  @json.from_json(json)
}

///|
async fn load_state() -> @contract.StartupState {
  let path = state_file_path()
  guard @fs.exists(path) else { @core.default_startup_state() }
  let app_state = read_app_state(path) catch { _ => default_app_state() }
  { recent_files: app_state.recent_files, last_file: app_state.last_file }
}

///|
async fn save_state(state : @contract.StartupState) -> Unit {
  let app_state = @core.app_state_from_startup(state)
  @fs.write_file(
    state_file_path(),
    app_state.to_json().stringify(),
    create_mode=CreateOrTruncate,
  ) catch {
    _ => ()
  }
}

///|
async fn remember_file(path : String) -> Unit {
  let state = load_state()
  save_state({
    recent_files: @core.add_recent(state.recent_files, path),
    last_file: Some(path),
  })
}

///|
async fn read_markdown_file(
  path : String,
  remember? : Bool = true,
) -> @contract.OpenDocument {
  let content = @fs.read_file(path).text()
  if remember {
    remember_file(path)
  }
  { path, name: @core.file_name(Some(path)), content }
}

///|
async fn write_markdown_file(
  path : String,
  content : String,
) -> @contract.SavedFile {
  @fs.write_file(path, content, create_mode=CreateOrTruncate)
  remember_file(path)
  { path, name: @core.file_name(Some(path)) }
}

///|
fn main {
  let html = load_frontend_html() catch {
    err => {
      println(
        "failed to load Markdown Notes frontend; run `just build-markdown-notes-frontend` first",
      )
      println(to_repr(err))
      return
    }
  }
  let is_dirty = Ref(false)
  @desktop.run(on_startup=app => {
    let window = app.create_window(
      WindowOptions(
        key="main",
        title="Markdown Notes",
        width=1180,
        height=760,
        min_width=840,
        min_height=560,
        load=Html(html),
      ),
      lifecycle=WindowLifecycle(before_close=(window, reason) => {
        ignore(reason)
        guard is_dirty.val else { Allow }
        let result = window.show_message_dialog(
          "This document has unsaved changes. Close it anyway?",
          title="Unsaved changes",
          kind=Warning,
          buttons=YesNo,
        )
        if result == Yes {
          Allow
        } else {
          Prevent
        }
      }),
    )
    let router = @desktop.IpcRouter()
      .handle(@contract.load_startup_state_endpoint, handler=_ => load_state())
      .handle(@contract.open_file_dialog_endpoint, handler=_ => {
        match window.open_file_dialog(filters=markdown_filters()) {
          Some(path) => { document: Some(read_markdown_file(path)) }
          None => { document: None }
        }
      })
      .handle(@contract.open_file_endpoint, handler=request => {
        read_markdown_file(request.path, remember=false)
      })
      .handle(@contract.save_file_endpoint, handler=request => {
        match request.path {
          Some(path) =>
            { file: Some(write_markdown_file(path, request.content)) }
          None =>
            match
              window.save_file_dialog(
                filters=markdown_filters(),
                default_name=@core.file_name(None),
              ) {
              Some(path) =>
                { file: Some(write_markdown_file(path, request.content)) }
              None => { file: None }
            }
        }
      })
      .handle(@contract.save_file_as_endpoint, handler=request => {
        match
          window.save_file_dialog(
            filters=markdown_filters(),
            default_name=@core.file_name(request.path),
          ) {
          Some(path) =>
            { file: Some(write_markdown_file(path, request.content)) }
          None => { file: None }
        }
      })
      .handle(@contract.set_dirty_endpoint, handler=state => {
        is_dirty.val = state.dirty
      })
    window.mount_ipc(router)
  }) catch {
    err => println("desktop runtime failed: \{to_repr(err)}")
  }
}
