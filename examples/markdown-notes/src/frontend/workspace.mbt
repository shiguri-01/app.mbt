///|
enum ViewMode {
  Split
  Editor
  Preview
}

///|
fn workspace_class(mode : ViewMode) -> String {
  match mode {
    Split => "workspace-body split"
    Editor => "workspace-body editor-only"
    Preview => "workspace-body preview-only"
  }
}

///|
fn editor_panel(model : NotesModel) -> DomNode {
  div(class="editor-panel") <| [
    textarea(
      class="markdown-editor",
      placeholder="# Start writing",
      dyn_attrs=[("value", attr_dynamic(fn() { model.content.get() }))],
      on=events().input(fn(e) {
        model.content.set(event_value(e))
        model.sync_window_state()
      }),
    ) <| [],
  ]
}

///|
fn preview_panel(model : NotesModel) -> DomNode {
  div(class="preview-panel") <| [
    div(
      class="markdown-preview",
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
  div(class="workspace") <| [
    div(dyn_class=fn() { workspace_class(model.mode.get()) }) <| [
      editor_panel(model),
      preview_panel(model),
    ],
  ]
}
