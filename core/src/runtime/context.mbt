package moonflow_core::runtime

pub struct ExecutionContext {
  data: Map[String, Value]
  metadata: ExecutionMetadata
}

pub struct ExecutionMetadata {
  workflow_id: String?
  execution_id: String
  start_time: Int
  node_results: Map[String, NodeResult]
  logs: Array[LogEntry]
}

pub enum Value {
  String(String)
  Number(Double)
  Bool(Bool)
  Array(Array[Value])
  Object(Map[String, Value])
  Null
}

pub struct NodeResult {
  node_id: String
  status: NodeStatus
  output: Value?
  error: String?
  duration_ms: Int
  timestamp: Int
}

pub enum NodeStatus {
  Pending
  Running
  Success
  Failure
  Skipped
}

pub struct LogEntry {
  level: LogLevel
  message: String
  timestamp: Int
  node_id: String?
}

pub enum LogLevel {
  Debug
  Info
  Warning
  Error
}

pub fn ExecutionContext::new(execution_id~: String) -> ExecutionContext {
  {
    data: {},
    metadata: {
      workflow_id: None,
      execution_id,
      start_time: get_timestamp(),
      node_results: {},
      logs: [],
    },
  }
}

pub fn ExecutionContext::set(self: ExecutionContext, key: String, value: Value) -> Unit {
  self.data[key] = value
}

pub fn ExecutionContext::get(self: ExecutionContext, key: String) -> Value? {
  self.data[key]
}

pub fn ExecutionContext::get_string(self: ExecutionContext, key: String) -> String? {
  match self.data[key] {
    Some(Value::String(s)) => Some(s)
    _ => None
  }
}

pub fn ExecutionContext::get_number(self: ExecutionContext, key: String) -> Double? {
  match self.data[key] {
    Some(Value::Number(n)) => Some(n)
    _ => None
  }
}

pub fn ExecutionContext::get_bool(self: ExecutionContext, key: String) -> Bool? {
  match self.data[key] {
    Some(Value::Bool(b)) => Some(b)
    _ => None
  }
}

pub fn ExecutionContext::log(
  self: ExecutionContext,
  level~: LogLevel = LogLevel::Info,
  message~: String,
  node_id~: String? = None,
) -> Unit {
  let entry = {
    level,
    message,
    timestamp: get_timestamp(),
    node_id,
  }
  self.metadata.logs.push(entry)
}

pub fn ExecutionContext::record_result(
  self: ExecutionContext,
  result: NodeResult,
) -> Unit {
  self.metadata.node_results[result.node_id] = result
}

pub fn ExecutionContext::get_result(
  self: ExecutionContext,
  node_id: String,
) -> NodeResult? {
  self.metadata.node_results[node_id]
}

pub fn ExecutionMetadata::get_duration(self: ExecutionMetadata) -> Int {
  get_timestamp() - self.start_time
}

pub fn ExecutionMetadata::get_success_count(self: ExecutionMetadata) -> Int {
  let count = 0
  for (_, result) in self.node_results {
    match result.status {
      NodeStatus::Success => count + 1
      _ => count
    }
  }
  count
}

pub fn ExecutionMetadata::get_failure_count(self: ExecutionMetadata) -> Int {
  let count = 0
  for (_, result) in self.node_results {
    match result.status {
      NodeStatus::Failure => count + 1
      _ => count
    }
  }
  count
}

fn get_timestamp() -> Int {
  0
}

pub fn Value::to_string(self: Value) -> String {
  match self {
    Value::String(s) => s
    Value::Number(n) => n.to_string()
    Value::Bool(b) => b.to_string()
    Value::Array(arr) => "[{arr.map(fn(v) { v.to_string() }).join(\", \")}]"
    Value::Object(obj) => {
      let pairs = []
      for (k, v) in obj {
        pairs.push("\{k}: \{v.to_string()}")
      }
      "\{{pairs.join(\", \")}}"
    }
    Value::Null => "null"
  }
}
