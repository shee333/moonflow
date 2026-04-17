///|
/// Core type definitions for MoonFlow workflow engine.

///|
pub(all) enum NodeType {
  Trigger
  Tool
  Agent
  Control
} derive(Show, Eq)

///|
pub(all) enum TriggerType {
  Timer
  Webhook
  Manual
} derive(Show, Eq)

///|
pub(all) enum ToolType {
  HttpGet
  HttpPost
  Email
  Feishu
  FileRead
  FileWrite
  FileDelete
} derive(Show, Eq)

///|
pub(all) enum AgentType {
  LLM
  IntentClassify
} derive(Show, Eq)

///|
pub(all) enum ControlType {
  Condition
  Parallel
  Loop
  End
} derive(Show, Eq)

///|
pub(all) enum RetryStrategy {
  ExponentialBackoff
  Linear
  Fixed
} derive(Show, Eq)

///|
pub(all) enum JoinType {
  All
  Any
  N
} derive(Show, Eq)

///|
pub(all) enum EndStatus {
  Success
  Failure
} derive(Show, Eq)

///|
pub(all) struct RetryConfig {
  max_attempts : Int
  strategy : RetryStrategy
  initial_delay : Int
} derive(Show)

///|
pub(all) struct NodeMetadata {
  author : String?
  version : String?
  tags : Array[String]?
}

///|
pub(all) struct Node {
  id : String
  node_type : NodeType
  label : String?
  config : Map[String, String]
  timeout : Int?
  retry : RetryConfig?
  condition : String?
  isolation : IsolationConfig?
  approval : ApprovalConfig?
}

///|
pub(all) struct Edge {
  from : String
  to : String
  label : String?
  condition : String?
  data_mapping : Map[String, String]?
}

///|
pub(all) struct WorkflowConfig {
  timeout : Int?
  retry : RetryConfig?
  concurrency : Int?
}

///|
pub(all) struct Workflow {
  version : String
  name : String
  description : String?
  metadata : NodeMetadata?
  nodes : Array[Node]
  edges : Array[Edge]
  config : WorkflowConfig?
}

///|
pub(all) struct IsolationConfig {
  mode : String
  timeout : Int?
  memory_limit : Int?
  network : Bool?
  filesystem : String?
}

///|
pub(all) struct ApprovalConfig {
  required : Bool
  approvers : Array[String]?
  timeout : Int?
  message : String?
  auto_reject_if_timeout : Bool?
  min_approvals : Int?
}
