///|
pub fn method_to_string(http_method : HttpMethod) -> String {
  match http_method {
    Get => "GET"
    Post => "POST"
    Put => "PUT"
    Patch => "PATCH"
    Delete => "DELETE"
    Head => "HEAD"
    Options => "OPTIONS"
  }
}

///|
pub fn parse_method(value : String) -> HttpMethod {
  match value {
    "POST" => Post
    "PUT" => Put
    "PATCH" => Patch
    "DELETE" => Delete
    "HEAD" => Head
    "OPTIONS" => Options
    _ => Get
  }
}
