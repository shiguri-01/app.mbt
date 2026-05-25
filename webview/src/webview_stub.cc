#include "vendor/webview.h"

#include <moonbit.h>

#include <cstring>

struct MoonBitWebView {
  webview_t handle;
  int destroyed;
};

static webview_error_t require_handle(MoonBitWebView *view) {
  if (view == nullptr || view->destroyed || view->handle == nullptr) {
    return WEBVIEW_ERROR_INVALID_STATE;
  }
  return WEBVIEW_ERROR_OK;
}

static webview_error_t destroy_handle(MoonBitWebView *view) {
  if (view == nullptr || view->destroyed || view->handle == nullptr) {
    return WEBVIEW_ERROR_OK;
  }
  webview_error_t status = webview_destroy(view->handle);
  view->handle = nullptr;
  view->destroyed = 1;
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

extern "C" {

MOONBIT_FFI_EXPORT
MoonBitWebView *moonbit_webview_create(int32_t debug) {
  auto *view = static_cast<MoonBitWebView *>(
      moonbit_make_external_object(finalize_webview, sizeof(MoonBitWebView)));
  view->handle = webview_create(debug, nullptr);
  view->destroyed = view->handle == nullptr ? 1 : 0;
  return view;
}

MOONBIT_FFI_EXPORT
int32_t moonbit_webview_is_valid(MoonBitWebView *view) {
  return view != nullptr && !view->destroyed && view->handle != nullptr;
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
  return webview_run(view->handle);
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
moonbit_bytes_t moonbit_webview_version_number(void) {
  const webview_version_info_t *info = webview_version();
  return make_bytes_from_c_string(info == nullptr ? "" : info->version_number);
}

}
