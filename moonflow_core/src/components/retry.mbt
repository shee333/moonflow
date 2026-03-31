package moonflow_core::components

pub struct RetryComponent

pub enum RetryStrategy {
  | Fixed
  | Linear
  | Exponential
  | Fibonacci
}

pub fn create_retry_component() -> RetryComponent {
  RetryComponent
}