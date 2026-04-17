///|
/// Transform component - transform data.

///|
pub(all) struct TransformComponent {
  template : String
}

///|
pub fn TransformComponent::new(template? : String = "") -> TransformComponent {
  TransformComponent::{ template, }
}

///|
pub fn TransformComponent::execute(
  _self : TransformComponent,
  input : ComponentInput,
) -> Result[ComponentOutput, ComponentError] {
  Ok(ComponentOutput::{ data: input.data, metadata: {} })
}

///|
pub fn TransformComponent::info() -> ComponentInfo {
  ComponentInfo::{
    name: "transform",
    version: "1.0.0",
    description: "Data transformation component",
    category: CatTool,
  }
}
