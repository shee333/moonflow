package moonflow_core::components

pub struct ThrottleComponent

pub enum ThrottleType {
  | TokenBucket
  | LeakyBucket
  | SlidingWindow
  | FixedWindow
}

pub struct ThrottleConfig {
  throttle_type: ThrottleType
  rate: Int
  capacity: Int
  window_ms: Int
}

pub fn create_throttle_component() -> ThrottleComponent {
  ThrottleComponent
}

pub fn create_throttle_config(throttle_type: ThrottleType, rate: Int) -> ThrottleConfig {
  ThrottleConfig::{
    throttle_type,
    rate,
    capacity: rate * 2,
    window_ms: 1000,
  }
}

pub fn create_throttle_config_with_window(
  throttle_type: ThrottleType,
  rate: Int,
  capacity: Int,
  window_ms: Int
) -> ThrottleConfig {
  ThrottleConfig::{
    throttle_type,
    rate,
    capacity,
    window_ms,
  }
}

impl Component for ThrottleComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let throttle_type = input.params.get_or("throttle_type", "token_bucket")
    let rate = input.params.get_or("rate", "100").to_int()
    let operation = input.data

    if operation == "" {
      return Err(ComponentError::ValidationError("Operation is required"))
    }

    execute_throttle_operation(throttle_type, rate, operation)
  }