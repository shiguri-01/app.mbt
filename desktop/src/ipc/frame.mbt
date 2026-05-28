///|
let ipc_version : Int = 1

///|
fn[T] json_decode_error(
  path : @json.JsonPath,
  message : String,
) -> T raise @json.JsonDecodeError {
  raise @json.JsonDecodeError((path, message))
}

///|
fn field(
  object : Map[String, Json],
  key : String,
  path : @json.JsonPath,
) -> Json raise @json.JsonDecodeError {
  match object.get(key) {
    Some(value) => value
    None => json_decode_error(path.add_key(key), "missing field '\{key}'")
  }
}

///|
fn int_field(
  object : Map[String, Json],
  key : String,
  path : @json.JsonPath,
) -> Int raise @json.JsonDecodeError {
  @json.FromJson::from_json(field(object, key, path), path.add_key(key))
}

///|
fn string_field(
  object : Map[String, Json],
  key : String,
  path : @json.JsonPath,
) -> String raise @json.JsonDecodeError {
  @json.FromJson::from_json(field(object, key, path), path.add_key(key))
}

///|
/// Framework-owned request frame. The payload is application-owned JSON.
pub(all) struct RequestFrame {
  version : Int
  payload : Json
} derive(Eq, Debug)

///|
/// Encode an application request body in the current IPC frame format.
pub fn[T : ToJson] RequestFrame::RequestFrame(body : T) -> RequestFrame {
  { version: ipc_version, payload: body.to_json() }
}

///|
/// Decode the application payload after validating the frame version.
pub fn[T : @json.FromJson] RequestFrame::decode(
  self : RequestFrame,
) -> T raise IpcError {
  if self.version != ipc_version {
    raise UnsupportedVersion(self.version)
  }
  @json.from_json(self.payload) catch {
    err => raise DecodeError(err.to_string())
  }
}

///|
/// Serialize this request frame to JSON text.
pub fn RequestFrame::stringify(self : RequestFrame) -> String {
  self.to_json().stringify()
}

///|
pub impl ToJson for RequestFrame with fn to_json(self) {
  { "version": self.version, "payload": self.payload }
}

///|
pub impl @json.FromJson for RequestFrame with fn from_json(json, path) {
  match json {
    Object(object) => {
      let version = int_field(object, "version", path)
      let payload = field(object, "payload", path)
      { version, payload }
    }
    _ => json_decode_error(path, "RequestFrame: expected object")
  }
}

///|
/// Parse JSON text into a request frame.
pub fn parse_request_frame(raw : String) -> RequestFrame raise IpcError {
  let json = @json.parse(raw) catch {
    err => raise DecodeError(err.to_string())
  }
  @json.from_json(json) catch {
    err => raise DecodeError(err.to_string())
  }
}

///|
/// Framework-owned response value.
pub(all) enum IpcResponse[T] {
  Ok(T)
  Err(IpcError)
} derive(Eq, Debug)

///|
pub impl[T : ToJson] ToJson for IpcResponse[T] with fn to_json(self) {
  match self {
    Ok(value) => { "ok": value.to_json() }
    Err(err) => { "err": err.to_json() }
  }
}

///|
pub impl[T : @json.FromJson] @json.FromJson for IpcResponse[T] with fn from_json(
  json,
  path,
) {
  match json {
    Object(object) =>
      match (object.get("ok"), object.get("err")) {
        (Some(value), None) =>
          Ok(@json.FromJson::from_json(value, path.add_key("ok")))
        (None, Some(err)) =>
          Err(@json.FromJson::from_json(err, path.add_key("err")))
        _ =>
          json_decode_error(
            path, "IpcResponse: expected exactly one of 'ok' or 'err'",
          )
      }
    _ => json_decode_error(path, "IpcResponse: expected object")
  }
}

///|
/// Framework-owned response frame.
pub(all) struct ResponseFrame[T] {
  version : Int
  response : IpcResponse[T]
} derive(Eq, Debug)

///|
/// Encode a typed IPC response in the current frame format.
pub fn[T] ResponseFrame::ResponseFrame(
  response : IpcResponse[T],
) -> ResponseFrame[T] {
  { version: ipc_version, response }
}

///|
/// Serialize this response frame to JSON text.
pub fn[T : ToJson] ResponseFrame::stringify(self : ResponseFrame[T]) -> String {
  self.to_json().stringify()
}

///|
pub impl[T : ToJson] ToJson for ResponseFrame[T] with fn to_json(self) {
  { "version": self.version, "response": self.response.to_json() }
}

///|
pub impl[T : @json.FromJson] @json.FromJson for ResponseFrame[T] with fn from_json(
  json,
  path,
) {
  match json {
    Object(object) => {
      let version = int_field(object, "version", path)
      let response : IpcResponse[T] = @json.FromJson::from_json(
        field(object, "response", path),
        path.add_key("response"),
      )
      { version, response }
    }
    _ => json_decode_error(path, "ResponseFrame: expected object")
  }
}

///|
/// Parse JSON text into a typed response frame and validate its version.
pub fn[T : @json.FromJson] parse_response_frame(
  raw : String,
) -> ResponseFrame[T] raise IpcError {
  let json = @json.parse(raw) catch {
    err => raise DecodeError(err.to_string())
  }
  let frame : ResponseFrame[T] = @json.from_json(json) catch {
    err => raise DecodeError(err.to_string())
  }
  if frame.version != ipc_version {
    raise UnsupportedVersion(frame.version)
  }
  frame
}

///|
/// Serialize a successful response frame for a typed result.
pub fn[T : ToJson] response_ok(value : T) -> String {
  ResponseFrame(Ok(value)).stringify()
}

///|
/// Serialize an error response frame.
pub fn response_err(err : IpcError) -> String {
  let response : IpcResponse[Json] = Err(err)
  ResponseFrame(response).to_json().stringify()
}
