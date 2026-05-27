///|
pub fn default_request() -> @contract.SavedRequest {
  @contract.SavedRequest::{
    id: "draft",
    name: "Untitled request",
    http_method: Get,
    url: "https://httpbin.org/get",
    headers: [
      @contract.Header::{
        name: "Accept",
        value: "application/json",
        enabled: true,
      },
    ],
    body: "",
  }
}

///|
pub fn display_name(request : @contract.SavedRequest) -> String {
  let name = request.name.trim().to_owned()
  if name == "" {
    "\{request.http_method.to_string()} \{request.url}"
  } else {
    name
  }
}

///|
pub fn append_header(
  headers : Array[@contract.Header],
) -> Array[@contract.Header] {
  let next = headers.copy()
  next.push(@contract.Header::{ name: "", value: "", enabled: true })
  next
}

///|
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
