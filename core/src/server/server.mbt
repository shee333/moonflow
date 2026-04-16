package moonflow_server

import oboard/mocket as mocket
import moonflow_core::runtime
import moonflow_core::workflow

pub fn start_server~(port~ : Int = 8080) -> Unit {
  let app = mocket.new()

  app.get("/health", fn(_) {
    mocket.json({
      "status" => "ok",
      "service" => "moonflow",
      "version" => "0.1.0"
    })
  })

  app.post("/execute", fn(ctx) {
    match ctx.body() {
      Some(body) => {
        match parse_workflow_request(body) {
          Ok(workflow) => {
            match runtime::execute_workflow(workflow) {
              Ok(result) => {
                mocket.json(serialize_execution_result(result))
              }
              Err(e) => {
                mocket.json({
                  "error" => serialize_execution_error(e),
                  "success" => false
                })
              }
            }
          }
          Err(msg) => {
            mocket.json({
              "error" => msg,
              "success" => false
            })
          }
        }
      }
      None => {
        mocket.json({
          "error" => "Missing request body",
          "success" => false
        })
      }
    }
  })

  app.post("/llm", fn(ctx) {
    match ctx.body() {
      Some(body) => {
        match parse_llm_request(body) {
          Ok(req) => {
            let response = call_llm(req)
            mocket.json(serialize_llm_response(response))
          }
          Err(msg) => {
            mocket.json({
              "error" => msg,
              "success" => false
            })
          }
        }
      }
      None => {
        mocket.json({
          "error" => "Missing request body",
          "success" => false
        })
      }
    }
  })

  println("===========================================")
  println("  MoonFlow Server")
  println("  AI Workflow Engine in MoonBit")
  println("===========================================")
  println("")
  println("Server starting on port {port}...")
  println("API endpoints:")
  println("  GET  /health          - Health check")
  println("  POST /execute         - Execute workflow")
  println("  POST /llm             - LLM inference")
  println("")
  println("===========================================")

  app.serve(port=port)
}

fn parse_workflow_request(body: String) -> Result[workflow::Workflow, String] {
  match parse_json_workflow(body) {
    Ok(w) => Ok(w)
    Err(e) => Err("Failed to parse workflow: \{e}")
  }
}

fn parse_llm_request(body: String) -> Result[LLMRequest, String] {
  match parse_json_llm_request(body) {
    Ok(r) => Ok(r)
    Err(e) => Err("Failed to parse LLM request: \{e}")
  }
}

pub struct LLMRequest {
  model: String
  prompt: String
  temperature: Double
  max_tokens: Int
}

pub struct LLMResponse {
  content: String
  model: String
  usage: LLMUsage
  finish_reason: String
}

pub struct LLMUsage {
  prompt_tokens: Int
  completion_tokens: Int
  total_tokens: Int
}

fn call_llm(req: LLMRequest) -> LLMResponse {
  LLMResponse::{
    content: "Mock LLM response for: \{req.prompt}",
    model: req.model,
    usage: LLMUsage::{
      prompt_tokens: 10,
      completion_tokens: 20,
      total_tokens: 30,
    },
    finish_reason: "stop",
  }
}

fn serialize_execution_result(result: runtime::WorkflowExecution) -> Map[String, String] {
  let output: Map[String, String] = {}
  output["execution_id"] = result.execution_id
  output["status"] = serialize_status(result.status)
  output["duration_ms"] = result.duration_ms.to_string()
  output["success"] = "true"
  output
}

fn serialize_status(status: runtime::WorkflowStatus) -> String {
  match status {
    runtime::WorkflowStatus::Pending => "pending"
    runtime::WorkflowStatus::Running => "running"
    runtime::WorkflowStatus::Completed => "completed"
    runtime::WorkflowStatus::Failed => "failed"
    runtime::WorkflowStatus::Cancelled => "cancelled"
  }
}

fn serialize_execution_error(err: runtime::WorkflowError) -> String {
  match err {
    runtime::WorkflowError::ValidationFailed(msg) => "Validation failed: \{msg}"
    runtime::WorkflowError::ExecutionFailed(msg) => "Execution failed: \{msg}"
    runtime::WorkflowError::Timeout => "Execution timeout"
    runtime::WorkflowError::Cancelled => "Execution cancelled"
  }
}

fn serialize_llm_response(response: LLMResponse) -> Map[String, String] {
  let output: Map[String, String] = {}
  output["content"] = response.content
  output["model"] = response.model
  output["finish_reason"] = response.finish_reason
  output["success"] = "true"
  output
}

fn parse_json_workflow(body: String) -> Result[workflow::Workflow, String] {
  Ok(workflow::Workflow::{
    name: "api-workflow",
    nodes: [],
    edges: [],
    config: None,
  })
}

fn parse_json_llm_request(body: String) -> Result[LLMRequest, String] {
  Ok(LLMRequest::{
    model: "mock-model",
    prompt: body,
    temperature: 0.7,
    max_tokens: 100,
  })
}

pub fn main {
  start_server(port=8080)
}
