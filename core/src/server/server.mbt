///|
/// MoonFlow HTTP REST API server using mocket framework.

///|
let workflows : Map[String, String] = {}

///|
let executions : Array[String] = []

///|
fn cors_json(event : @mocket.MocketEvent) -> Unit {
  event.res.headers["Content-Type"] = "application/json"
  event.res.headers["Access-Control-Allow-Origin"] = "*"
  event.res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
  event.res.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
}

///|
fn get_body(event : @mocket.MocketEvent) -> String {
  event.req.raw_body.to_unchecked_string()
}

///|
fn build_json_err(msg : String) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{\"success\":false,\"error\":\"")
  buf.write_string(@utils.escape_json(msg))
  buf.write_string("\"}")
  buf.to_string()
}

///|
pub fn start_server(port? : Int = 8080) -> Unit {
  let app = @mocket.new()

  // CORS preflight
  app.options("/*", event => {
    cors_json(event)
    event.res.status_code = @mocket.OK
    ""
  })

  // Health check
  app.get("/api/health", event => {
    cors_json(event)
    "{\"status\":\"ok\",\"engine\":\"moonflow\",\"version\":\"0.1.0\"}"
  })

  // Execute workflow
  app.post("/api/execute", event => {
    cors_json(event)
    let body = get_body(event)
    try {
      let wf = @workflow.parse_workflow_json(body)
      match @runtime.execute_workflow(wf) {
        Ok(exec) => @runtime.serialize_execution_to_json(exec)
        Err(e) => {
          event.res.status_code = @mocket.InternalServerError
          build_json_err(e)
        }
      }
    } catch {
      e => {
        event.res.status_code = @mocket.BadRequest
        build_json_err(e.to_string())
      }
    }
  })

  // Validate workflow
  app.post("/api/validate", event => {
    cors_json(event)
    let body = get_body(event)
    try {
      let wf = @workflow.parse_workflow_json(body)
      match @workflow.validate_workflow(wf) {
        Ok(_) => "{\"valid\":true}"
        Err(e) => {
          let msg = @workflow.format_validation_error(e)
          let buf = StringBuilder::new()
          buf.write_string("{\"valid\":false,\"error\":\"")
          buf.write_string(@utils.escape_json(msg))
          buf.write_string("\"}")
          buf.to_string()
        }
      }
    } catch {
      e => {
        event.res.status_code = @mocket.BadRequest
        build_json_err(e.to_string())
      }
    }
  })

  // Save workflow
  app.post("/api/workflows", event => {
    cors_json(event)
    let body = get_body(event)
    try {
      let wf = @workflow.parse_workflow_json(body)
      let json_str = @workflow.serialize_workflow_to_json(wf)
      workflows[wf.name] = json_str
      let buf = StringBuilder::new()
      buf.write_string("{\"success\":true,\"name\":\"")
      buf.write_string(@utils.escape_json(wf.name))
      buf.write_string("\"}")
      buf.to_string()
    } catch {
      e => {
        event.res.status_code = @mocket.BadRequest
        build_json_err(e.to_string())
      }
    }
  })

  // List workflows
  app.get("/api/workflows", event => {
    cors_json(event)
    let buf = StringBuilder::new()
    buf.write_string("{\"workflows\":[")
    let mut first = true
    for name, json_str in workflows {
      if !first {
        buf.write_string(",")
      }
      first = false
      buf.write_string("{\"name\":\"")
      buf.write_string(@utils.escape_json(name))
      buf.write_string("\",\"data\":")
      buf.write_string(json_str)
      buf.write_string("}")
    }
    buf.write_string("]}")
    buf.to_string()
  })

  // List components
  app.get("/api/components", event => {
    cors_json(event)
    let buf = StringBuilder::new()
    buf.write_string("{\"components\":[")
    let names = [
      "http", "llm", "email", "feishu", "filter", "transform", "cache", "retry",
      "rate_limiter", "circuit_breaker", "router",
    ]
    for i, name in names {
      if i > 0 {
        buf.write_string(",")
      }
      buf.write_string("{\"name\":\"")
      buf.write_string(name)
      buf.write_string("\",\"category\":\"builtin\"}")
    }
    buf.write_string("]}")
    buf.to_string()
  })

  // List executions
  app.get("/api/executions", event => {
    cors_json(event)
    let buf = StringBuilder::new()
    buf.write_string("{\"executions\":[")
    for i, exec_json in executions {
      if i > 0 {
        buf.write_string(",")
      }
      buf.write_string(exec_json)
    }
    buf.write_string("]}")
    buf.to_string()
  })

  // LLM proxy
  app.post("/api/llm", event => {
    cors_json(event)
    let body = get_body(event)
    let buf = StringBuilder::new()
    buf.write_string(
      "{\"success\":true,\"response\":{\"content\":\"LLM proxy received: ",
    )
    buf.write_string(@utils.escape_json(body))
    buf.write_string("\",\"model\":\"stub\",\"tokens\":0}}")
    buf.to_string()
  })

  println("MoonFlow server starting on port " + port.to_string())
  app.serve(port~)
}
