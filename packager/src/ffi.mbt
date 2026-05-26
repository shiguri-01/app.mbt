///|
#borrow(path)
extern "C" fn ffi_read_text(path : Bytes) -> Bytes = "moonbit_packager_read_text"

///|
#borrow(path)
extern "C" fn ffi_make_dirs(path : Bytes) -> Int = "moonbit_packager_make_dirs"

///|
#borrow(from, to)
extern "C" fn ffi_copy_file(from : Bytes, to : Bytes) -> Int = "moonbit_packager_copy_file"

///|
#borrow(from, to)
extern "C" fn ffi_copy_tree(from : Bytes, to : Bytes) -> Int = "moonbit_packager_copy_tree"

///|
#borrow(command)
extern "C" fn ffi_run_command(command : Bytes) -> Int = "moonbit_packager_run_command"

///|
extern "C" fn ffi_last_error() -> Bytes = "moonbit_packager_last_error"
