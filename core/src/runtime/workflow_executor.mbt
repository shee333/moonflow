///|
/// Workflow execution orchestrator.

///|
pub(all) enum WorkflowStatus {
  WfPending
  WfRunning
  WfCompleted
  WfFailed
  WfCancelled
} derive(Show, Eq)

///|
pub(all) struct WorkflowExecution {
  execution_id : String
  workflow_id : String?
  mut status : WorkflowStatus
  duration_ms : Int
  node_results : Map[String, NodeResult]
  mut error : String?
}

///|
pub fn execute_workflow(
  workflow : @workflow.Workflow,
) -> Result[WorkflowExecution, String] {
  match @workflow.validate_workflow(workflow) {
    Err(e) => {
      let msg = @workflow.format_validation_error(e)
      return Err("Validation failed: " + msg)
    }
    Ok(_) => ()
  }
  let exec = WorkflowExecution::{
    execution_id: "exec_" + workflow.name,
    workflow_id: Some(workflow.name),
    status: WfRunning,
    duration_ms: 0,
    node_results: {},
    error: None,
  }
  let order = @workflow.get_execution_order(workflow)
  let ctx = ExecutionContext::new(workflow.name)
  let node_map : Map[String, @workflow.Node] = {}
  for node in workflow.nodes {
    node_map[node.id] = node
  }
  for node_id in order {
    match node_map.get(node_id) {
      Some(node) => {
        let result = execute_node(node, ctx)
        exec.node_results[node_id] = result
        match result.status {
          Failure => {
            exec.status = WfFailed
            exec.error = result.error_msg
            return Ok(exec)
          }
          _ => ()
        }
      }
      None => ()
    }
  }
  exec.status = WfCompleted
  Ok(exec)
}

///|
pub fn format_workflow_status(status : WorkflowStatus) -> String {
  match status {
    WfPending => "pending"
    WfRunning => "running"
    WfCompleted => "completed"
    WfFailed => "failed"
    WfCancelled => "cancelled"
  }
}

///|
pub fn serialize_execution_to_json(exec : WorkflowExecution) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{\"success\":true")
  buf.write_string(",\"execution_id\":\"")
  buf.write_string(exec.execution_id)
  buf.write_string("\"")
  match exec.workflow_id {
    Some(id) => {
      buf.write_string(",\"workflow_id\":\"")
      buf.write_string(id)
      buf.write_string("\"")
    }
    None => ()
  }
  let status_str = format_workflow_status(exec.status)
  buf.write_string(",\"status\":\"")
  buf.write_string(status_str)
  buf.write_string("\"")
  buf.write_string(",\"duration_ms\":")
  buf.write_string(exec.duration_ms.to_string())
  buf.write_string(",\"node_results\":{")
  let mut first = true
  for node_id, result in exec.node_results {
    if !first {
      buf.write_string(",")
    }
    first = false
    let s = format_node_status(result.status)
    buf.write_string("\"")
    buf.write_string(node_id)
    buf.write_string("\":{\"status\":\"")
    buf.write_string(s)
    buf.write_string("\",\"duration_ms\":")
    buf.write_string(result.duration_ms.to_string())
    buf.write_string("}")
  }
  buf.write_string("}")
  match exec.error {
    Some(err) => {
      buf.write_string(",\"error\":\"")
      buf.write_string(err)
      buf.write_string("\"")
    }
    None => ()
  }
  buf.write_string("}")
  buf.to_string()
}

///|
pub fn serialize_error_to_json(err : String) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{\"success\":false,\"error\":\"")
  buf.write_string(err)
  buf.write_string("\"}")
  buf.to_string()
}
