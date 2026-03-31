package moonflow_core::components

pub struct MulticastComponent

pub enum MulticastStrategy {
  | Broadcast
  | RoundRobin
  | Random
}

pub struct MulticastConfig {
  strategy: MulticastStrategy
  target_count: Int
  timeout_ms: Int
}

pub fn create_multicast_component() -> MulticastComponent {
  MulticastComponent
}

pub fn create_multicast_config(strategy: MulticastStrategy, target_count: Int) -> MulticastConfig {
  MulticastConfig::{
    strategy,
    target_count,
    timeout_ms: 5000,
  }
}

pub fn create_multicast_config_with_timeout(
  strategy: MulticastStrategy,
  target_count: Int,
  timeout_ms: Int
) -> MulticastConfig {
  MulticastConfig::{
    strategy,
    target_count,
    timeout_ms,
  }
}

impl Component for MulticastComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let strategy = input.params.get_or("strategy", "broadcast")
    let target_count = input.params.get_or("target_count", "3").to_int()
    let operation = input.data

    if operation == "" {
      return Err(ComponentError::ValidationError("Operation is required"))
    }

    execute_multicast_operation(strategy, target_count, operation)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["strategy"] {
      Some(s) => is_valid_multicast_strategy(s)
      None => true
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "multicast",
      version: "1.0.0",
      description: "Multicast component with broadcast, round_robin, random strategies",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "strategy", type_: "string", required: true, description: "Multicast strategy: broadcast/round_robin/random" },
        InputSchema::{ name: "target_count", type_: "number", required: false, description: "Number of target recipients" },
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Operation to multicast" },
      ],
      outputs: [
        OutputSchema::{ name: "sent_count", type_: "number", description: "Number of recipients" },
        OutputSchema::{ name: "strategy", type_: "string", description: "Strategy used" },
      ],
    }
  }
}

fn execute_multicast_operation(strategy: String, target_count: Int, operation: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["strategy"] = strategy
  metadata["target_count"] = target_count.to_string()
  metadata["status"] = "multicast"

  let sent_count = calculate_sent_count(strategy, target_count)
  metadata["sent_count"] = sent_count.to_string()

  let response = "Multicast '\{operation}' to \{sent_count} recipients using '\{strategy}'"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn calculate_sent_count(strategy: String, target_count: Int) -> Int {
  match strategy {
    "broadcast" => target_count
    "round_robin" => target_count
    "random" => target_count
    _ => target_count
  }
}

fn is_valid_multicast_strategy(strategy: String) -> Bool {
  strategy == "broadcast" || strategy == "round_robin" || strategy == "random"
}
