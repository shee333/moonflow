///|
/// Retry component - retry logic with backoff.

///|
pub(all) struct RetryComponent {
  max_attempts : Int
  delay_ms : Int
  backoff_multiplier : Double
}

///|
pub fn RetryComponent::new(
  max_attempts? : Int = 3,
  delay_ms? : Int = 1000,
  backoff_multiplier? : Double = 2.0,
) -> RetryComponent {
  RetryComponent::{ max_attempts, delay_ms, backoff_multiplier }
}

///|
pub fn RetryComponent::info() -> ComponentInfo {
  ComponentInfo::{
    name: "retry",
    version: "1.0.0",
    description: "Retry with backoff component",
    category: CatTool,
  }
}
