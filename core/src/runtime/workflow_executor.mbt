package moonflow_core::runtime

import moonflow_core::workflow

pub type WorkflowResult = Result[WorkflowExecution, WorkflowError]

pub struct WorkflowExecution {
  workflow_id: String?
  execution_id: String
  status: WorkflowStatus
  node_results: Map[String, NodeResult]
  duration_ms: Int
  start_time: Int
  end_time: Int?
  logs: Array[LogEntry]
}

pub enum WorkflowStatus {
  Pending
  Running
  Completed
  Failed
  Cancelled
}

pub enum WorkflowError {
  ValidationFailed(String)
  ExecutionFailed(String)
  Timeout
  Cancelled
}

pub fn execute_workflow(
  workflow: moonflow_core::workflow::Workflow,
) -> WorkflowResult {
  let execution_id = generate_id()
  
  let ctx = ExecutionContext::new(execution_id~)
  ctx.metadata.workflow_id = Some(workflow.name)
  
  ctx.log(level=LogLevel::Info, message="Starting workflow: \{workflow.name}")
  
  match moonflow_core::workflow::validate_workflow(workflow) {
    Err(e) => {
      let error_msg = moonflow_core::workflow::format_validation_error(e)
      ctx.log(level=LogLevel::Error, message="Validation failed: \{error_msg}")
      return Err(WorkflowError::ValidationFailed(error_msg))
    }
    Ok(_) => ()
  }
  
  ctx.log(level=LogLevel::Info, message="Workflow validation passed")
  
  let execution_order = build_execution_order(workflow.nodes, workflow.edges)
  
  ctx.log(
    level=LogLevel::Info,
    message="Execution order: \{execution_order.map(fn(n) { n.id }).join(\" -> \")}"
  )
  
  for node in execution_order {
    ctx.log(level=LogLevel::Debug, message="Executing node: \{node.id}", node_id=Some(node.id))
    
    let start_time = get_timestamp()
    
    match execute_node(node, ctx) {
      Ok(output) => {
        let duration = get_timestamp() - start_time
        let result = {
          node_id: node.id,
          status: NodeStatus::Success,
          output: Some(output),
          error: None,
          duration_ms: duration,
          timestamp: start_time,
        }
        ctx.record_result(result)
        ctx.log(
          level=LogLevel::Info,
          message="Node \{node.id} completed in \{duration}ms",
          node_id=Some(node.id)
        )
      }
      Err(e) => {
        let duration = get_timestamp() - start_time
        let error_msg = format_executor_error(e)
        let result = {
          node_id: node.id,
          status: NodeStatus::Failure,
          output: None,
          error: Some(error_msg),
          duration_ms: duration,
          timestamp: start_time,
        }
        ctx.record_result(result)
        ctx.log(
          level=LogLevel::Error,
          message="Node \{node.id} failed: \{error_msg}",
          node_id=Some(node.id)
        )
        return Err(WorkflowError::ExecutionFailed(error_msg))
      }
    }
  }
  
  let success_count = ctx.metadata.get_success_count()
  let failure_count = ctx.metadata.get_failure_count()
  
  ctx.log(
    level=LogLevel::Info,
    message="Workflow completed. Success: \{success_count}, Failed: \{failure_count}"
  )
  
  Ok(WorkflowExecution::{
    workflow_id: Some(workflow.name),
    execution_id,
    status: WorkflowStatus::Completed,
    node_results: ctx.metadata.node_results,
    duration_ms: ctx.metadata.get_duration(),
    start_time: ctx.metadata.start_time,
    end_time: Some(get_timestamp()),
    logs: ctx.metadata.logs,
  })
}

fn execute_node(
  node: moonflow_core::workflow::Node,
  ctx: ExecutionContext,
) -> Result[Value, ExecutorError] {
  match node.node_type {
    moonflow_core::workflow::NodeType::Trigger => execute_trigger(node, ctx),
    moonflow_core::workflow::NodeType::Tool => execute_tool(node, ctx),
    moonflow_core::workflow::NodeType::Agent => execute_agent(node, ctx),
    moonflow_core::workflow::NodeType::Control => execute_control(node, ctx),
  }
}

fn execute_trigger(
  node: moonflow_core::workflow::Node,
  ctx: ExecutionContext,
) -> Result[Value, ExecutorError] {
  ctx.log(level=LogLevel::Debug, message="Executing trigger: \{node.id}")
  Ok(Value::Object({
    "type" => Value::String("trigger"),
    "node_id" => Value::String(node.id),
    "timestamp" => Value::Number(get_timestamp().to_double()),
  }))
}

fn execute_tool(
  node: moonflow_core::workflow::Node,
  ctx: ExecutionContext,
) -> Result[Value, ExecutorError] {
  let tool_name = detect_tool_name(node)
  
  ctx.log(level=LogLevel::Debug, message="Executing tool: \{tool_name}")
  
  let output = Value::Object({
    "type" => Value::String("tool"),
    "tool" => Value::String(tool_name),
    "node_id" => Value::String(node.id),
    "params" => map_to_value(node.with),
  })
  
  Ok(output)
}

fn execute_agent(
  node: moonflow_core::workflow::Node,
  ctx: ExecutionContext,
) -> Result[Value, ExecutorError] {
  let agent_name = detect_agent_name(node)
  
  ctx.log(level=LogLevel::Debug, message="Executing agent: \{agent_name}")
  
  let model = node.with["model"].unwrap_or("unknown")
  
  let output = Value::Object({
    "type" => Value::String("agent"),
    "agent" => Value::String(agent_name),
    "model" => Value::String(model),
    "node_id" => Value::String(node.id),
  })
  
  Ok(output)
}

fn execute_control(
  node: moonflow_core::workflow::Node,
  ctx: ExecutionContext,
) -> Result[Value, ExecutorError] {
  let control_name = detect_control_name(node)
  
  ctx.log(level=LogLevel::Debug, message="Executing control: \{control_name}")
  
  let output = Value::Object({
    "type" => Value::String("control"),
    "control" => Value::String(control_name),
    "node_id" => Value::String(node.id),
  })
  
  Ok(output)
}

fn detect_tool_name(node: moonflow_core::workflow::Node) -> String {
  let with = node.with
  if with.contains("url") {
    if with["method"].unwrap_or("GET") == "POST" {
      return "http_post"
    }
    return "http_get"
  }
  if with.contains("smtp_host") {
    return "email"
  }
  if with.contains("webhook_url") {
    return "feishu"
  }
  if with.contains("file_path") {
    if with.contains("content") {
      return "file_write"
    }
    if with.contains("delete") {
      return "file_delete"
    }
    return "file_read"
  }
  "unknown_tool"
}

fn detect_agent_name(node: moonflow_core::workflow::Node) -> String {
  let with = node.with
  if with.contains("model") && with.contains("prompt") {
    return "llm"
  }
  if with.contains("intents") {
    return "intent_classify"
  }
  "unknown_agent"
}

fn detect_control_name(node: moonflow_core::workflow::Node) -> String {
  let with = node.with
  if with.contains("condition") {
    return "condition"
  }
  if with.contains("join_type") {
    return "parallel"
  }
  if with.contains("items") {
    return "loop"
  }
  "unknown_control"
}

fn build_execution_order(
  nodes: Array[moonflow_core::workflow::Node],
  edges: Array[moonflow_core::workflow::Edge],
) -> Array[moonflow_core::workflow::Node] {
  let node_map: Map[String, moonflow_core::workflow::Node] = {}
  for node in nodes {
    node_map[node.id] = node
  }
  
  let in_degree: Map[String, Int] = {}
  let adjacency: Map[String, Array[String]] = {}
  
  for node in nodes {
    in_degree[node.id] = 0
    adjacency[node.id] = []
  }
  
  for edge in edges {
    in_degree[edge.to] = in_degree[edge.to].unwrap_or(0) + 1
    match adjacency[edge.from] {
      Some(arr) => arr.push(edge.to)
      None => adjacency[edge.from] = [edge.to]
    }
  }
  
  let queue: Array[String] = []
  for (node_id, degree) in in_degree {
    if degree == 0 {
      queue.push(node_id)
    }
  }
  
  let result: Array[moonflow_core::workflow::Node] = []
  
  for node_id in queue {
    match node_map[node_id] {
      Some(node) => result.push(node)
      None => ()
    }
    
    match adjacency[node_id] {
      Some(targets) => {
        for target in targets {
          let new_degree = in_degree[target].unwrap_or(0) - 1
          in_degree[target] = new_degree
          if new_degree == 0 {
            result.push(node_map[target])
          }
        }
      }
      None => ()
    }
  }
  
  result
}

fn map_to_value(m: Map[String, String]) -> Value {
  let obj: Map[String, Value] = {}
  for (k, v) in m {
    obj[k] = Value::String(v)
  }
  Value::Object(obj)
}

fn format_executor_error(err: ExecutorError) -> String {
  match err {
    ExecutorError::Timeout => "Execution timeout"
    ExecutorError::NetworkError(msg) => "Network error: \{msg}"
    ExecutorError::ValidationError(msg) => "Validation error: \{msg}"
    ExecutorError::ExecutionError(msg) => "Execution error: \{msg}"
    ExecutorError::RateLimitError => "Rate limit exceeded"
  }
}

fn generate_id() -> String {
  "exec_\{get_timestamp()}"
}

fn get_timestamp() -> Int {
  0
}
