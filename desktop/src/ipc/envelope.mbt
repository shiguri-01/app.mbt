///|
/// A transport-level IPC message.
///
/// The framework owns `id`; applications own the typed payload encoded inside
/// `payload`.
pub(all) struct Envelope {
  id : String?
  payload : Json
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Build an IPC envelope from any value that can be serialized as JSON.
pub fn[T : ToJson] Envelope::Envelope(body : T, id? : String) -> Envelope {
  { id, payload: body.to_json() }
}

///|
/// Decode the envelope payload as an application-defined command or event.
pub fn[T : FromJson] Envelope::decode(self : Envelope) -> T raise IpcError {
  @json.from_json(self.payload) catch {
    err => raise DecodeError(err.to_string())
  }
}

///|
/// Return the envelope as a JSON string suitable for a webview bridge.
pub fn Envelope::stringify(self : Envelope) -> String {
  self.to_json().stringify()
}

///|
/// Parse a transport JSON string into an envelope.
pub fn parse_envelope(raw : String) -> Envelope raise IpcError {
  let json = @json.parse(raw) catch {
    err => raise DecodeError(err.to_string())
  }
  @json.from_json(json) catch {
    err => raise DecodeError(err.to_string())
  }
}
