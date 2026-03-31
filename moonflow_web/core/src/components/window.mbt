package moonflow_core::components

pub struct WindowComponent

pub enum WindowType {
  | Tumbling
  | Sliding
  | Session
}

pub struct WindowConfig {
  window_type: WindowType
  size_ms: Int
  slide_ms: Int
}

pub fn create_window_component() -> WindowComponent {
  WindowComponent
}

pub fn create_window_config(window_type: WindowType, size_ms: Int) -> WindowConfig {
  WindowConfig::{
    window_type,
    size_ms,
    slide_ms: size_ms / 2,
  }
}

pub fn create_window_config_with_slide(
  window_type: WindowType,
  size_ms: Int,
  slide_ms: Int
) -> WindowConfig {
  WindowConfig::{
    window_type,
    size_ms,
    slide_ms,
  }
}

impl Component for WindowComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let window_type = input.params.get_or("window_type", "tumbling")
    let size_ms = input.params.get_or("size_ms", "60000").to_int()
    let operation = input.data

    if operation == "" {
      return Err(ComponentError::ValidationError("Operation is required"))
    }

    execute_window_operation(window_type, size_ms, operation)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["window_type"] {
      Some(w) => is_valid_window_type(w)
      None => true
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "window",
      version: "1.0.0",
      description: "Window component with tumbling, sliding, session window types",
      category: ComponentCategory::Flow,
      inputs: [
        InputSchema::{ name: "window_type", type_: "string", required: true, description: "Window type: tumbling/sliding/session" },
        InputSchema::{ name: "size_ms", type_: "number", required: false, description: "Window size in milliseconds" },
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Operation to window" },
      ],
      outputs: [
        OutputSchema::{ name: "window_id", type_: "string", description: "Window identifier" },
        OutputSchema::{ name: "window_size", type_: "number", description: "Window size in ms" },
      ],
    }
  }
}

fn execute_window_operation(window_type: String, size_ms: Int, operation: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["window_type"] = window_type
  metadata["size_ms"] = size_ms.to_string()
  metadata["status"] = "windowed"

  let window_id = generate_window_id(window_type, size_ms)
  metadata["window_id"] = window_id
  metadata["window_size"] = size_ms.to_string()

  let response = "Windowed '\{operation}' using '\{window_type}' window (\{size_ms}ms)"
  Ok(create_component_output_with_metadata(response, metadata))
}

fn generate_window_id(window_type: String, size_ms: Int) -> String {
  "\{window_type}_\{size_ms}"
}

fn calculate_window_count(window_type: String, size_ms: Int, total_time_ms: Int) -> Int {
  match window_type {
    "tumbling" => total_time_ms / size_ms
    "sliding" => (total_time_ms / (size_ms / 2)) - 1
    "session" => 1
    _ => 1
  }
}

fn is_valid_window_type(window_type: String) -> Bool {
  window_type == "tumbling" || window_type == "sliding" || window_type == "session"
}
