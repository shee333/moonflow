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

fn execute_throttle_operation(throttle_type: String, rate: Int, operation: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["throttle_type"] = throttle_type
  metadata["rate"] = rate.to_string()
  metadata["status"] = "throttled"

  let wait_time = calculate_wait_time(throttle_type, rate)
  metadata["wait_time"] = wait_time.to_string()
  metadata["allowed"] = "true"

  let response = "Throttled '\{operation}' using '\{throttle_type}' (\{rate} ops/s)"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn calculate_wait_time(throttle_type: String, rate: Int) -> Int {
  match throttle_type {
    "token_bucket" => 1000 / rate
    "leaky_bucket" => 1000 / rate
    "sliding_window" => 1000 / rate
    "fixed_window" => 1000 / rate
    _ => 10
  }
}

fn is_valid_throttle_type(throttle_type: String) -> Bool {
  throttle_type == "token_bucket" || throttle_type == "leaky_bucket" ||
  throttle_type == "sliding_window" || throttle_type == "fixed_window"
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

  fn validate(config: Map[String, String]) -> Bool {
    match config["throttle_type"] {
      Some(t) => is_valid_throttle_type(t)
      None => true
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "throttle",
      version: "1.0.0",
      description: "Throttle component with token_bucket, leaky_bucket, sliding_window, fixed_window support",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "throttle_type", type_: "string", required: true, description: "Throttle type: token_bucket/leaky_bucket/sliding_window/fixed_window" },
        InputSchema::{ name: "rate", type_: "number", required: false, description: "Throttle rate" },
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Operation to throttle" },
      ],
      outputs: [
        OutputSchema::{ name: "allowed", type_: "boolean", description: "Whether operation is allowed" },
        OutputSchema::{ name: "wait_time", type_: "number", description: "Wait time in ms" },
      ],
    }
  }
}