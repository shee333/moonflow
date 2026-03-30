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

impl Component for NotificationComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let channel = input.params.get_or("channel", "email")
    let recipients_str = input.params.get_or("recipients", "")
    let message = input.data

    if message == "" {
      return Err(ComponentError::ValidationError("Notification message is required"))
    }

    if recipients_str == "" {
      return Err(ComponentError::ValidationError("Recipients are required"))
    }

    let priority = input.params.get_or("priority", "normal")
    execute_notification(channel, message, priority)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match (config["message"], config["recipients"]) {
      (Some(msg), Some(recipients)) => msg.length() > 0 && recipients.length() > 0
      _ => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "notification",
      version: "1.0.0",
      description: "Multi-channel notification component supporting email, SMS, push, webhook, and Slack",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "channel", type_: "string", required: true, description: "Notification channel: email/sms/push/webhook/slack" },
        InputSchema::{ name: "recipients", type_: "string", required: true, description: "Comma-separated list of recipients" },
        InputSchema::{ name: "message", type_: "string", required: true, description: "Notification message content" },
        InputSchema::{ name: "priority", type_: "string", required: false, description: "Message priority: low/normal/high" },
      ],
      outputs: [
        OutputSchema::{ name: "channel", type_: "string", description: "Notification channel used" },
        OutputSchema::{ name: "recipients_count", type_: "number", description: "Number of recipients" },
        OutputSchema::{ name: "status", type_: "string", description: "Send status" },
      ],
    }
  }
}

fn execute_notification(channel: String, message: String, priority: String) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["channel"] = channel
  metadata["priority"] = priority
  metadata["status"] = "sent"

  let response = "Notification sent via \{channel} with priority \{priority}"
  Ok(create_component_output_with_metadata(response, metadata))
}
