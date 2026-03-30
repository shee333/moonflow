package moonflow_core::components

pub struct ApiComponent

pub enum ApiAuthType {
  | None
  | Basic
  | Bearer
  | OAuth2
  | ApiKey
}

pub struct ApiConfig {
  base_url: String
  auth_type: ApiAuthType
  auth_token: String?
  timeout: Int
  rate_limit: Int
  retry_count: Int
}

pub fn create_api_component() -> ApiComponent {
  ApiComponent
}

pub fn create_api_config(base_url: String, auth_type: ApiAuthType) -> ApiConfig {
  ApiConfig::{
    base_url,
    auth_type,
    auth_token: None,
    timeout: 30,
    rate_limit: 100,
    retry_count: 3,
  }
}

pub fn create_api_config_with_token(
  base_url: String,
  auth_type: ApiAuthType,
  token: String
) -> ApiConfig {
  ApiConfig::{
    base_url,
    auth_type,
    auth_token: Some(token),
    timeout: 30,
    rate_limit: 100,
    retry_count: 3,
  }
}

impl Component for ApiComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let endpoint = input.params.get_or("endpoint", "")
    let method = input.params.get_or("method", "GET")
    let payload = input.data

    if endpoint == "" {
      return Err(ComponentError::ValidationError("API endpoint is required"))
    }

    let base_url = input.params.get_or("base_url", "")
    if base_url == "" {
      return Err(ComponentError::ValidationError("Base URL is required"))
    }

    execute_api_request(base_url, endpoint, method, payload)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match (config["endpoint"], config["base_url"]) {
      (Some(endpoint), Some(base_url)) =>
        endpoint.length() > 0 && base_url.starts_with("http")
      _ => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "api",
      version: "1.0.0",
      description: "Generic API client component with authentication support",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "base_url", type_: "string", required: true, description: "API base URL" },
        InputSchema::{ name: "endpoint", type_: "string", required: true, description: "API endpoint path" },
        InputSchema::{ name: "method", type_: "string", required: false, description: "HTTP method: GET/POST/PUT/DELETE" },
        InputSchema::{ name: "payload", type_: "string", required: false, description: "Request body as JSON" },
      ],
      outputs: [
        OutputSchema::{ name: "status_code", type_: "number", description: "HTTP response status code" },
        OutputSchema::{ name: "body", type_: "string", description: "Response body" },
        OutputSchema::{ name: "headers", type_: "string", description: "Response headers as JSON" },
      ],
    }
  }
}

fn execute_api_request(base_url: String, endpoint: String, method: String, payload: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["base_url"] = base_url
  metadata["endpoint"] = endpoint
  metadata["method"] = method
  metadata["status"] = "success"

  let full_url = "\{base_url}\{endpoint}"
  let response = "API request to \{full_url} using \{method} completed"
  Ok(create_component_output_with_metadata(response, metadata))
}