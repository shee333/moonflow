///|
/// Node executor - dispatches execution based on node type.

///|
pub fn execute_node(
  node : @workflow.Node,
  ctx : ExecutionContext,
) -> NodeResult {
  let result = NodeResult::{
    node_id: node.id,
    status: Running,
    output: {},
    error_msg: None,
    duration_ms: 0,
  }
  match node.node_type {
    @workflow.Trigger => execute_trigger(node, result)
    @workflow.Tool => execute_tool(node, result)
    @workflow.Agent => execute_agent(node, result)
    @workflow.Control => execute_control(node, result)
  }
  ctx.set_node_result(node.id, result)
  result
}

///|
fn execute_trigger(node : @workflow.Node, result : NodeResult) -> Unit {
  result.status = Success
  result.output["triggered"] = ValBool(true)
  let label = node.label.unwrap_or("manual")
  result.output["trigger_type"] = ValString(label)
}

///|
fn execute_tool(node : @workflow.Node, result : NodeResult) -> Unit {
  let tool_name = detect_tool_name(node)
  match tool_name {
    "http_get" | "http_post" | "http" => {
      let url = node.config.get("url").unwrap_or("http://localhost")
      result.output["url"] = ValString(url)
      result.output["status_code"] = ValNumber(200.0)
      result.output["body"] = ValString("{\"ok\": true}")
      result.status = Success
    }
    "email" => {
      let to = node.config.get("to").unwrap_or("")
      result.output["sent"] = ValBool(true)
      result.output["to"] = ValString(to)
      result.status = Success
    }
    "feishu" => {
      let webhook = node.config.get("webhook").unwrap_or("")
      result.output["sent"] = ValBool(true)
      result.output["webhook"] = ValString(webhook)
      result.status = Success
    }
    "file_read" | "file_write" => {
      let path = node.config.get("path").unwrap_or("")
      result.output["path"] = ValString(path)
      result.output["success"] = ValBool(true)
      result.status = Success
    }
    _ => {
      result.output["tool"] = ValString(tool_name)
      result.output["success"] = ValBool(true)
      result.status = Success
    }
  }
}

///|
fn execute_agent(node : @workflow.Node, result : NodeResult) -> Unit {
  let model = node.config.get("model").unwrap_or("gpt-4")
  let prompt = node.config.get("prompt").unwrap_or("")
  let response = "[MoonFlow Agent] Model: " +
    model +
    ", Prompt length: " +
    prompt.length().to_string()
  result.output["model"] = ValString(model)
  result.output["response"] = ValString(response)
  result.output["tokens_used"] = ValNumber(50.0)
  result.status = Success
}

///|
fn execute_control(node : @workflow.Node, result : NodeResult) -> Unit {
  let label = node.label.unwrap_or("end")
  match label {
    "condition" => {
      let cond = node.condition.unwrap_or("true")
      result.output["condition"] = ValString(cond)
      result.output["branch"] = ValString("true")
      result.status = Success
    }
    _ => {
      result.output["control"] = ValString(label)
      result.status = Success
    }
  }
}

///|
fn detect_tool_name(node : @workflow.Node) -> String {
  match node.config.get("tool") {
    Some(name) => name
    None => {
      let label = node.label.unwrap_or("")
      if label.contains("http") || label.contains("HTTP") {
        "http"
      } else if label.contains("email") || label.contains("Email") {
        "email"
      } else if label.contains("feishu") || label.contains("Feishu") {
        "feishu"
      } else if label.contains("file") || label.contains("File") {
        "file_read"
      } else {
        "generic"
      }
    }
  }
}
