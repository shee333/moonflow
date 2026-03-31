package moonflow_core::components

pub struct MergerComponent

pub enum MergerType {
  | Concat
  | Union
  | Join
  | Zip
}

pub struct MergerConfig {
  merger_type: MergerType
  join_key: String?
  deduplicate: Bool
}

pub fn create_merger_component() -> MergerComponent {
  MergerComponent
}

pub fn create_merger_config(merger_type: MergerType) -> MergerConfig {
  MergerConfig::{
    merger_type,
    join_key: None,
    deduplicate: false,
  }
}

pub fn create_merger_config_with_join(
  merger_type: MergerType,
  join_key: String,
  deduplicate: Bool
) -> MergerConfig {
  MergerConfig::{
    merger_type,
    join_key: Some(join_key),
    deduplicate,
  }
}