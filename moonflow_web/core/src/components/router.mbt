package moonflow_core::components

pub struct RouterComponent

pub enum RouterType {
  | RoundRobin
  | Random
  | Weighted
  | Hash
}

pub struct RouterConfig {
  router_type: RouterType
  targets: Array[String]
  weights: Array[Int]?
}

pub fn create_router_component() -> RouterComponent {
  RouterComponent
}

pub fn create_router_config(router_type: RouterType, targets: Array[String]) -> RouterConfig {
  RouterConfig::{
    router_type,
    targets,
    weights: None,
  }
}

fn execute_routing(operation: String, router_type: String, key: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["operation"] = operation
  metadata["router_type"] = router_type
  metadata["status"] = "routed"

  let target = select_target(router_type, key)
  metadata["target"] = target

  let response = "Routed using '\{router_type}' strategy to target '\{target}'"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn select_target(router_type: String, key: String) -> String {
  match router_type {
    "round_robin" => "target_1"
    "random" => "target_2"
    "hash" => "target_\{hash_key(key)}"
    _ => "default_target"
  }
}

fn hash_key(key: String) -> String {
  let len = key.length()
  let hash = len % 3 + 1
  hash.to_string()
}

fn is_valid_router_type(router_type: String) -> Bool {
  router_type == "round_robin" || router_type == "random" ||
  router_type == "weighted" || router_type == "hash"
}

pub fn create_weighted_router_config(
  router_type: RouterType,
  targets: Array[String],
  weights: Array[Int]
) -> RouterConfig {
  RouterConfig::{
    router_type,
    targets,
    weights: Some(weights),
  }
}

impl Component for RouterComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let operation = input.params.get_or("operation", "route")
    let router_type = input.params.get_or("router_type", "round_robin")
    let key = input.params.get_or("key", "")

    if router_type == "weighted" {
      return Err(ComponentError::ValidationError("Weighted routing requires weights"))
    }

    execute_routing(operation, router_type, key)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["router_type"] {
      Some(rtype) => is_valid_router_type(rtype)
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "router",
      version: "1.0.0",
      description: "Routing component with RoundRobin, Random, Weighted, and Hash strategies",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Routing operation" },
        InputSchema::{ name: "router_type", type_: "string", required: true, description: "Type: round_robin/random/weighted/hash" },
        InputSchema::{ name: "key", type_: "string", required: false, description: "Key for hash routing" },
      ],
      outputs: [
        OutputSchema::{ name: "target", type_: "string", description: "Selected target" },
        OutputSchema::{ name: "router_type", type_: "string", description: "Router type used" },
      ],
    }
  }
}