///|
/// UI-library-agnostic frontend IPC client.
///
/// This package only prepares typed JSON messages. A Rabbita, Luna, or plain DOM
/// layer can decide how to deliver them to the host bridge.
pub struct Client {
  priv next_id : Int
}

///|
extern "js" fn call_bridge(name : String, raw : String) -> Unit =
  #| (name, raw) => {
  #|   const bridge = globalThis[name]
  #|   if (typeof bridge !== "function") {
  #|     throw new Error(`desktop bridge '${name}' is not available`)
  #|   }
  #|   bridge(raw)
  #| }

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
/// Create a frontend IPC client with request ids starting at `req-0`.
pub fn Client::Client() -> Client {
  { next_id: 0 }
}

///|
/// Serialize a one-way event envelope without calling the JavaScript bridge.
pub fn[T : ToJson] Client::event(self : Client, body : T) -> String {
  ignore(self)
  @ipc.Envelope(body).stringify()
}

///|
/// Send a one-way event through the named JavaScript bridge.
pub fn[T : ToJson] Client::emit(self : Client, name : String, body : T) -> Unit {
  call_bridge(name, self.event(body))
}

///|
/// Send a one-way event through the default bridge, `moonbitDesktop`.
pub fn[T : ToJson] Client::emit_default(self : Client, body : T) -> Unit {
  self.emit(@ipc.default_bridge_name(), body)
}

///|
/// Build a request envelope and return the next client state.
pub fn[T : ToJson] Client::request_envelope(
  self : Client,
  body : T,
) -> (Client, String) {
  let id = "req-\{self.next_id}"
  let next = { next_id: self.next_id + 1 }
  (next, @ipc.Envelope(body, id~).stringify())
}

///|
/// Alias of `request_envelope` for callers that do their own bridge call.
pub fn[T : ToJson] Client::request(self : Client, body : T) -> (Client, String) {
  self.request_envelope(body)
}

///|
/// Send a request and deliver the decoded response to a callback.
pub fn[T : ToJson, R : FromJson] Client::request_with_callback(
  self : Client,
  name : String,
  body : T,
  callback : (@ipc.Response[R]) -> Unit,
) -> Client {
  let (next, raw) = self.request_envelope(body)
  call_bridge_response(
    name,
    raw,
    response => {
      let result : @ipc.Response[R] = @json.from_json(@json.parse(response)) catch {
        err => Err(DecodeError(err.to_string()))
      }
      callback(result)
    },
    message => callback(Err(TransportClosed(message))),
  )
  next
}

///|
/// Send a callback-style request through the default bridge.
pub fn[T : ToJson, R : FromJson] Client::request_with_callback_default(
  self : Client,
  body : T,
  callback : (@ipc.Response[R]) -> Unit,
) -> Client {
  self.request_with_callback(@ipc.default_bridge_name(), body, callback)
}

///|
/// Send a request and wait for the JavaScript bridge promise.
pub async fn[T : ToJson, R : FromJson] Client::request_async(
  self : Client,
  name : String,
  body : T,
) -> (Client, @ipc.Response[R]) {
  let (next, raw) = self.request_envelope(body)
  let response = call_bridge_promise(name, raw).wait()
  let result : @ipc.Response[R] = @json.from_json(@json.parse(response)) catch {
    err => Err(DecodeError(err.to_string()))
  }
  (next, result)
}

///|
/// Send an async request through the default bridge.
pub async fn[T : ToJson, R : FromJson] Client::request_async_default(
  self : Client,
  body : T,
) -> (Client, @ipc.Response[R]) {
  self.request_async(@ipc.default_bridge_name(), body)
}

///|
/// Decode a raw event envelope received by frontend-side code.
pub fn[T : FromJson] decode_event(raw : String) -> T raise @ipc.IpcError {
  @ipc.parse_envelope(raw).decode()
}
