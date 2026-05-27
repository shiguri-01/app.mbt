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
pub async fn[T : ToJson, R : FromJson] Client::request(
  self : Client,
  endpoint : @ipc.IpcEndpoint[T, R],
  body : T,
) -> @ipc.IpcResponse[R] {
  self.request_raw(endpoint.name(), body)
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
pub fn[E : FromJson] Client::listen(
  self : Client,
  event : @ipc.IpcEvent[E],
  callback : (E) -> Unit,
) -> Unit {
  self.listen_raw(event.name(), callback)
}
