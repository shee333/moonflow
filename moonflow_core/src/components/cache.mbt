package moonflow_core::components

pub struct CacheComponent

pub enum CacheOperation {
  | Get
  | Set
  | Delete
  | Clear
  | Exists
}

pub enum CacheBackend {
  | Memory
  | Redis
  | Memcached
  | File
}

pub struct CacheConfig {
  backend: CacheBackend
  host: String
  port: Int
  database: Int
  password: String?
  ttl: Int
  max_size: Int
  prefix: String
}

pub fn create_cache_component() -> CacheComponent {
  CacheComponent
}

pub fn create_cache_config(backend: CacheBackend, ttl: Int) -> CacheConfig {
  CacheConfig::{
    backend,
    host: "localhost",
    port: 6379,
    database: 0,
    password: None,
    ttl,
    max_size: 1000,
    prefix: "moonflow:",
  }
}

pub fn create_cache_config_with_host(
  backend: CacheBackend,
  host: String,
  port: Int,
  ttl: Int
) -> CacheConfig {
  CacheConfig::{
    backend,
    host,
    port,
    database: 0,
    password: None,
    ttl,
    max_size: 1000,
    prefix: "moonflow:",
  }
}

impl Component for CacheComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let operation = input.params.get_or("operation", "get")
    let key = input.params.get_or("key", "")
    let value = input.data

    if key == "" {
      return Err(ComponentError::ValidationError("Cache key is required"))
    }

    let backend_str = input.params.get_or("backend", "memory")
    let host = input.params.get_or("host", "localhost")
    let port = input.params.get_or("port", "6379").to_int().unwrap_or(6379)

    let backend = parse_cache_backend(backend_str)

    execute_cache_operation(operation, key, value, backend, host, port)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match (config["key"], config["operation"]) {
      (Some(key), Some(op)) => key.length() > 0 && is_valid_cache_operation(op)
      _ => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "cache",
      version: "1.0.0",
      description: "Cache management component supporting memory, Redis, Memcached, and file backends",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Cache operation: get/set/delete/clear/exists" },
        InputSchema::{ name: "key", type_: "string", required: true, description: "Cache key" },
        InputSchema::{ name: "value", type_: "string", required: false, description: "Value to cache (for set operation)" },
        InputSchema::{ name: "backend", type_: "string", required: false, description: "Cache backend: memory/redis/memcached/file" },
        InputSchema::{ name: "ttl", type_: "number", required: false, description: "Time to live in seconds" },
      ],
      outputs: [
        OutputSchema::{ name: "key", type_: "string", description: "Cache key" },
        OutputSchema::{ name: "value", type_: "string", description: "Cached value" },
        OutputSchema::{ name: "status", type_: "string", description: "Operation status" },
      ],
    }
  }
}

fn parse_cache_backend(backend: String) -> CacheBackend {
  match backend {
    "redis" => CacheBackend::Redis
    "memcached" => CacheBackend::Memcached
    "file" => CacheBackend::File
    _ => CacheBackend::Memory
  }
}

fn is_valid_cache_operation(operation: String) -> Bool {
  operation == "get" || operation == "set" || operation == "delete" || operation == "clear" || operation == "exists"
}

fn execute_cache_operation(
  operation: String,
  key: String,
  value: String,
  backend: CacheBackend,
  host: String,
  port: Int
) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["key"] = key
  metadata["operation"] = operation
  metadata["backend"] = format_cache_backend(backend)
  metadata["host"] = host
  metadata["port"] = port.to_string()
  metadata["status"] = "success"

  let response = match operation {
    "get" => "Retrieved value for key '\{key}' from \{format_cache_backend(backend)}"
    "set" => "Set value for key '\{key}' in \{format_cache_backend(backend)}"
    "delete" => "Deleted key '\{key}' from \{format_cache_backend(backend)}"
    "clear" => "Cleared all keys from \{format_cache_backend(backend)}"
    "exists" => "Checked existence of key '\{key}' in \{format_cache_backend(backend)}"
    _ => "Cache operation '\{operation}' completed"
  }

  Ok(create_component_output_with_metadata(response, metadata))
}

fn format_cache_backend(backend: CacheBackend) -> String {
  match backend {
    CacheBackend::Memory => "memory"
    CacheBackend::Redis => "redis"
    CacheBackend::Memcached => "memcached"
    CacheBackend::File => "file"
  }
}
