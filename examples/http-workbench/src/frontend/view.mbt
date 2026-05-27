///|
using @html {
  button,
  div,
  h1,
  h2,
  input,
  label,
  main_,
  nothing,
  option,
  p,
  pre,
  section,
  select,
  span,
  textarea,
}

///|
fn method_option(
  http_method : @contract.HttpMethod,
  current : @contract.HttpMethod,
) -> @rabbita.Html {
  let label = http_method.to_string()
  option(value=label, selected=http_method == current, label)
}

///|
fn header_row(
  emit : @rabbita.Emit[Msg],
  index : Int,
  header : @contract.Header,
) -> @rabbita.Html {
  div(class="header-row") <| [
    button(
      class=if header.enabled {
        "switch-toggle active"
      } else {
        "switch-toggle"
      },
      title=if header.enabled { "Disable header" } else { "Enable header" },
      on_click=emit(ToggleHeader(index)),
      span(class="switch-knob", ""),
    ),
    input(
      class="header-name",
      value=header.name,
      placeholder="Header",
      on_input=emit.map(value => HeaderNameChanged(index, value)),
      nothing,
    ),
    input(
      class="header-value",
      value=header.value,
      placeholder="Value",
      on_input=emit.map(value => HeaderValueChanged(index, value)),
      nothing,
    ),
    button(
      class="icon-button danger",
      title="Remove header",
      on_click=emit(RemoveHeader(index)),
      "Remove",
    ),
  ]
}

///|
fn header_rows(
  emit : @rabbita.Emit[Msg],
  headers : Array[@contract.Header],
) -> Array[@rabbita.Html] {
  let rows = []
  let mut index = 0
  for header in headers {
    rows.push(header_row(emit, index, header))
    index = index + 1
  }
  rows
}

///|
fn response_view(response : @contract.SendHttpReply?) -> @rabbita.Html {
  match response {
    None => div(class="empty-panel", "Response")
    Some(reply) => {
      let status = match reply.status {
        Some(code) => "\{code} \{reply.status_text}"
        None => "Request error"
      }
      section(class="response-panel") <| [
        div(class="response-meta") <| [
          span(class="status-code", status),
          span(class="duration", "\{reply.duration_ms} ms"),
        ],
        match reply.error {
          Some(error) => pre(class="error-body", error)
          None =>
            div(class="response-content") <| [
              h2(class="panel-title", "Response headers"),
              pre(
                class="headers-body",
                if reply.headers.is_empty() {
                  "(none)"
                } else {
                  reply.headers
                  .map(header => "\{header.name}: \{header.value}")
                  .join("\n")
                },
              ),
              h2(class="panel-title", "Response body"),
              pre(
                class="response-body",
                if reply.body == "" {
                  "(empty)"
                } else {
                  reply.body
                },
              ),
            ]
        },
      ]
    }
  }
}

///|
fn saved_request_row(
  emit : @rabbita.Emit[Msg],
  request : @contract.SavedRequest,
) -> @rabbita.Html {
  div(class="saved-row") <| [
    button(
      class="saved-main",
      title="Load request",
      on_click=emit(SelectSaved(request.id)),
      "\{request.http_method.to_string()} \{@core.display_name(request)}",
    ),
    button(
      class="icon-button danger saved-remove",
      title="Delete saved request",
      on_click=emit(DeleteSaved(request.id)),
      "Del",
    ),
  ]
}

///|
fn history_status_text(entry : @contract.HistoryEntry) -> String {
  match (entry.status, entry.error) {
    (Some(status), _) => "\{status}"
    (_, Some(_)) => "Error"
    _ => "Pending"
  }
}

///|
fn history_status_class(entry : @contract.HistoryEntry) -> String {
  match (entry.status, entry.error) {
    (_, Some(_)) => "history-status error"
    (Some(status), _) =>
      if status >= 200 && status < 300 {
        "history-status ok"
      } else if status >= 300 && status < 400 {
        "history-status redirect"
      } else if status >= 400 {
        "history-status bad"
      } else {
        "history-status"
      }
    _ => "history-status"
  }
}

///|
fn history_row(entry : @contract.HistoryEntry) -> @rabbita.Html {
  div(class="history-row") <| [
    div(class="history-main") <| [
      span(class="history-name", entry.name),
      span(class=history_status_class(entry), history_status_text(entry)),
    ],
    div(class="history-detail") <| [
      span(class="history-method", entry.http_method.to_string()),
      span(class="history-url", title=entry.url, entry.url),
      span(class="history-duration", "\{entry.duration_ms} ms"),
    ],
  ]
}

///|
fn sidebar(emit : @rabbita.Emit[Msg], model : Model) -> @rabbita.Html {
  div(class="sidebar") <| [
    div(class="sidebar-head") <| [
      h2(class="panel-title", "Requests"),
      button(class="mini-button", on_click=emit(NewRequest), "New"),
    ],
    if model.state.saved_requests.is_empty() {
      p(class="muted", "No saved requests")
    } else {
      div(class="saved-list") <| model.state.saved_requests.map(request => {
        saved_request_row(emit, request)
      })
    },
    div(class="sidebar-head spaced") <| [
      h2(class="panel-title", "History"),
      button(class="mini-button", on_click=emit(ClearHistory), "Clear"),
    ],
    if model.state.recent_history.is_empty() {
      p(class="muted", "No history")
    } else {
      div(class="history-list") <| model.state.recent_history.map(entry => {
        history_row(entry)
      })
    },
  ]
}

///|
fn notice_view(model : Model) -> @rabbita.Html {
  if model.loading {
    span(class="notice", "Loading")
  } else if model.notice.contains("failed") ||
    model.notice.contains("Failed") ||
    model.notice.contains("required") {
    span(class="notice", model.notice)
  } else {
    nothing
  }
}

///|
fn request_editor(emit : @rabbita.Emit[Msg], model : Model) -> @rabbita.Html {
  div(class="editor") <| [
    div(class="topbar") <| [
      h1("HTTP/API Workbench"),
      div(class="top-actions") <| [
        notice_view(model),
      ],
    ],
    div(class="name-row") <| [
      label(class="field-label", "Name"),
      input(
        class="request-name",
        value=model.draft.name,
        placeholder="Request name",
        on_input=emit.map(value => NameChanged(value)),
        nothing,
      ),
      button(
        class="secondary name-save",
        disabled=model.saving,
        on_click=emit(SaveCurrentRequest),
        "Save request",
      ),
    ],
    div(class="request-line") <| [
      select(
        class="method-select",
        on_change=emit.map(value => MethodChanged(value)),
        [
          method_option(Get, model.draft.http_method),
          method_option(Post, model.draft.http_method),
          method_option(Put, model.draft.http_method),
          method_option(Patch, model.draft.http_method),
          method_option(Delete, model.draft.http_method),
          method_option(Head, model.draft.http_method),
          method_option(Options, model.draft.http_method),
        ],
      ),
      input(
        class="url-input",
        value=model.draft.url,
        placeholder="https://api.example.com/v1/items",
        on_input=emit.map(value => UrlChanged(value)),
        nothing,
      ),
      button(
        class="primary send-button",
        disabled=model.sending,
        on_click=emit(SendRequest),
        if model.sending {
          "Sending"
        } else {
          "Send"
        },
      ),
    ],
    section(class="request-panel") <| [
      div(class="panel-head") <| [
        h2(class="panel-title", "Request headers"),
        button(class="mini-button", on_click=emit(AddHeader), "Add header"),
      ],
      div(class="headers-grid") <| header_rows(emit, model.draft.headers),
    ],
    section(class="request-panel") <| [
      h2(class="panel-title", "Request body"),
      textarea(
        class="body-editor",
        rows=10,
        value=model.draft.body,
        placeholder="{\n  \"hello\": \"world\"\n}",
        on_input=emit.map(value => BodyChanged(value)),
        nothing,
      ),
    ],
    response_view(model.response),
  ]
}

///|
fn view(emit : @rabbita.Emit[Msg], model : Model) -> @rabbita.Html {
  main_(class="app-shell") <| [
    startup_loader(emit, model),
    sidebar(emit, model),
    request_editor(emit, model),
  ]
}

///|
fn startup_loader(emit : @rabbita.Emit[Msg], model : Model) -> @rabbita.Html {
  if model.notice == "ready" && !model.loading {
    // Rabbita's with_init queues commands before the app finishes initializing.
    // Trigger LoadState as a normal DOM event after mount instead.
    button(id="workbench-load-state", hidden=true, on_click=emit(LoadState), "")
  } else {
    nothing
  }
}
