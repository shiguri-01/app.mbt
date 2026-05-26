///|
pub fn open_file_message() -> String {
  let client = @desktop.Client()
  client.frame(@shared.FileDialogCommand::OpenFile)
}

///|
pub fn open_folder_message() -> String {
  let client = @desktop.Client()
  client.frame(@shared.FileDialogCommand::OpenFolder)
}
