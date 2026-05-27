///|
fn sidebar_shell_class() -> String {
  "sidebar"
}

///|
fn sidebar_header_class() -> String {
  "sidebar-header"
}

///|
fn sidebar_actions_class() -> String {
  "sidebar-actions"
}

///|
fn sidebar_title_class() -> String {
  "sidebar-title"
}

///|
fn recent_header_class() -> String {
  "recent-header"
}

///|
fn recent_list_class() -> String {
  "recent-list"
}

///|
fn sidebar_actions(model : NotesModel) -> DomNode {
  div(class=sidebar_actions_class()) <| [
    action_button({
      label: "New",
      title: "New document",
      kind: fn() { Sidebar },
      on_press: fn() { model.new_document() },
      disabled: fn() { model.busy.get() },
    }),
    action_button({
      label: "Open...",
      title: "Open Markdown file",
      kind: fn() { Sidebar },
      on_press: fn() { model.open_dialog() },
      disabled: fn() { model.busy.get() },
    }),
  ]
}

///|
fn empty_recent_class() -> String {
  "empty-recent"
}

///|
fn recent_file_class(path : String, current_path : String?) -> String {
  match current_path {
    Some(current) =>
      if current == path {
        "recent-file active"
      } else {
        "recent-file"
      }
    None => "recent-file"
  }
}

///|
fn sidebar(model : NotesModel) -> DomNode {
  aside(class=sidebar_shell_class()) <| [
    div(class=sidebar_header_class()) <| [
      sidebar_actions(model),
    ],
    div(class=recent_header_class()) <| [
      h2(class=sidebar_title_class()) <| [
        text("Recent"),
      ],
    ],
    div(class=recent_list_class()) <| [
      for_each(fn() { model.recent_files.get() }, fn(path, _index) {
        button(
          dyn_class=fn() { recent_file_class(path, model.path.get()) },
          attrs=[("title", AttrString(path))],
          on=events().click(_ => model.open_recent(path)),
        ) <| [
          span(class="recent-file-name") <| [
            text(@core.file_name(Some(path))),
          ],
          span(class="recent-file-path") <| [
            text(path),
          ],
        ]
      }),
    ],
    div(class=empty_recent_class()) <| [
      text_dyn(fn() {
        if model.recent_files.get().is_empty() {
          "No recent files"
        } else {
          ""
        }
      }),
    ],
  ]
}
