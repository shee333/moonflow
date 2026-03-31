package moonflow_core::components

pub struct MergerComponent

pub enum MergerType {
  | Concat
  | Union
  | Join
  | Zip
}

pub struct MergerConfig {
  merger_type: MergerType
  join_key: String?
  deduplicate: Bool
}

pub fn create_merger_component() -> MergerComponent {
  MergerComponent
}

pub fn create_merger_config(merger_type: MergerType) -> MergerConfig {
  MergerConfig::{
    merger_type,
    join_key: None,
    deduplicate: false,
  }
}

fn execute_merge_operation(merger_type: String, data1: String, data2: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["merger_type"] = merger_type
  metadata["status"] = "merged"

  let result = merge_data(merger_type, data1, data2)
  metadata["count"] = result.length().to_string()

  let response = "Merged '\{data1}' and '\{data2}' using '\{merger_type}' strategy"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn merge_data(merger_type: String, data1: String, data2: String) -> String {
  match merger_type {
    "concat" => data1 + data2
    "union" => data1 + "," + data2
    "join" => data1 + " JOIN " + data2
    "zip" => zip_strings(data1, data2)
    _ => data1
  }
}

fn zip_strings(s1: String, s2: String) -> String {
  let len1 = s1.length()
  let len2 = s2.length()
  let min_len = if len1 < len2 { len1 } else { len2 }
  let mut result = ""
  let mut i = 0
  while i < min_len {
    let c1 = s1[i]
    let c2 = s2[i]
    result = result + c1 + c2
    i = i + 1
  }
  if len1 > min_len {
    result = result + s1.substring(min_len, len1 - min_len)
  } else if len2 > min_len {
    result = result + s2.substring(min_len, len2 - min_len)
  }
  result
}

fn is_valid_merger_type(merger_type: String) -> Bool {
  merger_type == "concat" || merger_type == "union" ||
  merger_type == "join" || merger_type == "zip"
}

pub fn create_merger_config_with_join(
  merger_type: MergerType,
  join_key: String,
  deduplicate: Bool
) -> MergerConfig {
  MergerConfig::{
    merger_type,
    join_key: Some(join_key),
    deduplicate,
  }
}

impl Component for MergerComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let merger_type = input.params.get_or("merger_type", "concat")
    let data1 = input.data
    let data2 = input.params.get_or("data2", "")

    if data1 == "" || data2 == "" {
      return Err(ComponentError::ValidationError("Both data sources are required"))
    }

    execute_merge_operation(merger_type, data1, data2)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["merger_type"] {
      Some(mtype) => is_valid_merger_type(mtype)
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "merger",
      version: "1.0.0",
      description: "Data merging component with concat, union, join, and zip support",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "merger_type", type_: "string", required: true, description: "Merge type: concat/union/join/zip" },
        InputSchema::{ name: "data", type_: "string", required: true, description: "First data source" },
        InputSchema::{ name: "data2", type_: "string", required: true, description: "Second data source" },
      ],
      outputs: [
        OutputSchema::{ name: "merged", type_: "string", description: "Merged result" },
        OutputSchema::{ name: "count", type_: "number", description: "Total items merged" },
      ],
    }
  }
}