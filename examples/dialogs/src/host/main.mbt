///|
async fn dialog_html() -> String {
  guard @env.current_dir() is Some(cwd) else {
    fail("could not determine current directory")
  }
  let html = @fs.read_file(cwd + "/examples/dialogs/static/index.html").text()
  let frontend = @fs.read_file(
    cwd +
    "/_build/js/debug/build/shiguri-01/desktop-dialog-example/frontend/frontend.js",
  ).text()
  html.replace(old="__MOONBIT_DIALOG_FRONTEND__", new=frontend)
}

///|
fn load_dialog_html() -> Result[String, String] {
  let result : Ref[Result[String, String]?] = Ref(None)
  @async.run_async_main(() => {
    let html = dialog_html() catch {
      err => {
        result.val = Some(Err("\{to_repr(err)}"))
        return
      }
    }
    result.val = Some(Ok(html))
  })
  match result.val {
    Some(result) => result
    None => Err("dialog frontend loader finished without a result")
  }
}

///|
fn dialog_choice_from_runtime(
  choice : @desktop.MessageDialogResult,
) -> @shared.DialogChoice {
  match choice {
    @desktop.MessageDialogResult::Ok => ChoiceOk
    @desktop.MessageDialogResult::Cancel => ChoiceCancel
    @desktop.MessageDialogResult::Yes => ChoiceYes
    @desktop.MessageDialogResult::No => ChoiceNo
  }
}

///|
fn show_info_dialog(
  window : @desktop.Window,
) -> @shared.DialogEvent raise @desktop.DesktopError {
  let choice = window.show_message_dialog(
    "The host handled this request with a native message box.",
    title="MoonBit Dialogs",
    kind=Info,
    buttons=Ok,
  )
  DialogClosed(dialog_choice_from_runtime(choice))
}

///|
fn show_warning_dialog(
  window : @desktop.Window,
) -> @shared.DialogEvent raise @desktop.DesktopError {
  let choice = window.show_message_dialog(
    "This demonstrates a warning dialog with OK and Cancel buttons.",
    title="Warning",
    kind=Warning,
    buttons=OkCancel,
  )
  DialogClosed(dialog_choice_from_runtime(choice))
}

///|
fn ask_question_dialog(
  window : @desktop.Window,
) -> @shared.DialogEvent raise @desktop.DesktopError {
  let choice = window.show_message_dialog(
    "Do you want to keep using typed IPC for native dialogs?",
    title="Question",
    kind=Question,
    buttons=YesNoCancel,
  )
  DialogClosed(dialog_choice_from_runtime(choice))
}

///|
fn main {
  let html = match load_dialog_html() {
    Ok(html) => html
    Err(message) => {
      println(
        "failed to load dialog frontend; run `just build-dialogs-example-frontend` first",
      )
      println(message)
      return
    }
  }
  @desktop.run(on_startup=app => {
    let window = app.create_window(
      WindowOptions(
        key="main",
        title="MoonBit Dialogs",
        width=720,
        height=440,
        load=Html(html),
      ),
    )
    window.handle_ipc_endpoint(@shared.show_info_endpoint, handler=_request => {
      show_info_dialog(window)
    })
    window.handle_ipc_endpoint(@shared.show_warning_endpoint, handler=_request => {
      show_warning_dialog(window)
    })
    window.handle_ipc_endpoint(@shared.ask_question_endpoint, handler=_request => {
      ask_question_dialog(window)
    })
  }) catch {
    err => println("desktop runtime failed: \{to_repr(err)}")
  }
}
