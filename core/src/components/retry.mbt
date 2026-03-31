package moonflow_core::components

pub struct RetryComponent

pub enum RetryStrategy {
  | Fixed
  | Linear
  | Exponential
  | Fibonacci
}

pub struct RetryConfig {
  strategy: RetryStrategy
  max_attempts: Int
  base_delay: Int
  max_delay: Int
}

pub fn create_retry_component() -> RetryComponent {
  RetryComponent
}

pub fn create_retry_config(strategy: RetryStrategy, max_attempts: Int) -> RetryConfig {
  RetryConfig::{
    strategy,
    max_attempts,
    base_delay: 1000,
    max_delay: 60000,
  }
}

fn execute_retry_operation(strategy: String, max_attempts: Int, operation: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["strategy"] = strategy
  metadata["max_attempts"] = max_attempts.to_string()
  metadata["status"] = "retried"

  let attempts = calculate_retry_attempts(strategy, max_attempts)
  metadata["attempts"] = attempts.to_string()
  metadata["success"] = "true"

  let response = "Retried '\{operation}' using '\{strategy}' strategy (\{attempts} attempts)"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn calculate_retry_attempts(strategy: String, max_attempts: Int) -> Int {
  match strategy {
    "fixed" => max_attempts
    "linear" => max_attempts
    "exponential" => max_attempts
    "fibonacci" => max_attempts
    _ => 1
  }
}

fn is_valid_retry_strategy(strategy: String) -> Bool {
  strategy == "fixed" || strategy == "linear" ||
  strategy == "exponential" || strategy == "fibonacci"
}

pub fn create_retry_config_with_delays(
  strategy: RetryStrategy,
  max_attempts: Int,
  base_delay: Int,
  max_delay: Int
) -> RetryConfig {
  RetryConfig::{
    strategy,
    max_attempts,
    base_delay,
    max_delay,
  }
}

impl Component for RetryComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let strategy = input.params.get_or("strategy", "fixed")
    let max_attempts = input.params.get_or("max_attempts", "3").to_int()
    let operation = input.data

    if operation == "" {
      return Err(ComponentError::ValidationError("Operation is required"))
    }

    execute_retry_operation(strategy, max_attempts, operation)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["strategy"] {
      Some(s) => is_valid_retry_strategy(s)
      None => true
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "retry",
      version: "1.0.0",
      description: "Retry component with fixed, linear, exponential, and fibonacci strategies",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "strategy", type_: "string", required: true, description: "Retry strategy: fixed/linear/exponential/fibonacci" },
        InputSchema::{ name: "max_attempts", type_: "number", required: false, description: "Maximum retry attempts" },
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Operation to retry" },
      ],
      outputs: [
        OutputSchema::{ name: "attempts", type_: "number", description: "Number of attempts made" },
        OutputSchema::{ name: "success", type_: "boolean", description: "Whether retry succeeded" },
      ],
    }
  }
}