package moonflow_core::components

pub struct SplitComponent

pub enum SplitType {
  | BySize
  | ByPattern
  | ByDelimiter
}

pub struct SplitConfig {
  split_type: SplitType
  chunk_size: Int
  pattern: String
}

pub fn create_split_component() -> SplitComponent {
  SplitComponent
}

pub fn create_split_config(split_type: SplitType, chunk_size: Int) -> SplitConfig {
  SplitConfig::{
    split_type,
    chunk_size,
    pattern: "",
  }
}

pub fn create_split_config_with_pattern(
  split_type: SplitType,
  chunk_size: Int,
  pattern: String
) -> SplitConfig {
  SplitConfig::{
    split_type,
    chunk_size,
    pattern,
  }
}

impl Component for SplitComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let split_type = input.params.get_or("split_type", "by_size")
    let chunk_size = input.params.get_or("chunk_size", "100").to_int()
    let operation = input.data

    if operation == "" {
      return Err(ComponentError::ValidationError("Operation is required"))
    }

    execute_split_operation(split_type, chunk_size, operation)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["split_type"] {
      Some(s) => is_valid_split_type(s)
      None => true
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "split",
      version: "1.0.0",
      description: "Split component with by_size, by_pattern, by_delimiter strategies",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "split_type", type_: "string", required: true, description: "Split type: by_size/by_pattern/by_delimiter" },
        InputSchema::{ name: "chunk_size", type_: "number", required: false, description: "Size of each chunk" },
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Operation to split" },
      ],
      outputs: [
        OutputSchema::{ name: "chunk_count", type_: "number", description: "Number of chunks" },
        OutputSchema::{ name: "chunk_size", type_: "number", description: "Size of each chunk" },
      ],
    }
  }
}
