///|
fn sidebar_actions(model : NotesModel) -> DomNode {
  div(class="sidebar-actions") <| [
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
  aside(class="sidebar") <| [
    div(class="sidebar-header") <| [
      sidebar_actions(model),
    ],
    div(class="recent-header") <| [
      h2(class="sidebar-title") <| [
        text("Recent"),
      ],
    ],
    div(class="recent-list") <| [
      for_each(fn() { model.recent_files.get() }, fn(path, _index) {
        button(
          dyn_class=fn() { recent_file_class(path, model.path.get()) },
          attrs=[("title", AttrString(path))],
          dyn_disabled=fn() { model.busy.get() },
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
    div(
      dyn_class=fn() {
        if model.recent_files.get().is_empty() {
          "empty-recent"
        } else {
          "empty-recent hidden"
        }
      },
    ) <| [
      text("No recent files"),
    ],
  ]
}
