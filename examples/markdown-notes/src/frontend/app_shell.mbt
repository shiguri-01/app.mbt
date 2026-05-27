///|
fn app_shell_class() -> String {
  "app-shell"
}

///|
fn main_column_class() -> String {
  "main-column"
}

///|
fn app_view(model : NotesModel) -> DomNode {
  main_(class=app_shell_class()) <| [
    sidebar(model),
    div(class=main_column_class()) <| [
      topbar(model),
      workspace(model),
    ],
  ]
}
