///|
/// Rate limiter component.

///|
pub(all) struct RateLimiterComponent {
  max_requests : Int
  window_ms : Int
  mut current_count : Int
}

///|
pub fn RateLimiterComponent::new(
  max_requests? : Int = 100,
  window_ms? : Int = 60000,
) -> RateLimiterComponent {
  RateLimiterComponent::{ max_requests, window_ms, current_count: 0 }
}

///|
pub fn RateLimiterComponent::allow(self : RateLimiterComponent) -> Bool {
  if self.current_count < self.max_requests {
    self.current_count = self.current_count + 1
    true
  } else {
    false
  }
}

///|
pub fn RateLimiterComponent::info() -> ComponentInfo {
  ComponentInfo::{
    name: "rate_limiter",
    version: "1.0.0",
    description: "Rate limiting component",
    category: CatTool,
  }
}
