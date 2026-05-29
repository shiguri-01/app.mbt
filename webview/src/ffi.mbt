///|
extern "C" fn ffi_create(debug : Bool) -> RawWebView = "moonbit_webview_create"

///|
#borrow(view)
extern "C" fn ffi_is_valid(view : RawWebView) -> Bool = "moonbit_webview_is_valid"

///|
#borrow(view)
extern "C" fn ffi_has_native_window(view : RawWebView) -> Bool = "moonbit_webview_has_native_window"

///|
#borrow(view)
extern "C" fn ffi_get_native_window(view : RawWebView) -> NativeWindow = "moonbit_webview_get_native_window"

///|
#borrow(view)
extern "C" fn ffi_destroy(view : RawWebView) -> Int = "moonbit_webview_destroy"

///|
#borrow(view)
extern "C" fn ffi_run(view : RawWebView) -> Int = "moonbit_webview_run"

///|
#borrow(view)
extern "C" fn ffi_terminate(view : RawWebView) -> Int = "moonbit_webview_terminate"

///|
#borrow(view, title)
extern "C" fn ffi_set_title(view : RawWebView, title : Bytes) -> Int = "moonbit_webview_set_title"

///|
#borrow(view)
extern "C" fn ffi_set_size(
  view : RawWebView,
  width : Int,
  height : Int,
  hint : Int,
) -> Int = "moonbit_webview_set_size"

///|
#borrow(view, url)
extern "C" fn ffi_navigate(view : RawWebView, url : Bytes) -> Int = "moonbit_webview_navigate"

///|
#borrow(view, html)
extern "C" fn ffi_set_html(view : RawWebView, html : Bytes) -> Int = "moonbit_webview_set_html"

///|
#borrow(view, js)
extern "C" fn ffi_init(view : RawWebView, js : Bytes) -> Int = "moonbit_webview_init"

///|
#borrow(view, js)
extern "C" fn ffi_eval(view : RawWebView, js : Bytes) -> Int = "moonbit_webview_eval"

///|
#borrow(view, name)
extern "C" fn ffi_bind(
  view : RawWebView,
  name : Bytes,
  call_handler : FuncRef[((Bytes, Bytes) -> Unit, Bytes, Bytes) -> Unit],
  handler : (Bytes, Bytes) -> Unit,
) -> Int = "moonbit_webview_bind"

///|
#borrow(view, name)
extern "C" fn ffi_unbind(view : RawWebView, name : Bytes) -> Int = "moonbit_webview_unbind"

///|
#borrow(view, id, result)
extern "C" fn ffi_return(
  view : RawWebView,
  id : Bytes,
  status : Int,
  result : Bytes,
) -> Int = "moonbit_webview_return"

///|
#borrow(view)
extern "C" fn ffi_dispatch(
  view : RawWebView,
  call_handler : FuncRef[(() -> Unit) -> Unit],
  handler : () -> Unit,
) -> Int = "moonbit_webview_dispatch"

///|
#borrow(view)
extern "C" fn ffi_close_window(view : RawWebView) -> Int = "moonbit_webview_close_window"

///|
#borrow(view)
extern "C" fn ffi_focus_window(view : RawWebView) -> Int = "moonbit_webview_focus_window"

///|
#borrow(view)
extern "C" fn ffi_minimize_window(view : RawWebView) -> Int = "moonbit_webview_minimize_window"

///|
#borrow(view)
extern "C" fn ffi_maximize_window(view : RawWebView) -> Int = "moonbit_webview_maximize_window"

///|
#borrow(view)
extern "C" fn ffi_restore_window(view : RawWebView) -> Int = "moonbit_webview_restore_window"

///|
#borrow(view)
extern "C" fn ffi_show_window(view : RawWebView) -> Int = "moonbit_webview_show_window"

///|
#borrow(view)
extern "C" fn ffi_hide_window(view : RawWebView) -> Int = "moonbit_webview_hide_window"

///|
#borrow(view)
extern "C" fn ffi_is_window_closed(view : RawWebView) -> Bool = "moonbit_webview_is_window_closed"

///|
#borrow(view)
extern "C" fn ffi_set_window_event_handler(
  view : RawWebView,
  call_handler : FuncRef[((Int) -> Unit, Int) -> Unit],
  handler : (Int) -> Unit,
) -> Int = "moonbit_webview_set_window_event_handler"

///|
extern "C" fn ffi_version_number() -> Bytes = "moonbit_webview_version_number"
