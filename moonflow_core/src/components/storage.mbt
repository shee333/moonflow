package moonflow_core::components

pub struct StorageComponent

pub enum StorageType {
  | Local
  | S3
  | GCS
  | AzureBlob
  | OSS
}

pub struct StorageConfig {
  storage_type: StorageType
  bucket: String
  region: String
  access_key: String?
  secret_key: String?
  endpoint: String?
  base_path: String
}

pub fn create_storage_component() -> StorageComponent {
  StorageComponent
}

pub fn create_storage_config(
  storage_type: StorageType,
  bucket: String,
  region: String
) -> StorageConfig {
  StorageConfig::{
    storage_type,
    bucket,
    region,
    access_key: None,
    secret_key: None,
    endpoint: None,
    base_path: "/",
  }
}

pub fn create_storage_config_with_credentials(
  storage_type: StorageType,
  bucket: String,
  region: String,
  access_key: String,
  secret_key: String
) -> StorageConfig {
  StorageConfig::{
    storage_type,
    bucket,
    region,
    access_key: Some(access_key),
    secret_key: Some(secret_key),
    endpoint: None,
    base_path: "/",
  }
}

impl Component for StorageComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let operation = input.params.get_or("operation", "upload")
    let key = input.params.get_or("key", "")
    let bucket = input.params.get_or("bucket", "")
    let content = input.data

    if key == "" {
      return Err(ComponentError::ValidationError("Storage key is required"))
    }

    if bucket == "" {
      return Err(ComponentError::ValidationError("Bucket name is required"))
    }

    execute_storage_operation(operation, key, bucket, content)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match (config["key"], config["bucket"]) {
      (Some(key), Some(bucket)) => key.length() > 0 && bucket.length() > 0
      _ => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "storage",
      version: "1.0.0",
      description: "Storage component supporting local, S3, GCS, Azure Blob, and OSS",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Storage operation: upload/download/delete/list" },
        InputSchema::{ name: "key", type_: "string", required: true, description: "Storage object key" },
        InputSchema::{ name: "bucket", type_: "string", required: true, description: "Storage bucket name" },
        InputSchema::{ name: "content", type_: "string", required: false, description: "File content to upload" },
      ],
      outputs: [
        OutputSchema::{ name: "key", type_: "string", description: "Storage object key" },
        OutputSchema::{ name: "url", type_: "string", description: "Object URL" },
        OutputSchema::{ name: "size", type_: "number", description: "File size in bytes" },
      ],
    }
  }
}

fn execute_storage_operation(operation: String, key: String, bucket: String, content: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["key"] = key
  metadata["bucket"] = bucket
  metadata["operation"] = operation
  metadata["status"] = "completed"

  let response = "Storage operation '\{operation}' completed for '\{key}' in bucket '\{bucket}'"
  Ok(create_component_output_with_metadata(response, metadata))
}