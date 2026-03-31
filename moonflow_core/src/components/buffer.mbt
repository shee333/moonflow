package moonflow_core::components

pub struct BufferComponent

pub enum BufferStrategy {
  | FlushOnSize
  | FlushOnTime
  | FlushOnSizeOrTime
  | Manual
}

pub struct BufferConfig {
  strategy: BufferStrategy
  max_size: Int
  flush_interval_ms: Int
}

pub fn create_buffer_component() -> BufferComponent {
  BufferComponent
}

pub fn create_buffer_config(strategy: BufferStrategy, max_size: Int) -> BufferConfig {
  BufferConfig::{
    strategy,
    max_size,
    flush_interval_ms: 1000,
  }
}

pub fn create_buffer_config_with_interval(
  strategy: BufferStrategy,
  max_size: Int,
  flush_interval_ms: Int
) -> BufferConfig {
  BufferConfig::{
    strategy,
    max_size,
    flush_interval_ms,
  }
}

impl Component for BufferComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let strategy = input.params.get_or("strategy", "flush_on_size")
    let max_size = input.params.get_or("max_size", "100").to_int()
    let operation = input.data

    if operation == "" {
      return Err(ComponentError::ValidationError("Operation is required"))
    }

    execute_buffer_operation(strategy, max_size, operation)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["strategy"] {
      Some(s) => is_valid_buffer_strategy(s)
      None => true
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "buffer",
      version: "1.0.0",
      description: "Buffer component with flush_on_size, flush_on_time, flush_on_size_or_time, manual strategies",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "strategy", type_: "string", required: true, description: "Buffer strategy: flush_on_size/flush_on_time/flush_on_size_or_time/manual" },
        InputSchema::{ name: "max_size", type_: "number", required: false, description: "Maximum buffer size" },
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Operation to buffer" },
      ],
      outputs: [
        OutputSchema::{ name: "buffered", type_: "boolean", description: "Whether operation was buffered" },
        OutputSchema::{ name: "flush_needed", type_: "boolean", description: "Whether flush is needed" },
      ],
    }
  }
}
