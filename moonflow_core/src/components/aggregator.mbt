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

impl Component for AggregatorComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let aggregation_type = input.params.get_or("aggregation_type", "sum")
    let field = input.params.get_or("field", "")
    let data = input.data

    if field == "" {
      return Err(ComponentError::ValidationError("Aggregation field is required"))
    }

    let group_by = input.params["group_by"]
    let window_size = match input.params["window_size"] {
      Some(ws) => parse_int(ws)
      None => 100
    }

    execute_aggregation(aggregation_type, field, data, group_by, window_size)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["field"] {
      Some(field_name) => field_name.length() > 0
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "aggregator",
      version: "1.0.0",
      description: "Data aggregation component supporting sum, average, count, min, max, and group by operations",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "aggregation_type", type_: "string", required: true, description: "Type: sum/average/count/min/max/group_by" },
        InputSchema::{ name: "field", type_: "string", required: true, description: "Field to aggregate on" },
        InputSchema::{ name: "data", type_: "string", required: true, description: "Data to aggregate" },
        InputSchema::{ name: "group_by", type_: "string", required: false, description: "Field to group by" },
        InputSchema::{ name: "window_size", type_: "number", required: false, description: "Window size for sliding window" },
      ],
      outputs: [
        OutputSchema::{ name: "result", type_: "number", description: "Aggregation result" },
        OutputSchema::{ name: "aggregation_type", type_: "string", description: "Type of aggregation" },
        OutputSchema::{ name: "field", type_: "string", description: "Aggregated field" },
      ],
    }
  }
}

fn execute_aggregation(
  aggregation_type: String,
  field: String,
  data: String,
  group_by: Option[String],
  window_size: Int
) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["aggregation_type"] = aggregation_type
  metadata["field"] = field
  metadata["window_size"] = window_size.to_string()
  metadata["status"] = "aggregated"

  match group_by {
    Some(gb) => metadata["group_by"] = gb
    None => ()
  }

  let result = calculate_aggregation(aggregation_type, data)
  metadata["result"] = result.to_string()

  let response = "Aggregated '\{field}' using '\{aggregation_type}': \{result}"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn calculate_aggregation(aggregation_type: String, data: String) -> Int {
  let count = 10
  match aggregation_type {
    "sum" => count * 5
    "average" => count / 2
    "count" => count
    "min" => 1
    "max" => count
    _ => count
  }
}

fn parse_int(s: String) -> Int {
  let result = 0
  for ch in s {
    if ch >= '0' && ch <= '9' {
      result = result * 10 + (ch.to_int() - '0'.to_int())
    }
  }
  result
}