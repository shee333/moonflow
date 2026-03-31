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