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