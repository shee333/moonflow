package moonflow_core

pub type NodeType = moonflow_core::workflow::NodeType
pub type TriggerType = moonflow_core::workflow::TriggerType
pub type ToolType = moonflow_core::workflow::ToolType
pub type AgentType = moonflow_core::workflow::AgentType
pub type ControlType = moonflow_core::workflow::ControlType

pub type Workflow = moonflow_core::workflow::Workflow
pub type Node = moonflow_core::workflow::Node
pub type Edge = moonflow_core::workflow::Edge

pub type ExecutorResult = moonflow_core::runtime::ExecutorResult
pub type ExecutorError = moonflow_core::runtime::ExecutorError

pub type WorkflowResult = moonflow_core::runtime::WorkflowResult
pub type WorkflowExecution = moonflow_core::runtime::WorkflowExecution
pub type WorkflowStatus = moonflow_core::runtime::WorkflowStatus
pub type WorkflowError = moonflow_core::runtime::WorkflowError

pub type ExecutionContext = moonflow_core::runtime::ExecutionContext
pub type ExecutionMetadata = moonflow_core::runtime::ExecutionMetadata
pub type NodeResult = moonflow_core::runtime::NodeResult
pub type NodeStatus = moonflow_core::runtime::NodeStatus
pub type Value = moonflow_core::runtime::Value
pub type LogEntry = moonflow_core::runtime::LogEntry
pub type LogLevel = moonflow_core::runtime::LogLevel

pub fn create_context(execution_id~: String) -> ExecutionContext {
  moonflow_core::runtime::ExecutionContext::new(execution_id~)
}

pub fn execute_workflow(workflow: Workflow) -> WorkflowResult {
  moonflow_core::runtime::execute_workflow(workflow)
}

pub fn validate_workflow(workflow: Workflow) -> moonflow_core::workflow::ValidationResult {
  moonflow_core::workflow::validate_workflow(workflow)
}

pub fn format_validation_error(error: moonflow_core::workflow::ValidationError) -> String {
  moonflow_core::workflow::format_validation_error(error)
}
