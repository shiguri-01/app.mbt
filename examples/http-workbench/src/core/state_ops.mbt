///|
pub fn default_state() -> WorkbenchState {
  WorkbenchState::{
    saved_requests: [],
    recent_history: [],
    active_draft: default_request(),
  }
}

///|
pub fn capped_history(
  entries : Array[HistoryEntry],
  entry : HistoryEntry,
) -> Array[HistoryEntry] {
  let next = entries.copy()
  next.insert(0, entry)
  if next.length() > 30 {
    ignore(next.remove(next.length() - 1))
  }
  next
}

///|
pub fn upsert_saved_request(
  saved : Array[SavedRequest],
  draft : SavedRequest,
  new_id~ : String,
) -> (Array[SavedRequest], SavedRequest) {
  let id = if draft.id == "draft" { new_id } else { draft.id }
  let request = { ..draft, id, name: display_name(draft) }
  let next = []
  let mut replaced = false
  for saved_request in saved {
    if saved_request.id == id {
      next.push(request)
      replaced = true
    } else {
      next.push(saved_request)
    }
  }
  if !replaced {
    next.push(request)
  }
  (next, request)
}

///|
pub fn delete_saved_request(
  saved : Array[SavedRequest],
  id : String,
) -> Array[SavedRequest] {
  let next = []
  for request in saved {
    if request.id != id {
      next.push(request)
    }
  }
  next
}
