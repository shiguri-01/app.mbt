///|
/// Errors produced while moving typed values across the desktop IPC boundary.
pub(all) suberror IpcError {
  DecodeError(String)
  EncodeError(String)
  MissingRequestId
  HandlerError(String)
  TransportClosed
} derive(Debug, Eq, ToJson, FromJson)
