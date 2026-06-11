///|
/// Return the initial persisted state used by the example.
pub fn default_state() -> @contract.WorkbenchState {
  let active_draft = default_request()
  { saved_requests: sample_requests(), recent_history: [], active_draft }
}

///|
/// Add a history entry, keeping only the newest entries.
pub fn capped_history(
  entries : Array[@contract.HistoryEntry],
  entry : @contract.HistoryEntry,
) -> Array[@contract.HistoryEntry] {
  let next = entries.copy()
  next.insert(0, entry)
  if next.length() > 30 {
    ignore(next.remove(next.length() - 1))
  }
  next
}

///|
/// Insert or replace a saved request and assign `new_id` to drafts.
pub fn upsert_saved_request(
  saved : Array[@contract.SavedRequest],
  draft : @contract.SavedRequest,
  new_id~ : String,
) -> (Array[@contract.SavedRequest], @contract.SavedRequest) {
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
/// Delete a saved request by id.
pub fn delete_saved_request(
  saved : Array[@contract.SavedRequest],
  id : String,
) -> Array[@contract.SavedRequest] {
  let next = []
  for request in saved {
    if request.id != id {
      next.push(request)
    }
  }
  next
}
