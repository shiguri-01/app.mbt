///|
let initial_state : @contract.WorkbenchState = @core.default_state()

///|
let initial_model : Model = {
  client: Client(),
  state: initial_state,
  draft: initial_state.active_draft,
  response: None,
  loading: false,
  saving: false,
  sending: false,
  notice: "ready",
}

///|
#cfg(target="js")
extern "js" fn trigger_startup_load() -> Unit =
  #| () => {
  #|   // Rabbita's with_init currently runs before this IPC command path is
  #|   // ready. Dispatch the startup load through a normal DOM event after
  #|   // mount so it enters the same scheduler path as user actions.
  #|   setTimeout(() => {
  #|     document.getElementById('workbench-load-state')?.click()
  #|   }, 0)
  #| }

///|
#cfg(target="js")
fn main {
  let cell = @rabbita.cell(model=initial_model, update~, view~)
  let app = @rabbita.new(cell)
  app.mount("app")
  trigger_startup_load()
}
