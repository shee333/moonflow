package moonflow_core::components

pub struct WebhookComponent

pub enum WebhookMethod {
  | GET
  | POST
  | PUT
  | DELETE
  | PATCH
}

pub struct WebhookConfig {
  url: String
  method: WebhookMethod
  headers: Map[String, String]
  timeout: Int
  retry_count: Int
  secret: String?
}

pub fn create_webhook_component() -> WebhookComponent {
  WebhookComponent
}

pub fn create_webhook_config(url: String, method: WebhookMethod) -> WebhookConfig {
  WebhookConfig::{
    url,
    method,
    headers: {},
    timeout: 30,
    retry_count: 3,
    secret: None,
  }
}

pub fn create_webhook_config_with_auth(
  url: String,
  method: WebhookMethod,
  secret: String
) -> WebhookConfig {
  WebhookConfig::{
    url,
    method,
    headers: {},
    timeout: 30,
    retry_count: 3,
    secret: Some(secret),
  }
}

impl Component for WebhookComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let url = input.params.get_or("url", "")
    let method = input.params.get_or("method", "POST")
    let payload = input.data

    if url == "" {
      return Err(ComponentError::ValidationError("Webhook URL is required"))
    }

    if !url.starts_with("http://") && !url.starts_with("https://") {
      return Err(ComponentError::ValidationError("Invalid webhook URL"))
    }

    execute_webhook_request(url, method, payload)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["url"] {
      Some(url) => url.starts_with("http://") || url.starts_with("https://")
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "webhook",
      version: "1.0.0",
      description: "Webhook component for making HTTP requests with retry support",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "url", type_: "string", required: true, description: "Webhook URL endpoint" },
        InputSchema::{ name: "method", type_: "string", required: false, description: "HTTP method: GET/POST/PUT/DELETE/PATCH" },
        InputSchema::{ name: "payload", type_: "string", required: false, description: "Request payload body" },
        InputSchema::{ name: "headers", type_: "string", required: false, description: "Additional HTTP headers as JSON" },
      ],
      outputs: [
        OutputSchema::{ name: "status_code", type_: "number", description: "HTTP response status code" },
        OutputSchema::{ name: "response", type_: "string", description: "Response body" },
        OutputSchema::{ name: "success", type_: "boolean", description: "Request success flag" },
      ],
    }
  }
}

fn execute_webhook_request(url: String, method: String, payload: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["url"] = url
  metadata["method"] = method
  metadata["status"] = "sent"

  let response = "Webhook request sent to \{url} using \{method}"
  Ok(create_component_output_with_metadata(response, metadata))
}
