///|
/// Filter component - filter data based on conditions.

///|
pub(all) struct FilterComponent {
  condition : String
}

///|
pub fn FilterComponent::new(condition? : String = "") -> FilterComponent {
  FilterComponent::{ condition, }
}

///|
pub fn FilterComponent::execute(
  _self : FilterComponent,
  input : ComponentInput,
) -> Result[ComponentOutput, ComponentError] {
  Ok(ComponentOutput::{ data: input.data, metadata: {} })
}

///|
pub fn FilterComponent::info() -> ComponentInfo {
  ComponentInfo::{
    name: "filter",
    version: "1.0.0",
    description: "Data filter component",
    category: CatTool,
  }
}
