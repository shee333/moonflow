package moonflow_core::components

pub struct SplitterComponent

pub enum SplitterType {
  | ByDelimiter
  | ByLength
  | ByPattern
  | ByJsonPath
}

pub fn create_splitter_component() -> SplitterComponent {
  SplitterComponent
}