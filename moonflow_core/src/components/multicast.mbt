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
