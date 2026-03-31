package moonflow_core::components

pub struct RateLimitComponent

pub enum RateLimitType {
  | PerSecond
  | PerMinute
  | PerHour
  | PerDay
}

pub struct RateLimitConfig {
  rate_limit_type: RateLimitType
  max_requests: Int
  burst_size: Int
}

pub fn create_rate_limit_component() -> RateLimitComponent {
  RateLimitComponent
}

pub fn create_rate_limit_config(rate_limit_type: RateLimitType, max_requests: Int) -> RateLimitConfig {
  RateLimitConfig::{
    rate_limit_type,
    max_requests,
    burst_size: max_requests * 2,
  }
}
