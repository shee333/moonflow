package moonflow_core::components

pub struct RouterComponent

pub enum RouterType {
  | RoundRobin
  | Random
  | Weighted
  | Hash
}

pub fn create_router_component() -> RouterComponent {
  RouterComponent
}