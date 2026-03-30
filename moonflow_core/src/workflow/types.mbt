package moonflow_core::workflow

pub type NodeType =
  | Trigger
  | Tool
  | Agent
  | Control

pub type TriggerType =
  | Timer
  | Webhook
  | Manual

pub type ToolType =
  | HttpGet
  | HttpPost
  | Email
  | Feishu
  | FileRead
  | FileWrite
  | FileDelete

pub type AgentType =
  | LLM
  | IntentClassify

pub type ControlType =
  | Condition
  | Parallel
  | Loop
  | End

pub type RetryStrategy =
  | ExponentialBackoff
  | Linear
  | Fixed

pub type JoinType =
  | All
  | Any
  | N

pub type EndStatus =
  | Success
  | Failure

pub struct RetryConfig {
  max_attempts: Int
  strategy: RetryStrategy
  initial_delay: Int
}

pub struct NodeMetadata {
  author: String?
  version: String?
  tags: Array[String]?
}

pub struct Node {
  id: String
  node_type: NodeType
  label: String?
  with: Map[String, String]
  timeout: Int?
  retry: RetryConfig?
  condition: String?
  isolation: IsolationConfig?
  approval: ApprovalConfig?
}

pub struct Edge {
  from: String
  to: String
  label: String?
  condition: String?
  data_mapping: Map[String, String]?
}

pub struct WorkflowConfig {
  timeout: Int?
  retry: RetryConfig?
  concurrency: Int?
}

pub struct Workflow {
  version: String
  name: String
  description: String?
  metadata: NodeMetadata?
  nodes: Array[Node]
  edges: Array[Edge]
  config: WorkflowConfig?
}

pub struct IsolationConfig {
  mode: String
  timeout: Int?
  memory_limit: Int?
  network: Bool?
  filesystem: String?
}

pub struct ApprovalConfig {
  required: Bool
  approvers: Array[String]?
  timeout: Int?
  message: String?
  auto_reject_if_timeout: Bool?
  min_approvals: Int?
}
