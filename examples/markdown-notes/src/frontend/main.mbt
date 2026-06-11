///|
using @resource {signal, memo}

///|
fn event_value(e : @dom.InputEvent) -> String {
  let target : @js.Any = e.target() |> @js.identity
  target._get("value").cast()
}

///|
fn confirm_discard_changes() -> Bool {
  @dom.window().confirm("This document has unsaved changes. Continue?")
}

///|
struct NotesModel {
  client : @desktop.Client
  path : @resource.Signal[String?]
  title : @resource.Signal[String]
  content : @resource.Signal[String]
  saved_content : @resource.Signal[String]
  recent_files : @resource.Signal[Array[String]]
  notice : @resource.Signal[String?]
  busy : @resource.Signal[Bool]
  reported_dirty : @resource.Signal[Bool]
  mode : @resource.Signal[ViewMode]
  dirty : () -> Bool
}

///|
fn NotesModel::sync_window_state(self : NotesModel) -> Unit {
  let dirty = (self.dirty)()
  if self.reported_dirty.get() != dirty {
    self.reported_dirty.set(dirty)
    self.client.request_callback(@contract.set_dirty_endpoint, { dirty, }, _ => {
      ()
    })
  }
  let suffix = if dirty { " *" } else { "" }
  @dom.document().setTitle(self.title.get() + suffix + " - Markdown Notes")
}

///|
fn NotesModel::replace_document(
  self : NotesModel,
  path : String?,
  name : String,
  content : String,
) -> Unit {
  self.path.set(path)
  self.title.set(name)
  self.content.set(content)
  self.saved_content.set(content)
  self.notice.set(None)
  self.sync_window_state()
}

///|
fn NotesModel::can_discard_current_document(self : NotesModel) -> Bool {
  !(self.dirty)() || confirm_discard_changes()
}

///|
fn NotesModel::can_start_file_task(self : NotesModel) -> Bool {
  !self.busy.get()
}

///|
fn NotesModel::start_file_task(self : NotesModel) -> Unit {
  self.busy.set(true)
  self.notice.set(None)
}

///|
fn NotesModel::finish_file_task(self : NotesModel) -> Unit {
  self.busy.set(false)
}

///|
fn ipc_error_message(err : @ipc.IpcError) -> String {
  match err {
    DecodeError(message) => "Could not decode the desktop response: \{message}"
    EncodeError(message) => "Could not encode the desktop request: \{message}"
    HandlerError(message) => message
    TransportClosed(message) => "Desktop bridge is unavailable: \{message}"
    UnsupportedVersion(version) => "IPC version mismatch: \{version}"
    PayloadTooLarge(size~, limit~) =>
      "Request is too large: \{size} bytes, limit is \{limit} bytes"
  }
}

///|
fn NotesModel::show_file_error(
  self : NotesModel,
  action : String,
  err : @ipc.IpcError,
) -> Unit {
  self.notice.set(Some("\{action} failed: \{ipc_error_message(err)}"))
}

///|
fn NotesModel::open_document(
  self : NotesModel,
  document : @contract.OpenDocument,
) -> Unit {
  self.replace_document(Some(document.path), document.name, document.content)
  self.refresh_startup_state()
}

///|
fn NotesModel::record_saved_file(
  self : NotesModel,
  file : @contract.SavedFile,
) -> Unit {
  self.path.set(Some(file.path))
  self.title.set(file.name)
  self.saved_content.set(self.content.get())
  self.notice.set(None)
  self.sync_window_state()
  self.refresh_startup_state()
}

///|
fn NotesModel::handle_open_reply(
  self : NotesModel,
  response : @ipc.IpcResponse[@contract.OpenDocument],
) -> Unit {
  self.finish_file_task()
  match response {
    Ok(document) => self.open_document(document)
    Err(err) => self.show_file_error("Open", err)
  }
}

///|
fn NotesModel::handle_save_reply(
  self : NotesModel,
  response : @ipc.IpcResponse[@contract.SaveFileReply],
) -> Unit {
  self.finish_file_task()
  match response {
    Ok(reply) =>
      match reply.file {
        Some(file) => self.record_saved_file(file)
        None => ()
      }
    Err(err) => self.show_file_error("Save", err)
  }
}

///|
fn NotesModel::handle_open_dialog_reply(
  self : NotesModel,
  response : @ipc.IpcResponse[@contract.OpenDialogReply],
) -> Unit {
  self.finish_file_task()
  match response {
    Ok(reply) =>
      match reply.document {
        Some(document) => self.open_document(document)
        None => ()
      }
    Err(err) => self.show_file_error("Open", err)
  }
}

///|
fn NotesModel::refresh_startup_state(self : NotesModel) -> Unit {
  self.client.request_callback(@contract.load_startup_state_endpoint, (), response => {
    match response {
      Ok(state) => self.recent_files.set(state.recent_files)
      Err(_) => ()
    }
  })
}

///|
fn NotesModel::open_dialog(self : NotesModel) -> Unit {
  guard self.can_start_file_task() else {  }
  guard self.can_discard_current_document() else {  }
  self.start_file_task()
  self.client.request_callback(@contract.open_file_dialog_endpoint, (), response => {
    self.handle_open_dialog_reply(response)
  })
}

///|
fn NotesModel::open_recent(self : NotesModel, path : String) -> Unit {
  guard self.can_start_file_task() else {  }
  guard self.can_discard_current_document() else {  }
  self.start_file_task()
  self.client.request_callback(@contract.open_file_endpoint, { path, }, response => {
    self.handle_open_reply(response)
  })
}

///|
fn NotesModel::save(self : NotesModel) -> Unit {
  guard self.can_start_file_task() else {  }
  self.start_file_task()
  self.client.request_callback(
    @contract.save_file_endpoint,
    { path: self.path.get(), content: self.content.get() },
    response => self.handle_save_reply(response),
  )
}

///|
fn NotesModel::save_as(self : NotesModel) -> Unit {
  guard self.can_start_file_task() else {  }
  self.start_file_task()
  self.client.request_callback(
    @contract.save_file_as_endpoint,
    { path: self.path.get(), content: self.content.get() },
    response => self.handle_save_reply(response),
  )
}

///|
fn NotesModel::new_document(self : NotesModel) -> Unit {
  guard self.can_start_file_task() else {  }
  guard self.can_discard_current_document() else {  }
  self.path.set(None)
  self.title.set(@core.file_name(None))
  self.content.set(@core.welcome_markdown())
  self.saved_content.set(@core.welcome_markdown())
  self.notice.set(None)
  self.sync_window_state()
}

///|
fn create_model() -> NotesModel {
  let content = signal(@core.welcome_markdown())
  let saved_content = signal(@core.welcome_markdown())
  let dirty = memo(fn() { content.get() != saved_content.get() })
  {
    client: Client(),
    path: signal(None),
    title: signal(@core.file_name(None)),
    content,
    saved_content,
    recent_files: signal([]),
    notice: signal(None),
    busy: signal(false),
    reported_dirty: signal(false),
    mode: signal(Split),
    dirty,
  }
}

///|
fn main {
  let model = create_model()
  let doc = @dom.document()
  guard doc.getElementById("app") is Some(el) else {
    println("Could not find #app")
  }
  render(el |> DomElement::from_dom, app_view(model))
  model.refresh_startup_state()
  model.sync_window_state()
}
