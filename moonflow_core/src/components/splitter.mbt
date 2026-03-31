package moonflow_core::components

pub struct SplitterComponent

pub enum SplitterType {
  | ByDelimiter
  | ByLength
  | ByPattern
  | ByJsonPath
}

pub struct SplitterConfig {
  splitter_type: SplitterType
  delimiter: String
  chunk_size: Int
  max_chunks: Int
}

pub fn create_splitter_component() -> SplitterComponent {
  SplitterComponent
}

pub fn create_splitter_config(splitter_type: SplitterType, delimiter: String) -> SplitterConfig {
  SplitterConfig::{
    splitter_type,
    delimiter,
    chunk_size: 1024,
    max_chunks: 100,
  }
}

pub fn create_splitter_config_with_chunks(
  splitter_type: SplitterType,
  delimiter: String,
  chunk_size: Int,
  max_chunks: Int
) -> SplitterConfig {
  SplitterConfig::{
    splitter_type,
    delimiter,
    chunk_size,
    max_chunks,
  }
}

impl Component for SplitterComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let splitter_type = input.params.get_or("splitter_type", "by_delimiter")
    let delimiter = input.params.get_or("delimiter", ",")
    let data = input.data

    if data == "" {
      return Err(ComponentError::ValidationError("Input data is required"))
    }

    execute_split_operation(splitter_type, delimiter, data)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["splitter_type"] {
      Some(stype) => is_valid_splitter_type(stype)
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "splitter",
      version: "1.0.0",
      description: "Data splitting component with delimiter, length, pattern, and JSON path support",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "splitter_type", type_: "string", required: true, description: "Split type: by_delimiter/by_length/by_pattern/by_json_path" },
        InputSchema::{ name: "delimiter", type_: "string", required: false, description: "Delimiter for splitting" },
        InputSchema::{ name: "data", type_: "string", required: true, description: "Data to split" },
      ],
      outputs: [
        OutputSchema::{ name: "chunks", type_: "array", description: "Split chunks" },
        OutputSchema::{ name: "count", type_: "number", description: "Number of chunks" },
      ],
    }
  }
}