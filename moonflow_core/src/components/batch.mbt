package moonflow_core::components

pub struct BatchComponent

pub enum BatchMode {
  | Sequential
  | Parallel
  | Chunked
}

pub struct BatchConfig {
  batch_mode: BatchMode
  batch_size: Int
  max_concurrent: Int
}

pub fn create_batch_component() -> BatchComponent {
  BatchComponent
}

pub fn create_batch_config(batch_mode: BatchMode, batch_size: Int) -> BatchConfig {
  BatchConfig::{
    batch_mode,
    batch_size,
    max_concurrent: 1,
  }
}

fn execute_batch_operation(batch_mode: String, batch_size: Int, data: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["batch_mode"] = batch_mode
  metadata["batch_size"] = batch_size.to_string()
  metadata["status"] = "batched"

  let count = calculate_batch_count(batch_mode, batch_size, data)
  metadata["count"] = count.to_string()

  let response = "Batched '\{data}' using '\{batch_mode}' mode (size: \{batch_size})"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn calculate_batch_count(batch_mode: String, batch_size: Int, data: String) -> Int {
  let len = data.length()
  match batch_mode {
    "sequential" => (len + batch_size - 1) / batch_size
    "parallel" => len / batch_size + 1
    "chunked" => len / batch_size
    _ => 1
  }
}

fn is_valid_batch_mode(batch_mode: String) -> Bool {
  batch_mode == "sequential" || batch_mode == "parallel" ||
  batch_mode == "chunked"
}

pub fn create_batch_config_with_concurrency(
  batch_mode: BatchMode,
  batch_size: Int,
  max_concurrent: Int
) -> BatchConfig {
  BatchConfig::{
    batch_mode,
    batch_size,
    max_concurrent,
  }
}

impl Component for BatchComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let batch_mode = input.params.get_or("batch_mode", "sequential")
    let batch_size = input.params.get_or("batch_size", "10").to_int()
    let data = input.data

    if data == "" {
      return Err(ComponentError::ValidationError("Input data is required"))
    }

    execute_batch_operation(batch_mode, batch_size, data)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["batch_mode"] {
      Some(bmode) => is_valid_batch_mode(bmode)
      None => true
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "batch",
      version: "1.0.0",
      description: "Batch processing component with sequential, parallel, and chunked modes",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "batch_mode", type_: "string", required: true, description: "Batch mode: sequential/parallel/chunked" },
        InputSchema::{ name: "batch_size", type_: "number", required: false, description: "Batch size" },
        InputSchema::{ name: "data", type_: "string", required: true, description: "Data to batch" },
      ],
      outputs: [
        OutputSchema::{ name: "batches", type_: "array", description: "Batch results" },
        OutputSchema::{ name: "count", type_: "number", description: "Number of batches" },
      ],
    }
  }
}