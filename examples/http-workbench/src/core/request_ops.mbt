///|
/// Return the initial draft request shown by the example.
pub fn default_request() -> @contract.SavedRequest {
  {
    id: "draft",
    name: "New request",
    http_method: Get,
    url: "https://httpbin.org/get",
    headers: [{ name: "Accept", value: "application/json", enabled: true }],
    body: "",
  }
}

///|
fn sample_requests() -> Array[@contract.SavedRequest] {
  [
    {
      id: "sample-get",
      name: "GET httpbin",
      http_method: Get,
      url: "https://httpbin.org/get",
      headers: [{ name: "Accept", value: "application/json", enabled: true }],
      body: "",
    },
    {
      id: "sample-post",
      name: "POST echo",
      http_method: Post,
      url: "https://httpbin.org/post",
      headers: [
        { name: "Content-Type", value: "application/json", enabled: true },
      ],
      body: "{\n  \"message\": \"hello\"\n}",
    },
  ]
}

///|
/// Return the display name for a saved request.
pub fn display_name(request : @contract.SavedRequest) -> String {
  let name = request.name.trim().to_owned()
  if name == "" {
    "\{request.http_method.to_string()} \{request.url}"
  } else {
    name
  }
}

///|
/// Append an empty enabled header row.
pub fn append_header(
  headers : Array[@contract.Header],
) -> Array[@contract.Header] {
  let next = headers.copy()
  next.push({ name: "", value: "", enabled: true })
  next
}

///|
/// Remove the header at `index` when it exists.
pub fn remove_header(
  headers : Array[@contract.Header],
  index : Int,
) -> Array[@contract.Header] {
  let next = []
  let mut i = 0
  for header in headers {
    if i != index {
      next.push(header)
    }
    i = i + 1
  }
  next
}

///|
/// Update the header at `index` when it exists.
pub fn update_header(
  headers : Array[@contract.Header],
  index : Int,
  f : (@contract.Header) -> @contract.Header,
) -> Array[@contract.Header] {
  let next = []
  let mut i = 0
  for header in headers {
    next.push(if i == index { f(header) } else { header })
    i = i + 1
  }
  next
}

///|
/// Convert enabled non-empty headers into an HTTP header map.
pub fn enabled_headers(
  headers : Array[@contract.Header],
) -> Map[String, String] {
  let result : Map[String, String] = {}
  for header in headers {
    let name = header.name.trim().to_owned()
    if header.enabled && name != "" {
      result[name] = header.value
    }
  }
  result
}
