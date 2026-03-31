package moonflow_core::components

pub struct DebounceComponent

pub enum DebounceStrategy {
  | Leading
  | Trailing
  | Both
}

pub struct DebounceConfig {
  strategy: DebounceStrategy
  delay_ms: Int
  max_wait_ms: Int
}

pub fn create_debounce_component() -> DebounceComponent {
  DebounceComponent
}

pub fn create_debounce_config(strategy: DebounceStrategy, delay_ms: Int) -> DebounceConfig {
  DebounceConfig::{
    strategy,
    delay_ms,
    max_wait_ms: delay_ms * 10,
  }
}

pub fn create_debounce_config_with_max_wait(
  strategy: DebounceStrategy,
  delay_ms: Int,
  max_wait_ms: Int
) -> DebounceConfig {
  DebounceConfig::{
    strategy,
    delay_ms,
    max_wait_ms,
  }
}

impl Component for DebounceComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let strategy = input.params.get_or("strategy", "trailing")
    let delay_ms = input.params.get_or("delay_ms", "300").to_int()
    let operation = input.data

    if operation == "" {
      return Err(ComponentError::ValidationError("Operation is required"))
    }

    execute_debounce_operation(strategy, delay_ms, operation)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["strategy"] {
      Some(s) => is_valid_debounce_strategy(s)
      None => true
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "debounce",
      version: "1.0.0",
      description: "Debounce component with leading, trailing, both strategies",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "strategy", type_: "string", required: true, description: "Debounce strategy: leading/trailing/both" },
        InputSchema::{ name: "delay_ms", type_: "number", required: false, description: "Debounce delay in milliseconds" },
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Operation to debounce" },
      ],
      outputs: [
        OutputSchema::{ name: "executed", type_: "boolean", description: "Whether operation was executed" },
        OutputSchema::{ name: "delay", type_: "number", description: "Applied delay in ms" },
      ],
    }
  }
}
