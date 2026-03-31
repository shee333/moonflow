package moonflow_core::components

pub struct PoolComponent

pub enum PoolStrategy {
  | Lifo
  | Fifo
  | Random
}

pub struct PoolConfig {
  strategy: PoolStrategy
  min_size: Int
  max_size: Int
}

pub fn create_pool_component() -> PoolComponent {
  PoolComponent
}

pub fn create_pool_config(strategy: PoolStrategy, max_size: Int) -> PoolConfig {
  PoolConfig::{
    strategy,
    min_size: max_size / 4,
    max_size,
  }
}

pub fn create_pool_config_with_min_max(
  strategy: PoolStrategy,
  min_size: Int,
  max_size: Int
) -> PoolConfig {
  PoolConfig::{
    strategy,
    min_size,
    max_size,
  }
}

impl Component for PoolComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let strategy = input.params.get_or("strategy", "fifo")
    let max_size = input.params.get_or("max_size", "10").to_int()
    let operation = input.data

    if operation == "" {
      return Err(ComponentError::ValidationError("Operation is required"))
    }

    execute_pool_operation(strategy, max_size, operation)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["strategy"] {
      Some(s) => is_valid_pool_strategy(s)
      None => true
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "pool",
      version: "1.0.0",
      description: "Pool component with lifo, fifo, random strategies",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "strategy", type_: "string", required: true, description: "Pool strategy: lifo/fifo/random" },
        InputSchema::{ name: "max_size", type_: "number", required: false, description: "Maximum pool size" },
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Operation to pool" },
      ],
      outputs: [
        OutputSchema::{ name: "pooled", type_: "boolean", description: "Whether operation was pooled" },
        OutputSchema::{ name: "pool_size", type_: "number", description: "Current pool size" },
      ],
    }
  }
}
