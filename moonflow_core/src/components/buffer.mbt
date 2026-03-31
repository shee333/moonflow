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

fn execute_buffer_operation(strategy: String, max_size: Int, operation: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["strategy"] = strategy
  metadata["max_size"] = max_size.to_string()
  metadata["status"] = "buffered"

  let flush_needed = should_flush_buffer(strategy, max_size, 1)
  metadata["buffered"] = "true"
  metadata["flush_needed"] = flush_needed.to_string()

  let response = "Buffered '\{operation}' using '\{strategy}' (\{max_size} max size)"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn should_flush_buffer(strategy: String, max_size: Int, current_size: Int) -> Bool {
  match strategy {
    "flush_on_size" => current_size >= max_size
    "flush_on_time" => false
    "flush_on_size_or_time" => current_size >= max_size
    "manual" => false
    _ => false
  }
}

fn is_valid_buffer_strategy(strategy: String) -> Bool {
  strategy == "flush_on_size" || strategy == "flush_on_time" ||
  strategy == "flush_on_size_or_time" || strategy == "manual"
}
