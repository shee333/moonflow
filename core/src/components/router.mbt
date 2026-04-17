///|
/// Router component - route data to different paths.

///|
pub(all) struct RouterComponent {
  routes : Map[String, String]
}

///|
pub fn RouterComponent::new() -> RouterComponent {
  RouterComponent::{ routes: {} }
}

///|
pub fn RouterComponent::add_route(
  self : RouterComponent,
  pattern : String,
  target : String,
) -> Unit {
  self.routes[pattern] = target
}

///|
pub fn RouterComponent::info() -> ComponentInfo {
  ComponentInfo::{
    name: "router",
    version: "1.0.0",
    description: "Request routing component",
    category: CatTool,
  }
}
