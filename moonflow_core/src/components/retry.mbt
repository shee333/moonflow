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