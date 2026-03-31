package moonflow_core::runtime

pub type ExecutorResult = Result[String, ExecutorError]

pub type ExecutorError =
  | Timeout
  | NetworkError(String)
  | ValidationError(String)
  | ExecutionError(String)
  | RateLimitError

pub trait NodeExecutor {
  fn execute(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult
}

pub struct TriggerExecutor

pub struct ToolExecutor

pub struct AgentExecutor

pub struct ControlExecutor

pub fn execute_node(
  node: moonflow_core::workflow::Node,
  ctx: ExecutionContext
) -> ExecutorResult {
  match node.node_type {
    moonflow_core::workflow::NodeType::Trigger => {
      execute_trigger(node, ctx)
    }
    moonflow_core::workflow::NodeType::Tool => {
      execute_tool(node, ctx)
    }
    moonflow_core::workflow::NodeType::Agent => {
      execute_agent(node, ctx)
    }
    moonflow_core::workflow::NodeType::Control => {
      execute_control(node, ctx)
    }
  }
}

fn execute_trigger(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  let trigger_type = detect_trigger_type(node)

  match trigger_type {
    "timer" => execute_timer_trigger(node, ctx),
    "webhook" => execute_webhook_trigger(node, ctx),
    "manual" => execute_manual_trigger(node, ctx),
    _ => Err(ExecutorError::ValidationError("Unknown trigger type"))
  }
}

fn execute_tool(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  let tool_type = detect_tool_type(node)

  match tool_type {
    "http_get" => execute_http_get(node, ctx),
    "http_post" => execute_http_post(node, ctx),
    "email" => execute_email(node, ctx),
    "feishu" => execute_feishu(node, ctx),
    "file_read" => execute_file_read(node, ctx),
    "file_write" => execute_file_write(node, ctx),
    "file_delete" => execute_file_delete(node, ctx),
    _ => Err(ExecutorError::ValidationError("Unknown tool type"))
  }
}

fn execute_agent(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  let agent_type = detect_agent_type(node)

  match agent_type {
    "llm" => execute_llm_agent(node, ctx),
    "intent_classify" => execute_intent_classify(node, ctx),
    _ => Err(ExecutorError::ValidationError("Unknown agent type"))
  }
}

fn execute_control(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  let control_type = detect_control_type(node)

  match control_type {
    "condition" => execute_condition(node, ctx),
    "parallel" => execute_parallel(node, ctx),
    "loop" => execute_loop(node, ctx),
    "end" => execute_end(node, ctx),
    _ => Err(ExecutorError::ValidationError("Unknown control type"))
  }
}

fn detect_trigger_type(node: moonflow_core::workflow::Node) -> String {
  let with = node.with
  if with.contains("schedule") {
    return "timer"
  } else if with.contains("path") {
    return "webhook"
  } else {
    return "manual"
  }
}

fn detect_tool_type(node: moonflow_core::workflow::Node) -> String {
  let with = node.with
  if with.contains("url") {
    if with.contains("method") {
      return "http_post"
    }
    return "http_get"
  } else if with.contains("smtp_host") {
    return "email"
  } else if with.contains("webhook") {
    return "feishu"
  } else if with.contains("path") {
    if with.contains("content") {
      return "file_write"
    } else if with.contains("delete") {
      return "file_delete"
    }
    return "file_read"
  }
  "unknown"
}

fn detect_agent_type(node: moonflow_core::workflow::Node) -> String {
  let with = node.with
  if with.contains("model") && with.contains("prompt") {
    return "llm"
  } else if with.contains("intents") {
    return "intent_classify"
  }
  "unknown"
}

fn detect_control_type(node: moonflow_core::workflow::Node) -> String {
  let with = node.with
  if with.contains("expression") {
    return "condition"
  } else if with.contains("join_type") {
    return "parallel"
  } else if with.contains("items") {
    return "loop"
  } else if with.contains("status") {
    return "end"
  }
  "unknown"
}

fn execute_timer_trigger(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  Ok("Timer triggered successfully")
}

fn execute_webhook_trigger(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  Ok("Webhook received successfully")
}

fn execute_manual_trigger(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  Ok("Manual trigger activated")
}

fn execute_http_get(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["url"] {
    Some(url) => {
      Ok("HTTP GET \{url} completed")
    }
    None => Err(ExecutorError::ValidationError("Missing URL parameter"))
  }
}

fn execute_http_post(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["url"] {
    Some(url) => {
      Ok("HTTP POST \{url} completed")
    }
    None => Err(ExecutorError::ValidationError("Missing URL parameter"))
  }
}

fn execute_email(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["to"] {
    Some(to) => {
      Ok("Email sent to \{to}")
    }
    None => Err(ExecutorError::ValidationError("Missing recipient"))
  }
}

fn execute_feishu(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["webhook"] {
    Some(_) => {
      Ok("Feishu message sent")
    }
    None => Err(ExecutorError::ValidationError("Missing webhook"))
  }
}

fn execute_file_read(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["path"] {
    Some(path) => {
      Ok("File \{path} read successfully")
    }
    None => Err(ExecutorError::ValidationError("Missing file path"))
  }
}

fn execute_file_write(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["path"] {
    Some(path) => {
      Ok("File \{path} written successfully")
    }
    None => Err(ExecutorError::ValidationError("Missing file path"))
  }
}

fn execute_file_delete(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["path"] {
    Some(path) => {
      Ok("File \{path} deleted successfully")
    }
    None => Err(ExecutorError::ValidationError("Missing file path"))
  }
}

fn execute_llm_agent(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["model"] {
    Some(model) => {
      let prompt = node.with["prompt"].unwrap_or("No prompt provided")
      Ok("LLM \{model} response: [Generated content based on prompt: \{prompt}]")
    }
    None => Err(ExecutorError::ValidationError("Missing model parameter"))
  }
}

fn execute_intent_classify(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["intents"] {
    Some(intents) => {
      Ok("Intent classified as: \{intents}")
    }
    None => Err(ExecutorError::ValidationError("Missing intents parameter"))
  }
}

fn execute_condition(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["expression"] {
    Some(expr) => {
      Ok("Condition evaluated: \{expr}")
    }
    None => Err(ExecutorError::ValidationError("Missing expression"))
  }
}

fn execute_parallel(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["join_type"] {
    Some(join_type) => {
      Ok("Parallel execution with join type: \{join_type}")
    }
    None => Err(ExecutorError::ValidationError("Missing join_type"))
  }
}

fn execute_loop(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["items"] {
    Some(items) => {
      let max_iterations = node.with["max_iterations"].unwrap_or("100")
      Ok("Loop executed for items: \{items}, max iterations: \{max_iterations}")
    }
    None => Err(ExecutorError::ValidationError("Missing items"))
  }
}

fn execute_end(node: moonflow_core::workflow::Node, ctx: ExecutionContext) -> ExecutorResult {
  match node.with["status"] {
    Some(status) => {
      Ok("Workflow ended with status: \{status}")
    }
    None => Ok("Workflow ended")
  }
}

pub fn handle_timeout(node: moonflow_core::workflow::Node) -> ExecutorResult {
  Err(ExecutorError::Timeout)
}

pub fn handle_retry(
  node: moonflow_core::workflow::Node,
  retry_config: moonflow_core::workflow::RetryConfig,
  attempt: Int
) -> ExecutorResult {
  let delay = match retry_config.strategy {
    moonflow_core::workflow::RetryStrategy::ExponentialBackoff => {
      retry_config.initial_delay.unwrap_or(1000) * (2 ** attempt)
    }
    moonflow_core::workflow::RetryStrategy::Linear => {
      retry_config.initial_delay.unwrap_or(1000) * attempt
    }
    moonflow_core::workflow::RetryStrategy::Fixed => {
      retry_config.initial_delay.unwrap_or(1000)
    }
  }

  if attempt < retry_config.max_attempts.unwrap_or(3) {
    Ok("Retry scheduled in \{delay}ms, attempt \{attempt + 1}")
  } else {
    Err(ExecutorError::ExecutionError("Max retry attempts exceeded"))
  }
}
