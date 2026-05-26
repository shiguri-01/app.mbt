///|
pub(all) enum FileDialogCommand {
  OpenFile
  OpenFiles
  SaveFile
  OpenFolder
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) enum FileDialogEvent {
  Selected(Array[String])
  Canceled
} derive(Debug, Eq, ToJson, FromJson)
