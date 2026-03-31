package moonflow_core::workflow

pub fn parse_workflow_json(content: String) -> Workflow? {
  let json = parse_json(content)?
  let version = get_string(json, "version")?
  let name = get_string(json, "name")?
  let description = get_opt_string(json, "description")
  let metadata = parse_metadata(get_opt_map(json, "metadata"))
  let nodes = parse_nodes(get_array(json, "nodes"))?
  let edges = parse_edges(get_array(json, "edges"))?
  let config = parse_config(get_opt_map(json, "config"))
  Some(Workflow::{
    version,
    name,
    description,
    metadata,
    nodes,
    edges,
    config,
  })
}

fn parse_json(content: String) -> Map[String, JsonValue]? {
  None
}

pub enum JsonValue {
  String(String)
  Number(Double)
  Bool(Bool)
  Array(Array[JsonValue])
  Object(Map[String, JsonValue])
  Null
}

fn get_string(json: Map[String, JsonValue], key: String) -> String? {
  match json[key] {
    Some(JsonValue::String(s)) => Some(s)
    _ => None
  }
}

fn get_opt_string(json: Map[String, JsonValue], key: String) -> String? {
  match json[key] {
    Some(JsonValue::String(s)) => Some(s)
    _ => None
  }
}

fn get_opt_map(json: Map[String, JsonValue], key: String) -> Map[String, JsonValue]? {
  match json[key] {
    Some(JsonValue::Object(m)) => Some(m)
    _ => None
  }
}

fn get_array(json: Map[String, JsonValue], key: String) -> Array[JsonValue]? {
  match json[key] {
    Some(JsonValue::Array(arr)) => Some(arr)
    _ => None
  }
}

fn parse_metadata(json: Map[String, JsonValue]?) -> NodeMetadata? {
  match json {
    Some(m) => Some(NodeMetadata::{
      author: get_opt_string(m, "author"),
      version: get_opt_string(m, "version"),
      tags: parse_tags(get_opt_array(m, "tags")),
    })
    None => Some(NodeMetadata::{ author: None, version: None, tags: None })
  }
}

fn get_opt_array(json: Map[String, JsonValue], key: String) -> Array[JsonValue]? {
  match json[key] {
    Some(JsonValue::Array(arr)) => Some(arr)
    _ => None
  }
}

fn parse_tags(json: Array[JsonValue]?) -> Array[String]? {
  match json {
    Some(arr) => {
      let tags: Array[String] = []
      for val in arr {
        match val {
          JsonValue::String(s) => tags.push(s)
          _ => ()
        }
      }
      if tags.length() > 0 { Some(tags) } else { None }
    }
    None => None
  }
}

fn parse_nodes(arr: Array[JsonValue]) -> Array[Node]? {
  let nodes: Array[Node] = []
  for val in arr {
    match val {
      JsonValue::Object(m) => {
        match parse_node(m) {
          Some(n) => nodes.push(n)
          None => return None
        }
      }
      _ => return None
    }
  }
  Some(nodes)
}

fn parse_node(json: Map[String, JsonValue]) -> Node? {
  let id = get_string(json, "id")?
  let type_str = get_string(json, "type")?
  let node_type = parse_node_type(type_str)?
  let label = get_opt_string(json, "label")
  let with = parse_with(get_opt_map(json, "with"))
  let timeout = get_opt_int(json, "timeout")
  let retry = parse_retry(get_opt_map(json, "retry"))
  let condition = get_opt_string(json, "condition")
  let isolation = parse_isolation(get_opt_map(json, "isolation"))
  let approval = parse_approval(get_opt_map(json, "approval"))
  Some(Node::{
    id,
    node_type,
    label,
    with,
    timeout,
    retry,
    condition,
    isolation,
    approval,
  })
}

fn get_opt_int(json: Map[String, JsonValue], key: String) -> Int? {
  match json[key] {
    Some(JsonValue::Number(n)) => Some(n.to_int())
    _ => None
  }
}

fn parse_node_type(type_str: String) -> NodeType? {
  if type_str.starts_with("trigger.") {
    Some(NodeType::Trigger)
  } else if type_str.starts_with("tool.") {
    Some(NodeType::Tool)
  } else if type_str.starts_with("agent.") {
    Some(NodeType::Agent)
  } else if type_str.starts_with("control.") {
    Some(NodeType::Control)
  } else {
    None
  }
}

fn parse_with(json: Map[String, JsonValue]?) -> Map[String, String] {
  match json {
    Some(m) => {
      let result: Map[String, String] = {}
      for (k, v) in m {
        match v {
          JsonValue::String(s) => { result[k] = s }
          JsonValue::Number(n) => { result[k] = n.to_string() }
          JsonValue::Bool(b) => { result[k] = b.to_string() }
          _ => { result[k] = "" }
        }
      }
      result
    }
    None => {}
  }
}

fn parse_retry(json: Map[String, JsonValue]?) -> RetryConfig? {
  match json {
    Some(m) => {
      let max_attempts = get_opt_int(m, "max_attempts")
      let strategy_str = get_opt_string(m, "strategy")
      let initial_delay = get_opt_int(m, "initial_delay")
      let strategy = match strategy_str {
        Some("exponential_backoff") => RetryStrategy::ExponentialBackoff
        Some("linear") => RetryStrategy::Linear
        Some("fixed") => RetryStrategy::Fixed
        _ => RetryStrategy::ExponentialBackoff
      }
      Some(RetryConfig::{ max_attempts, strategy, initial_delay })
    }
    None => None
  }
}

fn parse_isolation(json: Map[String, JsonValue]?) -> IsolationConfig? {
  match json {
    Some(m) => {
      let mode = get_opt_string(m, "mode")
      let timeout = get_opt_int(m, "timeout")
      let memory_limit = get_opt_int(m, "memory_limit")
      let network = get_opt_bool(m, "network")
      let filesystem = get_opt_string(m, "filesystem")
      Some(IsolationConfig::{ mode, timeout, memory_limit, network, filesystem })
    }
    None => None
  }
}

fn get_opt_bool(json: Map[String, JsonValue], key: String) -> Bool? {
  match json[key] {
    Some(JsonValue::Bool(b)) => Some(b)
    _ => None
  }
}

fn parse_approval(json: Map[String, JsonValue]?) -> ApprovalConfig? {
  match json {
    Some(m) => {
      let required = get_opt_bool(m, "required")
      let approvers = parse_string_array(get_opt_array(m, "approvers"))
      let timeout = get_opt_int(m, "timeout")
      let message = get_opt_string(m, "message")
      let auto_reject_if_timeout = get_opt_bool(m, "auto_reject_if_timeout")
      let min_approvals = get_opt_int(m, "min_approvals")
      Some(ApprovalConfig::{
        required: required.unwrap_or(false),
        approvers,
        timeout,
        message,
        auto_reject_if_timeout,
        min_approvals,
      })
    }
    None => None
  }
}

fn parse_string_array(json: Array[JsonValue]?) -> Array[String]? {
  match json {
    Some(arr) => {
      let result: Array[String] = []
      for val in arr {
        match val {
          JsonValue::String(s) => result.push(s)
          _ => ()
        }
      }
      if result.length() > 0 { Some(result) } else { None }
    }
    None => None
  }
}

fn parse_edges(arr: Array[JsonValue]) -> Array[Edge]? {
  let edges: Array[Edge] = []
  for val in arr {
    match val {
      JsonValue::Object(m) => {
        match parse_edge(m) {
          Some(e) => edges.push(e)
          None => return None
        }
      }
      _ => return None
    }
  }
  Some(edges)
}

fn parse_edge(json: Map[String, JsonValue]) -> Edge? {
  let from = get_string(json, "from")?
  let to = get_string(json, "to")?
  let label = get_opt_string(json, "label")
  let condition = get_opt_string(json, "condition")
  let data_mapping = parse_data_mapping(get_opt_map(json, "data_mapping"))
  Some(Edge::{ from, to, label, condition, data_mapping })
}

fn parse_data_mapping(json: Map[String, JsonValue]?) -> Map[String, String]? {
  match json {
    Some(m) => {
      let result: Map[String, String] = {}
      for (k, v) in m {
        match v {
          JsonValue::String(s) => { result[k] = s }
          _ => ()
        }
      }
      if result.length() > 0 { Some(result) } else { None }
    }
    None => None
  }
}

fn parse_config(json: Map[String, JsonValue]?) -> WorkflowConfig? {
  match json {
    Some(m) => {
      let timeout = get_opt_int(m, "timeout")
      let retry = parse_retry(get_opt_map(m, "retry"))
      let concurrency = get_opt_int(m, "concurrency")
      Some(WorkflowConfig::{ timeout, retry, concurrency })
    }
    None => None
  }
}
