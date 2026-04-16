package moonflow_http

pub struct HttpResponse {
  status_code: Int
  body: String
  headers: Map[String, String]
}

pub struct HttpRequest {
  method: String
  url: String
  headers: Map[String, String]
  body: String?
}

pub fn http_get(url: String) -> HttpResponse {
  http_request({ method: "GET", url, headers: {}, body: None })
}

pub fn http_post(url: String, body: String) -> HttpResponse {
  http_request({ method: "POST", url, headers: { "Content-Type" => "application/json" }, body: Some(body) })
}

pub fn http_request(request: HttpRequest) -> HttpResponse {
  let curl_command = build_curl_command(request)
  let output = run_command(curl_command)
  parse_curl_output(output, request.url)
}

fn build_curl_command(request: HttpRequest) -> String {
  let cmd = "curl -s -w \"\\n%{http_code}\" -X {request.method}"
  
  let headers_str = request.headers
    |> @map.to_array
    |> @array.map(fn(h) { "-H \"{h.0}: {h.1}\"" })
    |> @array.join(" ")
  
  let body_cmd = match request.body {
    Some(b) => " -d '{b}'"
    None => ""
  }
  
  "{cmd} {headers_str}{body_cmd} \"{request.url}\""
}

fn run_command(cmd: String) -> String {
  extern "C" fn run_shell(cmd: String) -> String = "run_shell_command"
  run_shell(cmd)
}

fn parse_curl_output(output: String, url: String) -> HttpResponse {
  let parts = output.split("\n").collect()
  
  if parts.length() < 2 {
    return { status_code: 0, body: output, headers: {} }
  }
  
  let status_str = parts[parts.length() - 1]
  let status_code = @string.to_int(status_str).unwrap_or(0)
  
  let body_lines = parts[0:parts.length() - 1]
  let body = body_lines.join("\n")
  
  { status_code, body, headers: {} }
}
