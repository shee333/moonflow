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