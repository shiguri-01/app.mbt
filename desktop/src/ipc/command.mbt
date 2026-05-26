///|
/// Stable identifier for an application command used by IPC policies.
pub(all) struct CommandId(String) derive(Eq, Hash, Debug)

///|
pub impl ToJson for CommandId with fn to_json(self) {
  self.0.to_json()
}

///|
pub impl @json.FromJson for CommandId with fn from_json(json, path) {
  CommandId(@json.FromJson::from_json(json, path))
}

///|
pub fn CommandId::to_string(self : CommandId) -> String {
  self.0
}
