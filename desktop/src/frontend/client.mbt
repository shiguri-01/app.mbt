///|
/// UI-library-agnostic frontend IPC client.
///
/// This package only prepares typed JSON messages. A Rabbita, Luna, or plain DOM
/// layer can decide how to deliver them to the host bridge.
pub struct Client {
  next_id : Int
}

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
pub fn[T : ToJson] Client::request(self : Client, body : T) -> (Client, String) {
  let id = "req-\{self.next_id}"
  let next = { next_id: self.next_id + 1 }
  (next, @ipc.Envelope::new(body, id~).stringify())
}

///|
pub fn[T : FromJson] decode_event(raw : String) -> T raise @ipc.IpcError {
  @ipc.parse_envelope(raw).decode()
}
