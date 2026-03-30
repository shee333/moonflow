package moonflow_core::components

pub struct AggregatorComponent

pub enum AggregationType {
  | Sum
  | Average
  | Count
  | Min
  | Max
  | GroupBy
}

pub struct AggregatorConfig {
  aggregation_type: AggregationType
  field: String
  group_by: String?
  window_size: Int
}

pub fn create_aggregator_component() -> AggregatorComponent {
  AggregatorComponent
}

pub fn create_aggregator_config(aggregation_type: AggregationType, field: String) -> AggregatorConfig {
  AggregatorConfig::{
    aggregation_type,
    field,
    group_by: None,
    window_size: 100,
  }
}

pub fn create_aggregator_config_with_grouping(
  aggregation_type: AggregationType,
  field: String,
  group_by: String
) -> AggregatorConfig {
  AggregatorConfig::{
    aggregation_type,
    field,
    group_by: Some(group_by),
    window_size: 100,
  }
}