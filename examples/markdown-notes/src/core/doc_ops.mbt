///|
/// Return the default Markdown shown for a new document.
pub fn welcome_markdown() -> String {
  (
    #|# Markdown Notes
    #|
    #|Open a `.md` file or start typing here.
    #|
    #|- Native file dialogs are handled by the MoonBit host.
    #|- Preview is rendered from MoonBit in the frontend.
    #|- Dirty state is reported back to the native window lifecycle.
    #|
  )
}

///|
/// Return a display file name for a path.
pub fn file_name(path : String?) -> String {
  match path {
    None => "Untitled.md"
    Some(path) => {
      let mut start = 0
      for i in 0..<path.length() {
        if path[i] == ('/' : UInt16) || path[i] == ('\\' : UInt16) {
          start = i + 1
        }
      }
      if start >= path.length() {
        "Untitled.md"
      } else {
        path[start:].to_owned()
      }
    }
  }
}

///|
/// Return empty startup state.
pub fn default_startup_state() -> @contract.StartupState {
  @contract.StartupState::{ recent_files: [], last_file: None }
}

///|
/// Add a recent file path, remove duplicates, and cap the list.
pub fn add_recent(
  recent : Array[String],
  path : String,
  limit? : Int = 8,
) -> Array[String] {
  let next : Array[String] = [path]
  for item in recent {
    if item != path && next.length() < limit {
      next.push(item)
    }
  }
  next
}

///|
/// Convert startup state into frontend application state.
pub fn app_state_from_startup(
  state : @contract.StartupState,
) -> @contract.AppState {
  @contract.AppState::{
    recent_files: state.recent_files,
    last_file: state.last_file,
  }
}
