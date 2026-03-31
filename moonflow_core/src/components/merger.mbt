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

impl Component for MergerComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let merger_type = input.params.get_or("merger_type", "concat")
    let data1 = input.data
    let data2 = input.params.get_or("data2", "")

    if data1 == "" || data2 == "" {
      return Err(ComponentError::ValidationError("Both data sources are required"))
    }

    execute_merge_operation(merger_type, data1, data2)
  }