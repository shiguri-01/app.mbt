///|
fn workspace_class(mode : String) -> String {
  match mode {
    "editor" => "workspace-body editor-only"
    "preview" => "workspace-body preview-only"
    _ => "workspace-body split"
  }
}

///|
fn workspace_shell_class() -> String {
  "workspace"
}

///|
fn editor_panel_class() -> String {
  "editor-panel"
}

///|
fn editor_class() -> String {
  "markdown-editor"
}

///|
fn preview_panel_class() -> String {
  "preview-panel"
}

///|
fn preview_class() -> String {
  "markdown-preview"
}

///|
fn editor_panel(model : NotesModel) -> DomNode {
  div(class=editor_panel_class()) <| [
    textarea(
      class=editor_class(),
      placeholder="# Start writing",
      dyn_attrs=[("value", attr_dynamic(fn() { model.content.get() }))],
      on=events().input(fn(e) {
        model.content.set(event_value(e))
        model.notify_dirty()
      }),
    ) <| [],
  ]
}

///|
fn preview_panel(model : NotesModel) -> DomNode {
  div(class=preview_panel_class()) <| [
    div(
      class=preview_class(),
      dyn_attrs=[
        (
          "__innerHTML",
          attr_dynamic(fn() { @markdown.md_to_html(model.content.get()) }),
        ),
      ],
    ) <| [],
  ]
}

///|
fn workspace(model : NotesModel) -> DomNode {
  div(class=workspace_shell_class()) <| [
    div(dyn_class=fn() { workspace_class(model.mode.get()) }) <| [
      editor_panel(model),
      preview_panel(model),
    ],
  ]
}
