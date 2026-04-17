///|
/// Runtime execution context and core types.

///|
pub(all) struct ExecutionContext {
  data : Map[String, Value]
  metadata : ExecutionMetadata
}

///|
pub(all) struct ExecutionMetadata {
  workflow_name : String
  start_time : Int
  end_time : Int
  node_results : Map[String, NodeResult]
  logs : Array[LogEntry]
}

///|
pub(all) enum Value {
  ValString(String)
  ValNumber(Double)
  ValBool(Bool)
  ValNull
} derive(Show, Eq)

///|
pub(all) struct NodeResult {
  node_id : String
  mut status : NodeStatus
  output : Map[String, Value]
  error_msg : String?
  duration_ms : Int
} derive(Show)

///|
pub(all) enum NodeStatus {
  Pending
  Running
  Success
  Failure
  Skipped
} derive(Show, Eq)

///|
pub(all) struct LogEntry {
  level : LogLevel
  message : String
  node_id : String?
  timestamp : Int
}

///|
pub(all) enum LogLevel {
  Debug
  Info
  Warning
  Error
} derive(Show, Eq)

///|
pub fn ExecutionContext::new(workflow_name : String) -> ExecutionContext {
  ExecutionContext::{
    data: {},
    metadata: ExecutionMetadata::{
      workflow_name,
      start_time: 0,
      end_time: 0,
      node_results: {},
      logs: [],
    },
  }
}

///|
pub fn ExecutionContext::set_value(
  self : ExecutionContext,
  key : String,
  value : Value,
) -> Unit {
  self.data[key] = value
}

///|
pub fn ExecutionContext::get_value(
  self : ExecutionContext,
  key : String,
) -> Value? {
  self.data.get(key)
}

///|
pub fn ExecutionContext::set_node_result(
  self : ExecutionContext,
  node_id : String,
  result : NodeResult,
) -> Unit {
  self.metadata.node_results[node_id] = result
}

///|
pub fn ExecutionContext::get_node_result(
  self : ExecutionContext,
  node_id : String,
) -> NodeResult? {
  self.metadata.node_results.get(node_id)
}

///|
pub fn ExecutionContext::add_log(
  self : ExecutionContext,
  level : LogLevel,
  message : String,
  node_id : String?,
) -> Unit {
  self.metadata.logs.push(LogEntry::{ level, message, node_id, timestamp: 0 })
}

///|
pub fn value_to_string(v : Value) -> String {
  match v {
    ValString(s) => s
    ValNumber(n) => n.to_string()
    ValBool(b) => b.to_string()
    ValNull => "null"
  }
}

///|
pub fn format_log_level(level : LogLevel) -> String {
  match level {
    Debug => "DEBUG"
    Info => "INFO"
    Warning => "WARN"
    Error => "ERROR"
  }
}

///|
pub fn format_node_status(status : NodeStatus) -> String {
  match status {
    Pending => "pending"
    Running => "running"
    Success => "success"
    Failure => "failure"
    Skipped => "skipped"
  }
}
