///|
enum Msg {
  LoadState
  StateLoaded(@ipc.IpcResponse[@core.WorkbenchState])
  SaveWorkspace
  StateSaved(@ipc.IpcResponse[@core.SaveStateReply])
  MethodChanged(String)
  UrlChanged(String)
  NameChanged(String)
  BodyChanged(String)
  AddHeader
  RemoveHeader(Int)
  ToggleHeader(Int)
  HeaderNameChanged(Int, String)
  HeaderValueChanged(Int, String)
  SendRequest
  RequestSent(@ipc.IpcResponse[@core.SendHttpReply])
  SaveCurrentRequest
  SelectSaved(String)
  DeleteSaved(String)
  ClearHistory
}

///|
struct Model {
  client : @desktop.Client
  state : @core.WorkbenchState
  draft : @core.SavedRequest
  response : @core.SendHttpReply?
  loading : Bool
  saving : Bool
  sending : Bool
  notice : String
}

///|
fn new_request_id() -> String {
  "req-\{@async.now()}"
}

///|
fn with_draft(
  model : Model,
  draft : @core.SavedRequest,
  notice? : String = "",
) -> Model {
  { ..model, draft, state: { ..model.state, active_draft: draft }, notice }
}

///|
fn update(
  emit : @rabbita.Emit[Msg],
  msg : Msg,
  model : Model,
) -> (@rabbita.Cmd, Model) {
  match msg {
    LoadState =>
      (
        load_state_cmd(emit, model.client),
        { ..model, loading: true, notice: "loading state" },
      )
    StateLoaded(response) =>
      match response {
        Ok(state) =>
          (
            @rabbita.none,
            {
              ..model,
              state,
              draft: state.active_draft,
              loading: false,
              notice: "state loaded",
            },
          )
        Err(err) =>
          (
            @rabbita.none,
            { ..model, loading: false, notice: "load failed: \{to_repr(err)}" },
          )
      }
    SaveWorkspace => {
      let state = { ..model.state, active_draft: model.draft }
      (
        save_state_cmd(emit, model.client, state),
        { ..model, state, saving: true, notice: "saving" },
      )
    }
    StateSaved(response) =>
      match response {
        Ok(reply) =>
          (@rabbita.none, { ..model, saving: false, notice: reply.message })
        Err(err) =>
          (
            @rabbita.none,
            { ..model, saving: false, notice: "save failed: \{to_repr(err)}" },
          )
      }
    MethodChanged(value) =>
      (
        @rabbita.none,
        with_draft(model, {
          ..model.draft,
          http_method: @core.parse_method(value),
        }),
      )
    UrlChanged(url) =>
      (@rabbita.none, with_draft(model, { ..model.draft, url, }))
    NameChanged(name) =>
      (@rabbita.none, with_draft(model, { ..model.draft, name, }))
    BodyChanged(body) =>
      (@rabbita.none, with_draft(model, { ..model.draft, body, }))
    AddHeader =>
      (
        @rabbita.none,
        with_draft(model, {
          ..model.draft,
          headers: @core.append_header(model.draft.headers),
        }),
      )
    RemoveHeader(index) =>
      (
        @rabbita.none,
        with_draft(model, {
          ..model.draft,
          headers: @core.remove_header(model.draft.headers, index),
        }),
      )
    ToggleHeader(index) =>
      (
        @rabbita.none,
        with_draft(model, {
          ..model.draft,
          headers: @core.update_header(model.draft.headers, index, header => {
            ..header,
            enabled: !header.enabled,
          }),
        }),
      )
    HeaderNameChanged(index, name) =>
      (
        @rabbita.none,
        with_draft(model, {
          ..model.draft,
          headers: @core.update_header(model.draft.headers, index, header => {
            ..header,
            name,
          }),
        }),
      )
    HeaderValueChanged(index, value) =>
      (
        @rabbita.none,
        with_draft(model, {
          ..model.draft,
          headers: @core.update_header(model.draft.headers, index, header => {
            ..header,
            value,
          }),
        }),
      )
    SendRequest => {
      let url = model.draft.url.trim().to_owned()
      if url == "" {
        (@rabbita.none, { ..model, notice: "URL is required" })
      } else {
        (
          send_http_cmd(emit, model.client, { ..model.draft, url, }),
          { ..model, sending: true, response: None, notice: "sending" },
        )
      }
    }
    RequestSent(response) =>
      match response {
        Ok(reply) => {
          let history = @core.HistoryEntry::{
            id: "hist-\{@async.now()}",
            name: @core.display_name(model.draft),
            http_method: model.draft.http_method,
            url: model.draft.url,
            status: reply.status,
            error: reply.error,
            duration_ms: reply.duration_ms,
            created_at_ms: @async.now(),
          }
          let state = {
            ..model.state,
            active_draft: model.draft,
            recent_history: @core.capped_history(
              model.state.recent_history,
              history,
            ),
          }
          (
            save_state_cmd(emit, model.client, state),
            {
              ..model,
              state,
              response: Some(reply),
              sending: false,
              saving: true,
              notice: "response received",
            },
          )
        }
        Err(err) =>
          (
            @rabbita.none,
            {
              ..model,
              sending: false,
              notice: "request failed: \{to_repr(err)}",
            },
          )
      }
    SaveCurrentRequest => {
      let (saved, draft) = @core.upsert_saved_request(
        model.state.saved_requests,
        model.draft,
        new_id=new_request_id(),
      )
      let state = { ..model.state, saved_requests: saved, active_draft: draft }
      (
        save_state_cmd(emit, model.client, state),
        { ..model, state, draft, saving: true, notice: "saving request" },
      )
    }
    SelectSaved(id) => {
      let selected = model.state.saved_requests
        .iter()
        .find_first(request => request.id == id)
      match selected {
        Some(request) => (@rabbita.none, with_draft(model, request))
        None => (@rabbita.none, model)
      }
    }
    DeleteSaved(id) => {
      let saved = @core.delete_saved_request(model.state.saved_requests, id)
      let state = { ..model.state, saved_requests: saved }
      (
        save_state_cmd(emit, model.client, state),
        { ..model, state, saving: true, notice: "deleting request" },
      )
    }
    ClearHistory => {
      let state = { ..model.state, recent_history: [] }
      (
        save_state_cmd(emit, model.client, state),
        { ..model, state, saving: true, notice: "clearing history" },
      )
    }
  }
}
