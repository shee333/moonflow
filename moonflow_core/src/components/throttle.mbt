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