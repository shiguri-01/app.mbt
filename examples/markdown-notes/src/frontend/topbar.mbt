///|
fn document_path_class(path : String?) -> String {
  match path {
    Some(_) => "document-path"
    None => "document-path empty"
  }
}

///|
fn notice_class(notice : String?) -> String {
  match notice {
    Some(_) => "notice"
    None => "notice empty"
  }
}

///|
fn notice_label(notice : String?) -> String {
  match notice {
    Some(message) => message
    None => ""
  }
}

///|
fn document_path_label(path : String?) -> String {
  match path {
    Some(value) => value
    None => ""
  }
}

///|
fn document_actions(model : NotesModel) -> DomNode {
  div(class="document-actions") <| [
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
  div(class="mode-tabs") <| [
    mode_button({
      label: "Split",
      active: fn() { model.mode.get() is Split },
      on_press: fn() { model.mode.set(Split) },
    }),
    mode_button({
      label: "Edit",
      active: fn() { model.mode.get() is Editor },
      on_press: fn() { model.mode.set(Editor) },
    }),
    mode_button({
      label: "Preview",
      active: fn() { model.mode.get() is Preview },
      on_press: fn() { model.mode.set(Preview) },
    }),
  ]
}

///|
fn topbar_controls(model : NotesModel) -> DomNode {
  div(class="topbar-controls") <| [
    mode_tabs(model),
    document_actions(model),
  ]
}

///|
fn topbar(model : NotesModel) -> DomNode {
  header_(class="topbar") <| [
    div(class="topbar-main") <| [
      div(class="title-block") <| [
        h1(class="document-title") <| [
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
      text_dyn(fn() { notice_label(model.notice.get()) }),
    ],
  ]
}
