package moonflow_core::components

pub struct MergerComponent

pub enum MergerType {
  | Concat
  | Union
  | Join
  | Zip
}

pub fn create_merger_component() -> MergerComponent {
  MergerComponent
}