package moonflow_core::components

pub struct QueueComponent

pub enum QueueType {
  | RabbitMQ
  | Kafka
  | RedisQueue
  | SQS
}

pub struct QueueConfig {
  queue_type: QueueType
  host: String
  port: Int
  queue_name: String
  username: String?
  password: String?
  vhost: String?
}

pub fn create_queue_component() -> QueueComponent {
  QueueComponent
}

pub fn create_queue_config(
  queue_type: QueueType,
  host: String,
  port: Int,
  queue_name: String
) -> QueueConfig {
  QueueConfig::{
    queue_type,
    host,
    port,
    queue_name,
    username: None,
    password: None,
    vhost: None,
  }
}

pub fn create_queue_config_with_auth(
  queue_type: QueueType,
  host: String,
  port: Int,
  queue_name: String,
  username: String,
  password: String
) -> QueueConfig {
  QueueConfig::{
    queue_type,
    host,
    port,
    queue_name,
    username: Some(username),
    password: Some(password),
    vhost: None,
  }
}

impl Component for QueueComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let operation = input.params.get_or("operation", "publish")
    let queue_name = input.params.get_or("queue", "")
    let message = input.data

    if queue_name == "" {
      return Err(ComponentError::ValidationError("Queue name is required"))
    }

    if message == "" {
      return Err(ComponentError::ValidationError("Message content is required"))
    }

    let host = input.params.get_or("host", "localhost")
    let port = input.params.get_or("port", "5672").to_int().unwrap_or(5672)

    execute_queue_operation(operation, queue_name, message, host, port)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match (config["queue"], config["message"]) {
      (Some(queue), Some(msg)) => queue.length() > 0 && msg.length() > 0
      _ => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "queue",
      version: "1.0.0",
      description: "Queue component supporting RabbitMQ, Kafka, Redis Queue, and SQS",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Queue operation: publish/consume/ack/nack" },
        InputSchema::{ name: "queue", type_: "string", required: true, description: "Queue name" },
        InputSchema::{ name: "message", type_: "string", required: true, description: "Message content" },
        InputSchema::{ name: "host", type_: "string", required: false, description: "Queue server host" },
        InputSchema::{ name: "port", type_: "number", required: false, description: "Queue server port" },
      ],
      outputs: [
        OutputSchema::{ name: "queue", type_: "string", description: "Queue name" },
        OutputSchema::{ name: "message_id", type_: "string", description: "Message ID" },
        OutputSchema::{ name: "status", type_: "string", description: "Operation status" },
      ],
    }
  }
}

fn execute_queue_operation(
  operation: String,
  queue_name: String,
  message: String,
  host: String,
  port: Int
) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["queue"] = queue_name
  metadata["operation"] = operation
  metadata["host"] = host
  metadata["port"] = port.to_string()
  metadata["status"] = "success"

  let response = "Queue operation '\{operation}' on '\{queue_name}' at \{host}:\{port}"
  Ok(create_component_output_with_metadata(response, metadata))
}