///|
#borrow(parent, message, title)
extern "C" fn ffi_show_message_dialog(
  parent : @webview.NativeWindow,
  message : Bytes,
  title : Bytes,
  kind : Int,
  buttons : Int,
) -> Int = "moonbit_desktop_show_message_dialog"

///|
priv type FileDialogResult

///|
#borrow(parent, filter_names, filter_specs, default_path, default_name)
extern "C" fn ffi_show_file_dialog(
  parent : @webview.NativeWindow,
  kind : Int,
  filter_names : Bytes,
  filter_specs : Bytes,
  default_path : Bytes,
  default_name : Bytes,
) -> FileDialogResult = "moonbit_desktop_show_file_dialog"

///|
#borrow(result)
extern "C" fn ffi_file_dialog_result_status(result : FileDialogResult) -> Int = "moonbit_desktop_file_dialog_result_status"

///|
#borrow(result)
extern "C" fn ffi_file_dialog_result_len(result : FileDialogResult) -> Int = "moonbit_desktop_file_dialog_result_len"

///|
#borrow(result)
extern "C" fn ffi_file_dialog_result_path_at(
  result : FileDialogResult,
  index : Int,
) -> Bytes = "moonbit_desktop_file_dialog_result_path_at"

///|
#borrow(result)
extern "C" fn ffi_file_dialog_result_error(result : FileDialogResult) -> Bytes = "moonbit_desktop_file_dialog_result_error"
