async fn main {
  let port = 8080
  let addr = @socket.Addr::parse("[::]:\{port}") |> @result.unwrap
  @pipe.stdout.write("===========================================\n")
  @pipe.stdout.write("  MoonFlow Server\n")
  @pipe.stdout.write("  AI Workflow Engine in MoonBit\n")
  @pipe.stdout.write("===========================================\n")
  @pipe.stdout.write("Listening on http://localhost:\{port}\n")
  @pipe.stdout.write("API Docs: http://localhost:\{port}/api/health\n\n")
  @http.run_server(addr, fn(conn, addr) {
    handle_connection(conn, addr)
  })
}

async fn handle_connection(conn : ?, addr : String) -> Unit {
  let request = ?conn.read_request()
  ?conn.skip_request_body()

  @pipe.stderr.write("[{addr}] {request.path}\n")

  match request.path {
    "/" | "/health" | "/api/health" => {
      ?conn.send_response(200, "OK")
      ?conn.write("{\"status\":\"ok\",\"version\":\"0.1.0\",\"service\":\"MoonFlow Server\"}")
      ?conn.end_response()
    }
    "/api/workflow" if request.method == "GET" => {
      ?conn.send_response(200, "OK")
      ?conn.write("{\"success\":true,\"data\":[],\"message\":\"Workflows listed successfully\"}")
      ?conn.end_response()
    }
    "/api/nodes" if request.method == "GET" => {
      ?conn.send_response(200, "OK")
      ?conn.write("{\"success\":true,\"data\":{\"count\":8,\"categories\":[\"trigger\",\"ai\",\"network\",\"data\",\"logic\",\"output\"]}}")
      ?conn.end_response()
    }
    "/api/execute" if request.method == "POST" => {
      ?conn.send_response(202, "Accepted")
      ?conn.write("{\"success\":true,\"execution_id\":\"exec_123\",\"status\":\"running\"}")
      ?conn.end_response()
    }
    _ => {
      ?conn.send_response(404, "Not Found")
      ?conn.write("{\"error\":\"Not Found\",\"message\":\"The requested endpoint does not exist\"}")
      ?conn.end_response()
    }
  }
}
