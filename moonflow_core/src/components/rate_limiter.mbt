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
