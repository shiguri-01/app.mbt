///|
/// UI-library-agnostic frontend IPC client.
pub struct Client {}

///|
extern "js" fn call_bridge_response(
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
  #|     error => reject(String(error)),
  #|   )
  #| }

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
extern "js" fn install_listener(
  name : String,
  callback : (String) -> Unit,
) -> Unit =
  #| (name, callback) => {
  #|   globalThis[name] = raw => callback(String(raw))
  #| }

///|
pub fn Client::Client() -> Client {
  Client::{  }
}

///|
pub fn[T : ToJson] Client::frame(self : Client, body : T) -> String {
  ignore(self)
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
pub fn[T : ToJson, R : FromJson] Client::request_with_callback(
  self : Client,
  name : String,
  body : T,
  callback : (@ipc.IpcResponse[R]) -> Unit,
) -> Unit {
  let raw = self.frame(body)
  call_bridge_response(
    name,
    raw,
    response => callback(decode_response(response)),
    message => callback(Err(TransportClosed(message))),
  )
}

///|
pub fn[T : ToJson, R : FromJson] Client::request_with_callback_default(
  self : Client,
  body : T,
  callback : (@ipc.IpcResponse[R]) -> Unit,
) -> Unit {
  self.request_with_callback(@ipc.default_bridge_name(), body, callback)
}

///|
pub fn[T : ToJson, R : FromJson] Client::request_endpoint_with_callback(
  self : Client,
  endpoint : @ipc.IpcEndpoint[T, R],
  body : T,
  callback : (@ipc.IpcResponse[R]) -> Unit,
) -> Unit {
  self.request_with_callback(endpoint.name(), body, callback)
}

///|
pub async fn[T : ToJson, R : FromJson] Client::request_async(
  self : Client,
  name : String,
  body : T,
) -> @ipc.IpcResponse[R] {
  let response = call_bridge_promise(name, self.frame(body)).wait() catch {
    err => return Err(TransportClosed(err.to_string()))
  }
  decode_response(response)
}

///|
pub async fn[T : ToJson, R : FromJson] Client::request_async_default(
  self : Client,
  body : T,
) -> @ipc.IpcResponse[R] {
  self.request_async(@ipc.default_bridge_name(), body)
}

///|
pub async fn[T : ToJson, R : FromJson] Client::request_endpoint_async(
  self : Client,
  endpoint : @ipc.IpcEndpoint[T, R],
  body : T,
) -> @ipc.IpcResponse[R] {
  self.request_async(endpoint.name(), body)
}

///|
pub fn[E : FromJson] Client::listen(
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
pub fn[E : FromJson] Client::listen_default(
  self : Client,
  callback : (E) -> Unit,
) -> Unit {
  self.listen(@ipc.default_event_name(), callback)
}

///|
pub fn[E : FromJson] Client::listen_event(
  self : Client,
  event : @ipc.IpcEvent[E],
  callback : (E) -> Unit,
) -> Unit {
  self.listen(event.name(), callback)
}
