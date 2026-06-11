///|
/// UI-library-agnostic frontend IPC client.
pub struct Client {}

///|
extern "js" fn call_bridge_promise(
  name : String,
  raw : String,
) -> @js_async.Promise[String] =
  #| (name, raw) => {
  #|   const bridge = globalThis[name]
  #|   if (typeof bridge !== "function") {
  #|     return Promise.reject(new Error(`desktop bridge '${name}' is not available`))
  #|   }
  #|   return bridge(raw).then(value => JSON.stringify(value))
  #| }

///|
extern "js" fn call_bridge_callback(
  name : String,
  raw : String,
  resolve : (String) -> Unit,
  reject : (String) -> Unit,
) -> Unit =
  #| (name, raw, resolve, reject) => {
  #|   const bridge = globalThis[name]
  #|   if (typeof bridge !== "function") {
  #|     reject(`desktop bridge '${name}' is not available`)
  #|     return
  #|   }
  #|   bridge(raw).then(
  #|     value => resolve(JSON.stringify(value)),
  #|     error => reject(String(error && (error.stack || error.message) || error)),
  #|   )
  #| }

///|
extern "js" fn install_listener(
  name : String,
  callback : (String) -> Unit,
) -> Unit =
  #| (name, callback) => {
  #|   globalThis[name] = raw => callback(String(raw))
  #| }

///|
/// Create a frontend IPC client using the default desktop bridge.
#warnings("-unnecessary_annotation")
pub fn Client::Client() -> Client {
  Client::{  }
}

///|
fn[T : ToJson] encode_request_frame(body : T) -> String {
  @ipc.RequestFrame(body).stringify()
}

///|
fn[R : FromJson] decode_response(raw : String) -> @ipc.IpcResponse[R] {
  let frame : @ipc.ResponseFrame[R] = @ipc.parse_response_frame(raw) catch {
    err => return Err(err)
  }
  frame.response
}

///|
async fn[T : ToJson, R : FromJson] Client::request_raw(
  self : Client,
  name : String,
  body : T,
) -> @ipc.IpcResponse[R] {
  ignore(self)
  let response = call_bridge_promise(name, encode_request_frame(body)).wait() catch {
    err => return Err(TransportClosed(err.to_string()))
  }
  decode_response(response)
}

///|
/// Call a typed IPC endpoint through the desktop JavaScript bridge.
pub async fn[T : ToJson, R : FromJson] Client::request(
  self : Client,
  endpoint : @ipc.IpcEndpoint[T, R],
  body : T,
) -> @ipc.IpcResponse[R] {
  self.request_raw(endpoint.name(), body)
}

///|
fn[T : ToJson, R : FromJson] Client::request_raw_callback(
  self : Client,
  name : String,
  body : T,
  callback : (@ipc.IpcResponse[R]) -> Unit,
) -> Unit {
  ignore(self)
  call_bridge_callback(
    name,
    encode_request_frame(body),
    raw => callback(decode_response(raw)),
    message => callback(Err(TransportClosed(message))),
  )
}

///|
/// Call an IPC endpoint and report the response through a JavaScript callback.
///
/// This is useful for UI runtimes that already own their own scheduler and
/// should not block on `moonbitlang/async/js_async.Promise::wait`.
pub fn[T : ToJson, R : FromJson] Client::request_callback(
  self : Client,
  endpoint : @ipc.IpcEndpoint[T, R],
  body : T,
  callback : (@ipc.IpcResponse[R]) -> Unit,
) -> Unit {
  self.request_raw_callback(endpoint.name(), body, callback)
}

///|
fn[E : FromJson] Client::listen_raw(
  self : Client,
  name : String,
  callback : (E) -> Unit,
) -> Unit {
  ignore(self)
  install_listener(name, raw => {
    let frame = @ipc.parse_request_frame(raw) catch { _ => return }
    let event : E = frame.decode() catch { _ => return }
    callback(event)
  })
}

///|
/// Listen for a typed host-to-frontend event.
pub fn[E : FromJson] Client::listen(
  self : Client,
  event : @ipc.IpcEvent[E],
  callback : (E) -> Unit,
) -> Unit {
  self.listen_raw(event.name(), callback)
}
