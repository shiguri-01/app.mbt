///|
/// Errors produced while moving typed values across the desktop IPC boundary.
pub(all) suberror IpcError {
  DecodeError(String)
  EncodeError(String)
  HandlerError(String)
  TransportClosed(String)
  UnsupportedVersion(Int)
  PayloadTooLarge(size~ : Int, limit~ : Int)
} derive(Debug, Eq)

///|
fn ipc_error_object(tag : String, fields : Map[String, Json]) -> Json {
  fields["tag"] = tag.to_json()
  Json::object(fields)
}

///|
pub impl ToJson for IpcError with fn to_json(self) {
  match self {
    DecodeError(message) =>
      ipc_error_object("DecodeError", { "message": message.to_json() })
    EncodeError(message) =>
      ipc_error_object("EncodeError", { "message": message.to_json() })
    HandlerError(message) =>
      ipc_error_object("HandlerError", { "message": message.to_json() })
    TransportClosed(message) =>
      ipc_error_object("TransportClosed", { "message": message.to_json() })
    UnsupportedVersion(version) =>
      ipc_error_object("UnsupportedVersion", { "version": version.to_json() })
    PayloadTooLarge(size~, limit~) =>
      ipc_error_object("PayloadTooLarge", {
        "size": size.to_json(),
        "limit": limit.to_json(),
      })
  }
}

///|
pub impl @json.FromJson for IpcError with fn from_json(json, path) {
  match json {
    Object(object) => {
      let tag = string_field(object, "tag", path)
      match tag {
        "DecodeError" => DecodeError(string_field(object, "message", path))
        "EncodeError" => EncodeError(string_field(object, "message", path))
        "HandlerError" => HandlerError(string_field(object, "message", path))
        "TransportClosed" =>
          TransportClosed(string_field(object, "message", path))
        "UnsupportedVersion" =>
          UnsupportedVersion(int_field(object, "version", path))
        "PayloadTooLarge" =>
          PayloadTooLarge(
            size=int_field(object, "size", path),
            limit=int_field(object, "limit", path),
          )
        _ => json_decode_error(path.add_key("tag"), "unknown IPC error tag")
      }
    }
    _ => json_decode_error(path, "IpcError: expected object")
  }
}
