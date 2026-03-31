package moonflow_core::components

pub type ComponentResult = Result[ComponentOutput, ComponentError]

pub struct ComponentOutput {
  data: String
  metadata: Map[String, String]
}

pub type ComponentError =
  | NetworkError(String)
  | AuthenticationError(String)
  | ValidationError(String)
  | ExecutionError(String)
  | TimeoutError
  | RateLimitError
  | UnknownError(String)

pub trait Component {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult
  fn validate(config: Map[String, String]) -> Bool
  fn get_metadata() -> ComponentMetadata
}

pub struct ComponentInput {
  data: String
  params: Map[String, String]
  secrets: Map[String, String]
}

pub struct ComponentMetadata {
  name: String
  version: String
  description: String
  category: ComponentCategory
  inputs: Array[InputSchema]
  outputs: Array[OutputSchema]
}

pub enum ComponentCategory {
  | Trigger
  | Tool
  | Agent
  | Control
}

pub struct InputSchema {
  name: String
  type_: String
  required: Bool
  description: String
}

pub struct OutputSchema {
  name: String
  type_: String
  description: String
}

pub fn create_component_input(
  data: String,
  params: Map[String, String],
  secrets: Map[String, String]
) -> ComponentInput {
  ComponentInput::{ data, params, secrets }
}

pub fn create_component_output(data: String) -> ComponentOutput {
  ComponentOutput::{ data, metadata: {} }
}

pub fn create_component_output_with_metadata(
  data: String,
  metadata: Map[String, String]
) -> ComponentOutput {
  ComponentOutput::{ data, metadata }
}

pub fn format_component_error(error: ComponentError) -> String {
  match error {
    ComponentError::NetworkError(msg) => "Network error: \{msg}"
    ComponentError::AuthenticationError(msg) => "Authentication error: \{msg}"
    ComponentError::ValidationError(msg) => "Validation error: \{msg}"
    ComponentError::ExecutionError(msg) => "Execution error: \{msg}"
    ComponentError::TimeoutError => "Request timeout"
    ComponentError::RateLimitError => "Rate limit exceeded"
    ComponentError::UnknownError(msg) => "Unknown error: \{msg}"
  }
}
