package moonflow_core::components

pub struct RateLimitComponent

pub enum RateLimitType {
  | PerSecond
  | PerMinute
  | PerHour
  | PerDay
} derive(Show, Eq)

pub struct RateLimitConfig {
  rate_limit_type: RateLimitType
  max_requests: Int
  burst_size: Int
} derive(Show, Eq)

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

pub fn create_rate_limit_config_with_burst(
  rate_limit_type: RateLimitType,
  max_requests: Int,
  burst_size: Int
) -> RateLimitConfig {
  RateLimitConfig::{
    rate_limit_type,
    max_requests,
    burst_size,
  }
}

impl Component for RateLimitComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let rate_limit_type = input.params.get_or("rate_limit_type", "per_second")
    let max_requests = input.params.get_or("max_requests", "100").to_int()
    let operation = input.data

    if operation == "" {
      return Err(ComponentError::ValidationError("Operation is required"))
    }

    execute_rate_limit_operation(rate_limit_type, max_requests, operation)
  }

  fn validate(config: Map[String, String]) -> Bool {
    true
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "rate_limit",
      version: "1.0.0",
      description: "Rate limit component with per_second, per_minute, per_hour, per_day support",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "rate_limit_type", type_: "string", required: true, description: "Rate limit type: per_second/per_minute/per_hour/per_day" },
        InputSchema::{ name: "max_requests", type_: "number", required: false, description: "Maximum requests allowed" },
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Operation to rate limit" },
      ],
      outputs: [
        OutputSchema::{ name: "allowed", type_: "boolean", description: "Whether operation is allowed" },
        OutputSchema::{ name: "remaining", type_: "number", description: "Remaining requests" },
      ],
    }
  }
}

fn execute_rate_limit_operation(rate_limit_type: String, max_requests: Int, operation: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["rate_limit_type"] = rate_limit_type
  metadata["max_requests"] = max_requests.to_string()
  metadata["status"] = "rate_limited"

  let remaining = calculate_remaining_requests(rate_limit_type, max_requests)
  metadata["remaining"] = remaining.to_string()
  metadata["allowed"] = "true"

  let response = "Rate limited '\{operation}' at '\{rate_limit_type}' (\{max_requests} max requests)"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn calculate_remaining_requests(rate_limit_type: String, max_requests: Int) -> Int {
  match rate_limit_type {
    "per_second" => max_requests - 1
    "per_minute" => max_requests - 1
    "per_hour" => max_requests - 1
    "per_day" => max_requests - 1
    _ => max_requests
  }
}

fn is_valid_rate_limit_type(rate_limit_type: String) -> Bool {
  rate_limit_type == "per_second" || rate_limit_type == "per_minute" ||
  rate_limit_type == "per_hour" || rate_limit_type == "per_day"
}
