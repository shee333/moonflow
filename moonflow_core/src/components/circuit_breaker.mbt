package moonflow_core::components

pub struct CircuitBreakerComponent

pub enum CircuitState {
  | Closed
  | Open
  | HalfOpen
}

pub struct CircuitBreakerConfig {
  failure_threshold: Int
  success_threshold: Int
  timeout_ms: Int
  half_open_max_calls: Int
}

pub fn create_circuit_breaker_component() -> CircuitBreakerComponent {
  CircuitBreakerComponent
}

pub fn create_circuit_breaker_config(failure_threshold: Int) -> CircuitBreakerConfig {
  CircuitBreakerConfig::{
    failure_threshold,
    success_threshold: 2,
    timeout_ms: 60000,
    half_open_max_calls: 3,
  }
}

pub fn create_circuit_breaker_config_with_timeout(
  failure_threshold: Int,
  timeout_ms: Int
) -> CircuitBreakerConfig {
  CircuitBreakerConfig::{
    failure_threshold,
    success_threshold: 2,
    timeout_ms,
    half_open_max_calls: 3,
  }
}

impl Component for CircuitBreakerComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let state = input.params.get_or("state", "closed")
    let operation = input.data

    if operation == "" {
      return Err(ComponentError::ValidationError("Operation is required"))
    }

    execute_circuit_breaker_operation(state, operation)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["state"] {
      Some(s) => is_valid_circuit_state(s)
      None => true
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "circuit_breaker",
      version: "1.0.0",
      description: "Circuit breaker component with closed, open, half_open states",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "state", type_: "string", required: true, description: "Circuit state: closed/open/half_open" },
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Operation to protect" },
      ],
      outputs: [
        OutputSchema::{ name: "allowed", type_: "boolean", description: "Whether operation is allowed" },
        OutputSchema::{ name: "state", type_: "string", description: "Current circuit state" },
      ],
    }
  }
}