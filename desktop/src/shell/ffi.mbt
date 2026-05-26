///|
#borrow(parent, message, title)
extern "C" fn ffi_show_message_dialog(
  parent : @webview.NativeWindow,
  message : Bytes,
  title : Bytes,
  kind : Int,
  buttons : Int,
) -> Int = "moonbit_desktop_show_message_dialog"
