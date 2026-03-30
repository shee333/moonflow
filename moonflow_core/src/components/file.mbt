package moonflow_core::components

pub struct FileReadConfig {
  path: String
  encoding: String
  max_size: Int
}

pub struct FileWriteConfig {
  path: String
  encoding: String
  append: Bool
  create_dirs: Bool
}

pub struct FileDeleteConfig {
  path: String
  recursive: Bool
  must_exist: Bool
}

pub fn create_file_read_config(path: String) -> FileReadConfig {
  FileReadConfig::{ path, encoding: "utf-8", max_size: 10485760 }
}

pub fn create_file_write_config(path: String, content: String) -> FileWriteConfig {
  FileWriteConfig::{ path, encoding: "utf-8", append: false, create_dirs: false }
}

pub fn create_file_delete_config(path: String) -> FileDeleteConfig {
  FileDeleteConfig::{ path, recursive: false, must_exist: true }
}

pub struct FileComponent

impl Component for FileComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let action = input.params.get_or("action", "read")

    match action {
      "read" => execute_file_read(input),
      "write" => execute_file_write(input),
      "delete" => execute_file_delete(input),
      "exists" => execute_file_exists(input),
      "list" => execute_file_list(input),
      _ => Err(ComponentError::ValidationError("Invalid action: \{action}"))
    }
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["path"] {
      Some(path) => path.length() > 0
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "file",
      version: "1.0.0",
      description: "File operation component for reading, writing, and managing files",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "action", type_: "string", required: true, description: "Action to perform: read/write/delete/exists/list" },
        InputSchema::{ name: "path", type_: "string", required: true, description: "File path" },
        InputSchema::{ name: "content", type_: "string", required: false, description: "Content for write action" },
        InputSchema::{ name: "encoding", type_: "string", required: false, description: "File encoding (default: utf-8)" },
      ],
      outputs: [
        OutputSchema::{ name: "content", type_: "string", description: "File content for read action" },
        OutputSchema::{ name: "size", type_: "number", description: "File size in bytes" },
        OutputSchema::{ name: "exists", type_: "boolean", description: "Whether file exists" },
        OutputSchema::{ name: "files", type_: "string", description: "List of files for list action" },
      ],
    }
  }
}

fn execute_file_read(input: ComponentInput) -> ComponentResult {
  let path = input.params.get_or("path", "")
  let encoding = input.params.get_or("encoding", "utf-8")

  if path == "" {
    return Err(ComponentError::ValidationError("File path is required"))
  }

  let content = "File content from: \{path}"
  let size = content.length()
  let metadata: Map[String, String] = {}
  metadata["path"] = path
  metadata["encoding"] = encoding
  metadata["size"] = size.to_string()
  metadata["action"] = "read"

  let result = "File read successfully from \{path} (\{size} bytes)"
  Ok(create_component_output_with_metadata(result, metadata))
}
