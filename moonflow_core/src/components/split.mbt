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
