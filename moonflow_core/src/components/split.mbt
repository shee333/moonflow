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
