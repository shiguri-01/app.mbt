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
      class=if header.enabled { "icon-toggle active" } else { "icon-toggle" },
      title="Toggle header",
      on_click=emit(ToggleHeader(index)),
      if header.enabled {
        "on"
      } else {
        "off"
      },
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
      class="icon-button",
      title="Remove header",
      on_click=emit(RemoveHeader(index)),
      "x",
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
    None => div(class="empty-panel", "No response yet")
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
              h2(class="panel-title", "Headers"),
              pre(
                class="headers-body",
                reply.headers
                .map(header => "\{header.name}: \{header.value}")
                .join("\n"),
              ),
              h2(class="panel-title", "Body"),
              pre(class="response-body", reply.body),
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
      "\{request.http_method.to_string()}  \{@core.display_name(request)}",
    ),
    button(
      class="icon-button",
      title="Delete saved request",
      on_click=emit(DeleteSaved(request.id)),
      "x",
    ),
  ]
}

///|
fn history_row(entry : @contract.HistoryEntry) -> @rabbita.Html {
  let result = match (entry.status, entry.error) {
    (Some(status), _) => "\{status}"
    (_, Some(error)) => error
    _ => "-"
  }
  div(class="history-row") <| [
    span(class="history-method", entry.http_method.to_string()),
    span(class="history-url", entry.url),
    span(class="history-result", result),
    span(class="history-duration", "\{entry.duration_ms} ms"),
  ]
}

///|
fn sidebar(emit : @rabbita.Emit[Msg], model : Model) -> @rabbita.Html {
  div(class="sidebar") <| [
    div(class="sidebar-head") <| [
      h2(class="panel-title", "Saved"),
      button(class="mini-button", on_click=emit(SaveCurrentRequest), "save"),
    ],
    if model.state.saved_requests.is_empty() {
      p(class="muted", "No saved requests")
    } else {
      div(class="saved-list") <| model.state.saved_requests.map(request => {
        saved_request_row(emit, request)
      })
    },
    div(class="sidebar-head spaced") <| [
      h2(class="panel-title", "Recent"),
      button(class="mini-button", on_click=emit(ClearHistory), "clear"),
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
fn request_editor(emit : @rabbita.Emit[Msg], model : Model) -> @rabbita.Html {
  div(class="editor") <| [
    div(class="topbar") <| [
      h1("HTTP/API Workbench"),
      div(class="top-actions") <| [
        span(
          class="notice",
          if model.loading {
            "loading state"
          } else {
            model.notice
          },
        ),
        button(
          class="secondary",
          disabled=model.saving,
          on_click=emit(SaveWorkspace),
          if model.saving {
            "saving"
          } else {
            "save state"
          },
        ),
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
          "sending"
        } else {
          "send"
        },
      ),
    ],
    section(class="request-panel") <| [
      div(class="panel-head") <| [
        h2(class="panel-title", "Headers"),
        button(class="mini-button", on_click=emit(AddHeader), "add"),
      ],
      div(class="headers-grid") <| header_rows(emit, model.draft.headers),
    ],
    section(class="request-panel") <| [
      h2(class="panel-title", "Body"),
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
