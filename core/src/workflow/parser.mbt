///|
/// Workflow JSON parser using MoonBit standard library @json.
/// Parses JSON string into Workflow types.

///|
pub suberror ParseError {
  ParseError(String)
}

///|
pub fn ParseError::to_string(self : ParseError) -> String {
  match self {
    ParseError(msg) => msg
  }
}

///|
pub fn parse_workflow_json(content : String) -> Workflow raise ParseError {
  let json = @json.parse(content) catch {
    e => raise ParseError("JSON parse error: \{e}")
  }
  guard json is Json::Object(root) else {
    raise ParseError("Workflow JSON must be an object")
  }
  let version = get_str_opt(root, "version").unwrap_or("v1")
  let name = get_str_req(root, "name")
  let description = get_str_opt(root, "description")
  let metadata = parse_metadata(root.get("metadata"))
  let nodes = parse_nodes(get_arr_req(root, "nodes"))
  let edges = parse_edges(get_arr_req(root, "edges"))
  let config = parse_config(root.get("config"))
  Workflow::{ version, name, description, metadata, nodes, edges, config }
}

///|
fn get_str_req(
  obj : Map[String, Json],
  key : String,
) -> String raise ParseError {
  match obj.get(key) {
    Some(Json::String(s)) => s
    Some(_) => raise ParseError("Field '\{key}' must be a string")
    None => raise ParseError("Missing required field '\{key}'")
  }
}

///|
fn get_str_opt(obj : Map[String, Json], key : String) -> String? {
  match obj.get(key) {
    Some(Json::String(s)) => Some(s)
    _ => None
  }
}

///|
fn get_int_opt(obj : Map[String, Json], key : String) -> Int? {
  match obj.get(key) {
    Some(Json::Number(n, ..)) => Some(n.to_int())
    _ => None
  }
}

///|
fn get_bool_opt(obj : Map[String, Json], key : String) -> Bool? {
  match obj.get(key) {
    Some(Json::True) => Some(true)
    Some(Json::False) => Some(false)
    _ => None
  }
}

///|
fn get_arr_req(
  obj : Map[String, Json],
  key : String,
) -> Array[Json] raise ParseError {
  match obj.get(key) {
    Some(Json::Array(arr)) => arr
    Some(_) => raise ParseError("Field '\{key}' must be an array")
    None => raise ParseError("Missing required field '\{key}'")
  }
}

///|
fn parse_metadata(json : Json?) -> NodeMetadata? {
  guard json is Some(Json::Object(m)) else { return None }
  Some(NodeMetadata::{
    author: get_str_opt(m, "author"),
    version: get_str_opt(m, "version"),
    tags: parse_string_array(m.get("tags")),
  })
}

///|
fn parse_string_array(json : Json?) -> Array[String]? {
  guard json is Some(Json::Array(arr)) else { return None }
  let result : Array[String] = []
  for val in arr {
    match val {
      Json::String(s) => result.push(s)
      _ => ()
    }
  }
  if result.length() > 0 {
    Some(result)
  } else {
    None
  }
}

///|
fn parse_nodes(arr : Array[Json]) -> Array[Node] raise ParseError {
  let nodes : Array[Node] = []
  for val in arr {
    guard val is Json::Object(m) else {
      raise ParseError("Each node must be an object")
    }
    nodes.push(parse_node(m))
  }
  nodes
}

///|
fn parse_node(json : Map[String, Json]) -> Node raise ParseError {
  let id = get_str_req(json, "id")
  let type_str = get_str_req(json, "type")
  let node_type = parse_node_type(type_str)
  let label = get_str_opt(json, "label")
  let config_map = parse_with_map(json.get("with"))
  let timeout = get_int_opt(json, "timeout")
  let retry = parse_retry(json.get("retry"))
  let condition = get_str_opt(json, "condition")
  let isolation = parse_isolation(json.get("isolation"))
  let approval = parse_approval(json.get("approval"))
  Node::{
    id,
    node_type,
    label,
    config: config_map,
    timeout,
    retry,
    condition,
    isolation,
    approval,
  }
}

///|
fn parse_node_type(type_str : String) -> NodeType raise ParseError {
  if type_str.has_prefix("trigger") {
    Trigger
  } else if type_str.has_prefix("tool") {
    Tool
  } else if type_str.has_prefix("agent") {
    Agent
  } else if type_str.has_prefix("control") {
    Control
  } else {
    match type_str {
      "llm" | "LLM" => Agent
      "http" | "http-trigger" => Tool
      "trigger" => Trigger
      "condition" | "code" | "response" | "template" | "end" => Control
      _ => raise ParseError("Unknown node type: \{type_str}")
    }
  }
}

///|
fn parse_with_map(json : Json?) -> Map[String, String] {
  let result : Map[String, String] = {}
  guard json is Some(Json::Object(m)) else { return result }
  for k, v in m {
    match v {
      Json::String(s) => result[k] = s
      Json::Number(n, ..) => result[k] = n.to_string()
      Json::True => result[k] = "true"
      Json::False => result[k] = "false"
      _ => result[k] = ""
    }
  }
  result
}

///|
fn parse_retry(json : Json?) -> RetryConfig? {
  guard json is Some(Json::Object(m)) else { return None }
  let max_attempts = get_int_opt(m, "max_attempts").unwrap_or(3)
  let strategy_str = get_str_opt(m, "strategy")
  let initial_delay = get_int_opt(m, "initial_delay").unwrap_or(1000)
  let strategy = match strategy_str {
    Some("exponential_backoff") | Some("exponential") => ExponentialBackoff
    Some("linear") => Linear
    Some("fixed") => Fixed
    _ => ExponentialBackoff
  }
  Some(RetryConfig::{ max_attempts, strategy, initial_delay })
}

///|
fn parse_isolation(json : Json?) -> IsolationConfig? {
  guard json is Some(Json::Object(m)) else { return None }
  Some(IsolationConfig::{
    mode: get_str_opt(m, "mode").unwrap_or("none"),
    timeout: get_int_opt(m, "timeout"),
    memory_limit: get_int_opt(m, "memory_limit"),
    network: get_bool_opt(m, "network"),
    filesystem: get_str_opt(m, "filesystem"),
  })
}

///|
fn parse_approval(json : Json?) -> ApprovalConfig? {
  guard json is Some(Json::Object(m)) else { return None }
  Some(ApprovalConfig::{
    required: get_bool_opt(m, "required").unwrap_or(false),
    approvers: parse_string_array(m.get("approvers")),
    timeout: get_int_opt(m, "timeout"),
    message: get_str_opt(m, "message"),
    auto_reject_if_timeout: get_bool_opt(m, "auto_reject_if_timeout"),
    min_approvals: get_int_opt(m, "min_approvals"),
  })
}

///|
fn parse_edges(arr : Array[Json]) -> Array[Edge] raise ParseError {
  let edges : Array[Edge] = []
  for val in arr {
    guard val is Json::Object(m) else {
      raise ParseError("Each edge must be an object")
    }
    edges.push(parse_edge(m))
  }
  edges
}

///|
fn parse_edge(json : Map[String, Json]) -> Edge raise ParseError {
  // Support both from/to and source/target (frontend may use either)
  let from = match get_str_opt(json, "from") {
    Some(s) => s
    None =>
      match get_str_opt(json, "source") {
        Some(s) => s
        None => raise ParseError("Edge missing 'from' or 'source' field")
      }
  }
  let to = match get_str_opt(json, "to") {
    Some(s) => s
    None =>
      match get_str_opt(json, "target") {
        Some(s) => s
        None => raise ParseError("Edge missing 'to' or 'target' field")
      }
  }
  let label = get_str_opt(json, "label")
  let condition = get_str_opt(json, "condition")
  let data_mapping = parse_data_mapping(json.get("data_mapping"))
  Edge::{ from, to, label, condition, data_mapping }
}

///|
fn parse_data_mapping(json : Json?) -> Map[String, String]? {
  guard json is Some(Json::Object(m)) else { return None }
  let result : Map[String, String] = {}
  for k, v in m {
    match v {
      Json::String(s) => result[k] = s
      _ => ()
    }
  }
  if result.length() > 0 {
    Some(result)
  } else {
    None
  }
}

///|
fn parse_config(json : Json?) -> WorkflowConfig? {
  guard json is Some(Json::Object(m)) else { return None }
  Some(WorkflowConfig::{
    timeout: get_int_opt(m, "timeout"),
    retry: parse_retry(m.get("retry")),
    concurrency: get_int_opt(m, "concurrency"),
  })
}
