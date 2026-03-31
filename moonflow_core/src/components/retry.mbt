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