package moonflow_core::components

pub struct SplitterComponent

pub enum SplitterType {
  | ByDelimiter
  | ByLength
  | ByPattern
  | ByJsonPath
}

pub struct SplitterConfig {
  splitter_type: SplitterType
  delimiter: String
  chunk_size: Int
  max_chunks: Int
}

pub fn create_splitter_component() -> SplitterComponent {
  SplitterComponent
}

pub fn create_splitter_config(splitter_type: SplitterType, delimiter: String) -> SplitterConfig {
  SplitterConfig::{
    splitter_type,
    delimiter,
    chunk_size: 1024,
    max_chunks: 100,
  }
}

fn execute_split_operation(splitter_type: String, delimiter: String, data: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["splitter_type"] = splitter_type
  metadata["delimiter"] = delimiter
  metadata["status"] = "split"

  let chunks = count_chunks(splitter_type, delimiter, data)
  metadata["count"] = chunks.to_string()

  let response = "Split '\{data}' into \{chunks} chunks using '\{splitter_type}'"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn count_chunks(splitter_type: String, delimiter: String, data: String) -> Int {
  match splitter_type {
    "by_delimiter" => {
      let count = 1
      let len = delimiter.length()
      if len > 0 {
        let mut i = 0
        while i < data.length() {
          let pos = data.find(delimiter, i)
          match pos {
            Some(_) => count + 1
            None => break
          }
          i = i + len
        }
      } else {
        count
      }
    }
    "by_length" => {
      let chunk_size = 1024
      (data.length() + chunk_size - 1) / chunk_size
    }
    _ => 1
  }
}

fn is_valid_splitter_type(splitter_type: String) -> Bool {
  splitter_type == "by_delimiter" || splitter_type == "by_length" ||
  splitter_type == "by_pattern" || splitter_type == "by_json_path"
}

pub fn create_splitter_config_with_chunks(
  splitter_type: SplitterType,
  delimiter: String,
  chunk_size: Int,
  max_chunks: Int
) -> SplitterConfig {
  SplitterConfig::{
    splitter_type,
    delimiter,
    chunk_size,
    max_chunks,
  }
}

impl Component for SplitterComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let splitter_type = input.params.get_or("splitter_type", "by_delimiter")
    let delimiter = input.params.get_or("delimiter", ",")
    let data = input.data

    if data == "" {
      return Err(ComponentError::ValidationError("Input data is required"))
    }

    execute_split_operation(splitter_type, delimiter, data)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["splitter_type"] {
      Some(stype) => is_valid_splitter_type(stype)
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "splitter",
      version: "1.0.0",
      description: "Data splitting component with delimiter, length, pattern, and JSON path support",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "splitter_type", type_: "string", required: true, description: "Split type: by_delimiter/by_length/by_pattern/by_json_path" },
        InputSchema::{ name: "delimiter", type_: "string", required: false, description: "Delimiter for splitting" },
        InputSchema::{ name: "data", type_: "string", required: true, description: "Data to split" },
      ],
      outputs: [
        OutputSchema::{ name: "chunks", type_: "array", description: "Split chunks" },
        OutputSchema::{ name: "count", type_: "number", description: "Number of chunks" },
      ],
    }
  }
}