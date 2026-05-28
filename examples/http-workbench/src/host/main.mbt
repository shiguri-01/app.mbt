///|
fn state_file_path() -> String {
  @desktop.app_dir() + "/http-workbench-state.json"
}

///|
fn local_dist_path(relative : String) -> String raise {
  guard @env.current_dir() is Some(cwd) else {
    fail("could not determine current directory")
  }
  cwd + "/examples/http-workbench/dist/" + relative
}

///|
async fn read_dist_text(relative : String) -> String {
  match (@desktop.resource_text(relative) catch { _ => None }) {
    Some(text) => text
    None => @fs.read_file(local_dist_path(relative)).text()
  }
}

///|
async fn workbench_html() -> String {
  read_dist_text("index.html")
}

///|
fn load_workbench_html() -> Result[String, String] {
  let result : Ref[Result[String, String]?] = Ref(None)
  @async.run_async_main(() => {
    let html = workbench_html() catch {
      err => {
        result.val = Some(Err("\{to_repr(err)}"))
        return
      }
    }
    result.val = Some(Ok(html))
  })
  match result.val {
    Some(result) => result
    None => Err("workbench frontend loader finished without a result")
  }
}

///|
pub fn method_to_request_method(
  http_method : @contract.HttpMethod,
) -> @http.RequestMethod {
  match http_method {
    Get => @http.RequestMethod::Get
    Post => @http.RequestMethod::Post
    Put => @http.RequestMethod::Put
    Patch => @http.RequestMethod::Patch
    Delete => @http.RequestMethod::Delete
    Head => @http.RequestMethod::Head
    Options => @http.RequestMethod::Options
  }
}

///|
fn parse_url(uri : String) -> (String, Int, String, String) raise {
  guard uri.find("://") is Some(protocol_len) else { fail("invalid URL") }
  let protocol = match uri[:protocol_len] {
    "http" => "http"
    "https" => "https"
    protocol => fail("unsupported protocol: \{protocol}")
  }
  let uri = uri[protocol_len + 3:]
  let (host, path) = if uri.find("/") is Some(i) {
    (uri[:i].to_owned(), uri[i:].to_owned())
  } else {
    (uri.to_owned(), "/")
  }
  let (host, port) = if host.find(":") is Some(i) {
    let port_str = host[i + 1:]
    let port = @string.parse_int(port_str) catch { _ => fail("invalid port") }
    guard port is (1..<65536) else { fail("invalid port") }
    (host[:i].to_owned(), port)
  } else {
    let port = if protocol == "http" { 80 } else { 443 }
    (host, port)
  }
  let path = if path == "" { "/" } else { path }
  (protocol, port, host, path)
}

///|
async fn perform_http_request(
  request : @contract.SavedRequest,
) -> (@http.Response, String, Int64) {
  let headers = @core.enabled_headers(request.headers)
  let (protocol, port, host, path) = parse_url(request.url.trim().to_owned())
  let client = @http.Client("\{protocol}://\{host}:\{port}")
  defer client.close()
  let http_method = method_to_request_method(request.http_method)
  let start = @async.now()
  let response = client
    ..request(http_method, path, extra_headers=headers)
    ..write(request.body)
    .end_request()
  let body = client.read_all().text()
  let duration = @async.now() - start
  (response, body, duration)
}

///|
fn response_headers(
  headers : Map[String, String],
) -> Array[@contract.ResponseHeader] {
  let result = []
  for name, value in headers {
    result.push(@contract.ResponseHeader::{ name, value })
  }
  result
}

///|
pub async fn load_state_from_path(path : String) -> @contract.WorkbenchState {
  if !@fs.exists(path) {
    return @core.default_state()
  }
  let raw = @fs.read_file(path).text() catch {
    _ => return @core.default_state()
  }
  let json = @json.parse(raw) catch { _ => return @core.default_state() }
  @json.from_json(json) catch {
    _ => @core.default_state()
  }
}

///|
pub async fn save_state_to_path(
  path : String,
  state : @contract.WorkbenchState,
) -> @contract.SaveStateReply {
  @fs.write_file(
    path,
    state.to_json().stringify(),
    create_mode=CreateOrTruncate,
  )
  @contract.SaveStateReply::{ saved: true, message: "Saved" }
}

///|
async fn handle_send_http(
  request : @contract.SendHttpRequest,
) -> @contract.SendHttpReply {
  let start = @async.now()
  let (response, body, duration) = perform_http_request(request.request) catch {
    err =>
      return @contract.SendHttpReply::{
        status: None,
        status_text: "",
        headers: [],
        body: "",
        duration_ms: @async.now() - start,
        error: Some("\{to_repr(err)}"),
      }
  }
  @contract.SendHttpReply::{
    status: Some(response.code),
    status_text: response.reason,
    headers: response_headers(response.headers),
    body,
    duration_ms: duration,
    error: None,
  }
}

///|
fn main {
  let html = match load_workbench_html() {
    Ok(html) => html
    Err(message) => {
      println(
        "failed to load HTTP workbench frontend; run `just build-http-workbench-frontend` first",
      )
      println(message)
      return
    }
  }
  @desktop.run(on_startup=app => {
    let window = app.create_window(
      WindowOptions(
        key="main",
        title="HTTP/API Workbench",
        width=1180,
        height=780,
        load=Html(html),
      ),
    )
    let router = @desktop.IpcRouter()
      .handle(@contract.load_state_endpoint, handler=_ => {
        load_state_from_path(state_file_path())
      })
      .handle(@contract.save_state_endpoint, handler=state => {
        save_state_to_path(state_file_path(), state)
      })
      .handle(@contract.send_http_endpoint, handler=request => {
        handle_send_http(request)
      })
    window.mount_ipc(router)
  }) catch {
    err => println("desktop runtime failed: \{to_repr(err)}")
  }
}
