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