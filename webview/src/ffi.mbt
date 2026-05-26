///|
extern "C" fn ffi_create(debug : Bool) -> WebView = "moonbit_webview_create"

///|
#borrow(view)
extern "C" fn ffi_is_valid(view : WebView) -> Bool = "moonbit_webview_is_valid"

///|
#borrow(view)
extern "C" fn ffi_has_native_window(view : WebView) -> Bool = "moonbit_webview_has_native_window"

///|
#borrow(view)
extern "C" fn ffi_get_native_window(view : WebView) -> NativeWindow = "moonbit_webview_get_native_window"

///|
#borrow(view)
extern "C" fn ffi_destroy(view : WebView) -> Int = "moonbit_webview_destroy"

///|
#borrow(view)
extern "C" fn ffi_run(view : WebView) -> Int = "moonbit_webview_run"

///|
#borrow(view)
extern "C" fn ffi_terminate(view : WebView) -> Int = "moonbit_webview_terminate"

///|
#borrow(view, title)
extern "C" fn ffi_set_title(view : WebView, title : Bytes) -> Int = "moonbit_webview_set_title"

///|
#borrow(view)
extern "C" fn ffi_set_size(
  view : WebView,
  width : Int,
  height : Int,
  hint : Int,
) -> Int = "moonbit_webview_set_size"

///|
#borrow(view, url)
extern "C" fn ffi_navigate(view : WebView, url : Bytes) -> Int = "moonbit_webview_navigate"

///|
#borrow(view, html)
extern "C" fn ffi_set_html(view : WebView, html : Bytes) -> Int = "moonbit_webview_set_html"

///|
#borrow(view, js)
extern "C" fn ffi_init(view : WebView, js : Bytes) -> Int = "moonbit_webview_init"

///|
#borrow(view, js)
extern "C" fn ffi_eval(view : WebView, js : Bytes) -> Int = "moonbit_webview_eval"

///|
#borrow(view, name)
extern "C" fn ffi_bind(
  view : WebView,
  name : Bytes,
  call_handler : FuncRef[((Bytes, Bytes) -> Unit, Bytes, Bytes) -> Unit],
  handler : (Bytes, Bytes) -> Unit,
) -> Int = "moonbit_webview_bind"

///|
#borrow(view, name)
extern "C" fn ffi_unbind(view : WebView, name : Bytes) -> Int = "moonbit_webview_unbind"

///|
#borrow(view, id, result)
extern "C" fn ffi_return(
  view : WebView,
  id : Bytes,
  status : Int,
  result : Bytes,
) -> Int = "moonbit_webview_return"

///|
#borrow(view)
extern "C" fn ffi_dispatch(
  view : WebView,
  call_handler : FuncRef[(() -> Unit) -> Unit],
  handler : () -> Unit,
) -> Int = "moonbit_webview_dispatch"

///|
extern "C" fn ffi_version_number() -> Bytes = "moonbit_webview_version_number"
