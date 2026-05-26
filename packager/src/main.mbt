///|
fn usage() -> String {
  (
    #|Usage:
    #|  app-packager package <manifest>
    #|
    #|Example:
    #|  moon run packager/src --target native -- package examples/counter/desktop.app.json
    #|
  )
}

///|
fn run_cli(args : Array[String]) -> Unit raise PackError {
  match (args.get(1), args.get(2)) {
    (Some("package"), Some(path)) => package_app(path)
    _ => println(usage())
  }
}

///|
fn main {
  run_cli(@env.args()) catch {
    Failed(message) => println("packaging failed: \{message}")
  }
}
