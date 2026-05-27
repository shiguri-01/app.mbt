///|
pub fn default_request() -> SavedRequest {
  SavedRequest::{
    id: "draft",
    name: "Untitled request",
    http_method: Get,
    url: "https://httpbin.org/get",
    headers: [
      Header::{ name: "Accept", value: "application/json", enabled: true },
    ],
    body: "",
  }
}

///|
pub fn display_name(request : SavedRequest) -> String {
  let name = request.name.trim().to_owned()
  if name == "" {
    "\{method_to_string(request.http_method)} \{request.url}"
  } else {
    name
  }
}

///|
pub fn append_header(headers : Array[Header]) -> Array[Header] {
  let next = headers.copy()
  next.push(Header::{ name: "", value: "", enabled: true })
  next
}

///|
pub fn remove_header(headers : Array[Header], index : Int) -> Array[Header] {
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
  headers : Array[Header],
  index : Int,
  f : (Header) -> Header,
) -> Array[Header] {
  let next = []
  let mut i = 0
  for header in headers {
    next.push(if i == index { f(header) } else { header })
    i = i + 1
  }
  next
}

///|
pub fn enabled_headers(headers : Array[Header]) -> Map[String, String] {
  let result : Map[String, String] = {}
  for header in headers {
    let name = header.name.trim().to_owned()
    if header.enabled && name != "" {
      result[name] = header.value
    }
  }
  result
}
