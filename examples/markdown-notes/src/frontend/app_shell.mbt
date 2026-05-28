///|
fn app_view(model : NotesModel) -> DomNode {
  main_(class="app-shell") <| [
    sidebar(model),
    div(class="main-column") <| [
      topbar(model),
      workspace(model),
    ],
  ]
}
