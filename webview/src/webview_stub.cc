#include "vendor/webview.h"

#include <moonbit.h>

#include <cstring>
#include <string>
#include <vector>

typedef void (*MoonBitWebViewBindingCallback)(void *, moonbit_bytes_t,
                                              moonbit_bytes_t);
typedef void (*MoonBitWebViewDispatchCallback)(void *);
typedef void (*MoonBitWebViewWindowEventCallback)(void *, int32_t);

struct MoonBitWebViewBinding {
  std::string name;
  MoonBitWebViewBindingCallback callback;
  void *closure;
};

struct MoonBitWebView {
  webview_t handle;
  int destroyed;
  int window_closed;
  int closing_window;
  std::vector<MoonBitWebViewBinding *> bindings;
  MoonBitWebViewWindowEventCallback window_event_callback;
  void *window_event_closure;
};

struct MoonBitWebViewDispatch {
  MoonBitWebViewDispatchCallback callback;
  void *closure;
};

struct MoonBitWebViewWindowEventDispatch {
  MoonBitWebView *view;
  int32_t code;
};

static webview_error_t require_handle(MoonBitWebView *view) {
  if (view == nullptr || view->destroyed || view->handle == nullptr) {
    return WEBVIEW_ERROR_INVALID_STATE;
  }
  return WEBVIEW_ERROR_OK;
}

static webview_error_t require_native_window(MoonBitWebView *view,
                                             void **window) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
  void *native_window = webview_get_window(view->handle);
  if (native_window == nullptr || view->window_closed) {
    return WEBVIEW_ERROR_INVALID_STATE;
  }
  *window = native_window;
  return WEBVIEW_ERROR_OK;
}

static void emit_window_event(MoonBitWebView *view, int32_t code) {
  if (view == nullptr || view->window_event_callback == nullptr ||
      view->window_event_closure == nullptr) {
    return;
  }
  moonbit_incref(view->window_event_closure);
  view->window_event_callback(view->window_event_closure, code);
  moonbit_decref(view->window_event_closure);
}

static void moonbit_webview_window_event_dispatch_trampoline(webview_t,
                                                             void *arg) {
  auto *event = static_cast<MoonBitWebViewWindowEventDispatch *>(arg);
  if (event != nullptr) {
    emit_window_event(event->view, event->code);
    delete event;
  }
}

static void dispatch_window_event(MoonBitWebView *view, int32_t code) {
  if (view == nullptr || view->destroyed || view->handle == nullptr) {
    return;
  }
  auto *event = new MoonBitWebViewWindowEventDispatch{view, code};
  webview_error_t status = webview_dispatch(
      view->handle, moonbit_webview_window_event_dispatch_trampoline, event);
  if (status != WEBVIEW_ERROR_OK) {
    delete event;
  }
}

static webview_error_t destroy_handle(MoonBitWebView *view) {
  if (view == nullptr || view->destroyed || view->handle == nullptr) {
    return WEBVIEW_ERROR_OK;
  }
  webview_error_t status = webview_destroy(view->handle);
  view->handle = nullptr;
  view->destroyed = 1;
  for (auto *binding : view->bindings) {
    if (binding != nullptr) {
      if (binding->closure != nullptr) {
        moonbit_decref(binding->closure);
        binding->closure = nullptr;
      }
      delete binding;
    }
  }
  view->bindings.clear();
  if (view->window_event_closure != nullptr) {
    moonbit_decref(view->window_event_closure);
    view->window_event_closure = nullptr;
  }
  view->window_event_callback = nullptr;
  return status;
}

static void finalize_webview(void *ptr) {
  (void)destroy_handle(static_cast<MoonBitWebView *>(ptr));
}

static const char *as_c_string(moonbit_bytes_t bytes) {
  return reinterpret_cast<const char *>(bytes);
}

static moonbit_bytes_t make_bytes_from_c_string(const char *text) {
  if (text == nullptr) {
    return moonbit_make_bytes(0, 0);
  }
  int32_t len = static_cast<int32_t>(std::strlen(text));
  moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
  std::memcpy(bytes, text, static_cast<size_t>(len));
  return bytes;
}

static void moonbit_webview_binding_trampoline(const char *id, const char *req,
                                               void *arg) {
  auto *binding = static_cast<MoonBitWebViewBinding *>(arg);
  if (binding == nullptr || binding->callback == nullptr ||
      binding->closure == nullptr) {
    return;
  }
  moonbit_bytes_t id_bytes = make_bytes_from_c_string(id);
  moonbit_bytes_t req_bytes = make_bytes_from_c_string(req);
  moonbit_incref(binding->closure);
  binding->callback(binding->closure, id_bytes, req_bytes);
  moonbit_decref(binding->closure);
  moonbit_decref(id_bytes);
  moonbit_decref(req_bytes);
}

static void moonbit_webview_dispatch_trampoline(webview_t, void *arg) {
  auto *dispatch = static_cast<MoonBitWebViewDispatch *>(arg);
  if (dispatch == nullptr) {
    return;
  }
  if (dispatch->callback != nullptr && dispatch->closure != nullptr) {
    moonbit_incref(dispatch->closure);
    dispatch->callback(dispatch->closure);
    moonbit_decref(dispatch->closure);
  }
  if (dispatch->closure != nullptr) {
    moonbit_decref(dispatch->closure);
  }
  delete dispatch;
}

extern "C" {

MOONBIT_FFI_EXPORT
MoonBitWebView *moonbit_webview_create(int32_t debug) {
  auto *view = static_cast<MoonBitWebView *>(
      moonbit_make_external_object(finalize_webview, sizeof(MoonBitWebView)));
  view->handle = webview_create(debug, nullptr);
  view->destroyed = view->handle == nullptr ? 1 : 0;
  view->window_closed = view->destroyed;
  view->closing_window = 0;
  view->window_event_callback = nullptr;
  view->window_event_closure = nullptr;
  return view;
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_is_valid(MoonBitWebView *view) {
  return view != nullptr && !view->destroyed && view->handle != nullptr;
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_has_native_window(MoonBitWebView *view) {
  return require_handle(view) == WEBVIEW_ERROR_OK &&
         !view->window_closed &&
         webview_get_window(view->handle) != nullptr;
}

MOONBIT_FFI_EXPORT
void *moonbit_webview_get_native_window(MoonBitWebView *view) {
  void *window{};
  if (require_native_window(view, &window) != WEBVIEW_ERROR_OK) {
    return nullptr;
  }
  return window;
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_destroy(MoonBitWebView *view) {
  return destroy_handle(view);
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_run(MoonBitWebView *view) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
  moonbit_incref(view);
  status = webview_run(view->handle);
  moonbit_decref(view);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_terminate(MoonBitWebView *view) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
  return webview_terminate(view->handle);
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_set_title(MoonBitWebView *view, moonbit_bytes_t title) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
  return webview_set_title(view->handle, as_c_string(title));
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_set_size(MoonBitWebView *view, int32_t width,
                                 int32_t height, int32_t hint) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
  return webview_set_size(view->handle, width, height,
                          static_cast<webview_hint_t>(hint));
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_navigate(MoonBitWebView *view, moonbit_bytes_t url) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
  return webview_navigate(view->handle, as_c_string(url));
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_set_html(MoonBitWebView *view, moonbit_bytes_t html) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
  return webview_set_html(view->handle, as_c_string(html));
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_init(MoonBitWebView *view, moonbit_bytes_t js) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
  return webview_init(view->handle, as_c_string(js));
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_eval(MoonBitWebView *view, moonbit_bytes_t js) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
  return webview_eval(view->handle, as_c_string(js));
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_bind(MoonBitWebView *view, moonbit_bytes_t name,
                             MoonBitWebViewBindingCallback callback,
                             void *closure) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    moonbit_decref(closure);
    return status;
  }
  const char *name_text = as_c_string(name);
  auto *binding = new MoonBitWebViewBinding{name_text, callback, closure};
  view->bindings.push_back(binding);
  status = webview_bind(view->handle, name_text,
                        moonbit_webview_binding_trampoline, binding);
  if (status != WEBVIEW_ERROR_OK) {
    moonbit_decref(closure);
    view->bindings.pop_back();
    delete binding;
  }
  return status;
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_unbind(MoonBitWebView *view, moonbit_bytes_t name) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
  const char *name_text = as_c_string(name);
  status = webview_unbind(view->handle, name_text);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
  for (auto it = view->bindings.begin(); it != view->bindings.end(); ++it) {
    auto *binding = *it;
    if (binding != nullptr && binding->name == name_text) {
      if (binding->closure != nullptr) {
        moonbit_decref(binding->closure);
      }
      view->bindings.erase(it);
      delete binding;
      break;
    }
  }
  return status;
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_return(MoonBitWebView *view, moonbit_bytes_t id,
                               int32_t status, moonbit_bytes_t result) {
  webview_error_t view_status = require_handle(view);
  if (view_status != WEBVIEW_ERROR_OK) {
    return view_status;
  }
  return webview_return(view->handle, as_c_string(id), status,
                        as_c_string(result));
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_dispatch(MoonBitWebView *view,
                                 MoonBitWebViewDispatchCallback callback,
                                 void *closure) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    moonbit_decref(closure);
    return status;
  }
  auto *dispatch = new MoonBitWebViewDispatch{callback, closure};
  status = webview_dispatch(view->handle, moonbit_webview_dispatch_trampoline,
                            dispatch);
  if (status != WEBVIEW_ERROR_OK) {
    moonbit_decref(closure);
    delete dispatch;
  }
  return status;
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_close_window(MoonBitWebView *view) {
  void *native_window{};
  webview_error_t status = require_native_window(view, &native_window);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
#if defined(_WIN32)
  HWND hwnd = static_cast<HWND>(native_window);
  view->closing_window = 1;
  DestroyWindow(hwnd);
  view->closing_window = 0;
  view->window_closed = 1;
  emit_window_event(view, 2);
  return WEBVIEW_ERROR_OK;
#else
  return WEBVIEW_ERROR_INVALID_STATE;
#endif
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_focus_window(MoonBitWebView *view) {
  void *native_window{};
  webview_error_t status = require_native_window(view, &native_window);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
#if defined(_WIN32)
  HWND hwnd = static_cast<HWND>(native_window);
  ShowWindow(hwnd, SW_SHOWNORMAL);
  SetForegroundWindow(hwnd);
  SetFocus(hwnd);
  return WEBVIEW_ERROR_OK;
#else
  return WEBVIEW_ERROR_INVALID_STATE;
#endif
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_minimize_window(MoonBitWebView *view) {
  void *native_window{};
  webview_error_t status = require_native_window(view, &native_window);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
#if defined(_WIN32)
  ShowWindow(static_cast<HWND>(native_window), SW_MINIMIZE);
  return WEBVIEW_ERROR_OK;
#else
  return WEBVIEW_ERROR_INVALID_STATE;
#endif
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_maximize_window(MoonBitWebView *view) {
  void *native_window{};
  webview_error_t status = require_native_window(view, &native_window);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
#if defined(_WIN32)
  ShowWindow(static_cast<HWND>(native_window), SW_MAXIMIZE);
  return WEBVIEW_ERROR_OK;
#else
  return WEBVIEW_ERROR_INVALID_STATE;
#endif
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_restore_window(MoonBitWebView *view) {
  void *native_window{};
  webview_error_t status = require_native_window(view, &native_window);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
#if defined(_WIN32)
  ShowWindow(static_cast<HWND>(native_window), SW_RESTORE);
  return WEBVIEW_ERROR_OK;
#else
  return WEBVIEW_ERROR_INVALID_STATE;
#endif
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_show_window(MoonBitWebView *view) {
  void *native_window{};
  webview_error_t status = require_native_window(view, &native_window);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
#if defined(_WIN32)
  ShowWindow(static_cast<HWND>(native_window), SW_SHOW);
  return WEBVIEW_ERROR_OK;
#else
  return WEBVIEW_ERROR_INVALID_STATE;
#endif
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_hide_window(MoonBitWebView *view) {
  void *native_window{};
  webview_error_t status = require_native_window(view, &native_window);
  if (status != WEBVIEW_ERROR_OK) {
    return status;
  }
#if defined(_WIN32)
  ShowWindow(static_cast<HWND>(native_window), SW_HIDE);
  return WEBVIEW_ERROR_OK;
#else
  return WEBVIEW_ERROR_INVALID_STATE;
#endif
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_is_window_closed(MoonBitWebView *view) {
  return view == nullptr || view->window_closed;
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_set_window_event_handler(
    MoonBitWebView *view, MoonBitWebViewWindowEventCallback callback,
    void *closure) {
  webview_error_t status = require_handle(view);
  if (status != WEBVIEW_ERROR_OK) {
    moonbit_decref(closure);
    return status;
  }
#if defined(_WIN32)
  if (view->window_event_closure != nullptr) {
    moonbit_decref(view->window_event_closure);
  }
  view->window_event_callback = callback;
  view->window_event_closure = closure;
  return WEBVIEW_ERROR_OK;
#else
  (void)callback;
  moonbit_decref(closure);
  (void)closure;
  return WEBVIEW_ERROR_INVALID_STATE;
#endif
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t moonbit_webview_version_number(void) {
  const webview_version_info_t *info = webview_version();
  return make_bytes_from_c_string(info == nullptr ? "" : info->version_number);
}

}
