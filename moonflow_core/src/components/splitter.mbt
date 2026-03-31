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