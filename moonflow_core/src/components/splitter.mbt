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