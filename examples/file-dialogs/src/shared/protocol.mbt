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

///|
pub fn command_id(command : FileDialogCommand) -> @ipc.CommandId {
  match command {
    OpenFile => @ipc.CommandId("file_dialog.open_file")
    OpenFiles => @ipc.CommandId("file_dialog.open_files")
    SaveFile => @ipc.CommandId("file_dialog.save_file")
    OpenFolder => @ipc.CommandId("file_dialog.open_folder")
  }
}
