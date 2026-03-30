package moonflow_core::components

pub struct ComponentRegistry

let global_registry: Map[String, ComponentMetadata] = {}

pub fn init_registry() {
  register_component("http", create_http_component().get_metadata())
  register_component("email", create_email_component().get_metadata())
  register_component("feishu", create_feishu_component().get_metadata())
  register_component("llm", create_llm_component().get_metadata())
}

pub fn register_component(name: String, metadata: ComponentMetadata) {
  global_registry[name] = metadata
}

pub fn get_component_metadata(name: String) -> ComponentMetadata? {
  global_registry[name]
}

pub fn list_components() -> Array[String] {
  let names: Array[String] = []
  for (name, _) in global_registry {
    names.push(name)
  }
  names
}

pub fn list_components_by_category(category: ComponentCategory) -> Array[ComponentMetadata] {
  let results: Array[ComponentMetadata] = []
  for (_, metadata) in global_registry {
    if metadata.category == category {
      results.push(metadata)
    }
  }
  results
}

pub struct ComponentManifest {
  name: String
  version: String
  description: String
  author: String
  license: String
  repository: String
  dependencies: Array[String]
  metadata: ComponentMetadata
}

pub fn create_component_manifest(
  name: String,
  version: String,
  description: String,
  author: String,
  license: String,
  repository: String,
  metadata: ComponentMetadata
) -> ComponentManifest {
  ComponentManifest::{
    name,
    version,
    description,
    author,
    license,
    repository,
    dependencies: [],
    metadata,
  }
}

pub fn add_dependency(manifest: ComponentManifest, dependency: String) -> ComponentManifest {
  let mut new_manifest = manifest
  new_manifest.dependencies.push(dependency)
  new_manifest
}

pub type ComponentStatus =
  | Available
  | Beta
  | Deprecated

pub struct ComponentInfo {
  manifest: ComponentManifest
  status: ComponentStatus
  downloads: Int
  rating: Double
  tags: Array[String]
}

pub fn create_component_info(manifest: ComponentManifest) -> ComponentInfo {
  ComponentInfo::{
    manifest,
    status: ComponentStatus::Available,
    downloads: 0,
    rating: 0.0,
    tags: [],
  }
}

pub fn set_component_status(info: ComponentInfo, status: ComponentStatus) -> ComponentInfo {
  ComponentInfo::{ status, ..info }
}

pub fn add_tag(info: ComponentInfo, tag: String) -> ComponentInfo {
  let mut new_info = info
  new_info.tags.push(tag)
  new_info
}

pub struct ComponentSearchResult {
  components: Array[ComponentInfo]
  total: Int
  page: Int
  page_size: Int
}

pub fn search_components(query: String) -> ComponentSearchResult {
  let results: Array[ComponentInfo] = []
  for (_, metadata) in global_registry {
    if metadata.name.contains(query) || metadata.description.contains(query) {
      let manifest = create_component_manifest(
        metadata.name,
        metadata.version,
        metadata.description,
        "MoonFlow Team",
        "MIT",
        "",
        metadata
      )
      results.push(create_component_info(manifest))
    }
  }

  ComponentSearchResult::{
    components: results,
    total: results.length(),
    page: 1,
    page_size: 20,
  }
}
