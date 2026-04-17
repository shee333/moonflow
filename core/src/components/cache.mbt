///|
/// Cache component - caching for workflow results.

///|
pub(all) struct CacheComponent {
  mut store : Map[String, String]
  ttl : Int
}

///|
pub fn CacheComponent::new(ttl? : Int = 300) -> CacheComponent {
  CacheComponent::{ store: {}, ttl }
}

///|
pub fn CacheComponent::get(self : CacheComponent, key : String) -> String? {
  self.store.get(key)
}

///|
pub fn CacheComponent::set(
  self : CacheComponent,
  key : String,
  value : String,
) -> Unit {
  self.store[key] = value
}

///|
pub fn CacheComponent::info() -> ComponentInfo {
  ComponentInfo::{
    name: "cache",
    version: "1.0.0",
    description: "Result caching component",
    category: CatTool,
  }
}
