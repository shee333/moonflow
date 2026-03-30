package moonflow_core::components

pub struct NotificationComponent

pub enum NotificationChannel {
  | Email
  | SMS
  | Push
  | Webhook
  | Slack
}

pub struct NotificationConfig {
  channel: NotificationChannel
  recipients: Array[String]
  subject: String?
  sender: String
  priority: String
}

pub fn create_notification_component() -> NotificationComponent {
  NotificationComponent
}

pub fn create_notification_config(
  channel: NotificationChannel,
  recipients: Array[String],
  sender: String
) -> NotificationConfig {
  NotificationConfig::{
    channel,
    recipients,
    subject: None,
    sender,
    priority: "normal",
  }
}

pub fn create_notification_config_with_priority(
  channel: NotificationChannel,
  recipients: Array[String],
  sender: String,
  priority: String
) -> NotificationConfig {
  NotificationConfig::{
    channel,
    recipients,
    subject: None,
    sender,
    priority,
  }
}
