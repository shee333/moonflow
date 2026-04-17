///|
/// HTTP component for making HTTP requests.

///|
pub(all) struct HttpComponent {
  base_url : String
  timeout_ms : Int
  default_headers : Map[String, String]
}

///|
pub fn HttpComponent::new(base_url : String) -> HttpComponent {
  HttpComponent::{ base_url, timeout_ms: 30000, default_headers: {} }
}

///|
pub fn HttpComponent::execute(
  self : HttpComponent,
  input : ComponentInput,
) -> Result[ComponentOutput, ComponentError] {
  let url = if input.data.length() > 0 { input.data } else { self.base_url }
  Ok(ComponentOutput::{
    data: "{\"url\":\"" + url + "\",\"status\":200}",
    metadata: {},
  })
}

///|
pub fn HttpComponent::info() -> ComponentInfo {
  ComponentInfo::{
    name: "http",
    version: "0.1.0",
    description: "HTTP request component",
    category: CatTool,
  }
}
