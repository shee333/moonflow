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