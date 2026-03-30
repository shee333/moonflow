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