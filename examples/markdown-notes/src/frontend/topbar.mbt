///|
fn topbar_class() -> String {
  "topbar"
}

///|
fn topbar_main_class() -> String {
  "topbar-main"
}

///|
fn title_block_class() -> String {
  "title-block"
}

///|
fn document_title_class() -> String {
  "document-title"
}

///|
fn document_path_class(path : String?) -> String {
  match path {
    Some(_) => "document-path"
    None => "document-path empty"
  }
}

///|
fn document_actions_class() -> String {
  "document-actions"
}

///|
fn topbar_controls_class() -> String {
  "topbar-controls"
}

///|
fn mode_tabs_class() -> String {
  "mode-tabs"
}

///|
fn notice_class(notice : String) -> String {
  if notice == "" {
    "notice empty"
  } else {
    "notice"
  }
}

///|
fn document_path_label(path : String?) -> String {
  match path {
    Some(value) => value
    None => "\u{00A0}"
  }
}

///|
fn document_actions(model : NotesModel) -> DomNode {
  div(class=document_actions_class()) <| [
    action_button({
      label: "Save",
      title: "Save",
      kind: fn() { if (model.dirty)() { Primary } else { Secondary } },
      on_press: fn() { model.save() },
      disabled: fn() { model.busy.get() },
    }),
    action_button({
      label: "Save As...",
      title: "Save as",
      kind: fn() { Secondary },
      on_press: fn() { model.save_as() },
      disabled: fn() { model.busy.get() },
    }),
  ]
}

///|
fn mode_tabs(model : NotesModel) -> DomNode {
  div(class=mode_tabs_class()) <| [
    mode_button({
      label: "Split",
      active: fn() { model.mode.get() == "split" },
      on_press: fn() { model.mode.set("split") },
    }),
    mode_button({
      label: "Edit",
      active: fn() { model.mode.get() == "editor" },
      on_press: fn() { model.mode.set("editor") },
    }),
    mode_button({
      label: "Preview",
      active: fn() { model.mode.get() == "preview" },
      on_press: fn() { model.mode.set("preview") },
    }),
  ]
}

///|
fn topbar_controls(model : NotesModel) -> DomNode {
  div(class=topbar_controls_class()) <| [
    mode_tabs(model),
    document_actions(model),
  ]
}

///|
fn topbar(model : NotesModel) -> DomNode {
  header_(class=topbar_class()) <| [
    div(class=topbar_main_class()) <| [
      div(class=title_block_class()) <| [
        h1(class=document_title_class()) <| [
          text_dyn(fn() { model.title.get() }),
          text_dyn(fn() { if (model.dirty)() { " *" } else { "" } }),
        ],
        p(dyn_class=fn() { document_path_class(model.path.get()) }) <| [
          text_dyn(fn() { document_path_label(model.path.get()) }),
        ],
      ],
      topbar_controls(model),
    ],
    div(dyn_class=fn() { notice_class(model.notice.get()) }) <| [
      text_dyn(fn() { model.notice.get() }),
    ],
  ]
}
