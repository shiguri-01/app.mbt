///|
/// UI-library-agnostic frontend IPC client.
///
/// This package only prepares typed JSON messages. A Rabbita, Luna, or plain DOM
/// layer can decide how to deliver them to the host bridge.
pub struct Client {
  next_id : Int
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
pub fn Client::new() -> Client {
  { next_id: 0 }
}

///|
pub fn[T : ToJson] Client::event(self : Client, body : T) -> String {
  ignore(self)
  @ipc.Envelope::new(body).stringify()
}

///|
pub fn[T : ToJson] Client::emit(self : Client, name : String, body : T) -> Unit {
  call_bridge(name, self.event(body))
}

///|
pub fn[T : ToJson] Client::request_envelope(
  self : Client,
  body : T,
) -> (Client, String) {
  let id = "req-\{self.next_id}"
  let next = { next_id: self.next_id + 1 }
  (next, @ipc.Envelope::new(body, id~).stringify())
}

///|
pub fn[T : ToJson] Client::request(self : Client, body : T) -> (Client, String) {
  self.request_envelope(body)
}

///|
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
        err => Err(@ipc.IpcError::DecodeError(err.to_string()))
      }
      callback(result)
    },
    message => {
      ignore(message)
      callback(Err(@ipc.IpcError::TransportClosed))
    },
  )
  next
}

///|
pub async fn[T : ToJson, R : FromJson] Client::request_async(
  self : Client,
  name : String,
  body : T,
) -> (Client, @ipc.Response[R]) {
  let (next, raw) = self.request_envelope(body)
  let response = call_bridge_promise(name, raw).wait()
  let result : @ipc.Response[R] = @json.from_json(@json.parse(response)) catch {
    err => Err(@ipc.IpcError::DecodeError(err.to_string()))
  }
  (next, result)
}

///|
pub fn[T : FromJson] decode_event(raw : String) -> T raise @ipc.IpcError {
  @ipc.parse_envelope(raw).decode()
}
