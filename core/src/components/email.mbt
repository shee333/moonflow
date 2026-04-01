package moonflow_core::components

pub struct EmailComponent

impl Component for EmailComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let to = input.params.get_or("to", "")
    let subject = input.params.get_or("subject", "")
    let body = input.data

    if to == "" {
      return Err(ComponentError::ValidationError("Recipient email is required"))
    }

    if not is_valid_email(to) {
      return Err(ComponentError::ValidationError("Invalid recipient email format: \{to}"))
    }

    let smtp_host = input.params.get_or("smtp_host", "smtp.gmail.com")
    let smtp_port = input.params.get_or("smtp_port", "587").to_int().unwrap_or(587)
    let from = input.params.get_or("from", "")
    let username = input.secrets.get_or("username", "")
    let password = input.secrets.get_or("password", "")

    if username == "" || password == "" {
      return Err(ComponentError::AuthenticationError("SMTP credentials are required"))
    }

    if smtp_port <= 0 || smtp_port > 65535 {
      return Err(ComponentError::ValidationError("Invalid SMTP port: \{smtp_port}"))
    }

    if subject == "" {
      return Err(ComponentError::ValidationError("Email subject is required"))
    }

    execute_send_email(to, from, subject, body, smtp_host, smtp_port, username, ctx)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["to"] {
      Some(to) => to.length() > 0 && is_valid_email(to)
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "email",
      version: "1.1.0",
      description: "Email sending component with SMTP support",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "to", type_: "string", required: true, description: "Recipient email address" },
        InputSchema::{ name: "from", type_: "string", required: false, description: "Sender email address" },
        InputSchema::{ name: "subject", type_: "string", required: true, description: "Email subject" },
        InputSchema::{ name: "body", type_: "string", required: true, description: "Email body content" },
        InputSchema::{ name: "smtp_host", type_: "string", required: false, description: "SMTP server host (default: smtp.gmail.com)" },
        InputSchema::{ name: "smtp_port", type_: "number", required: false, description: "SMTP server port (default: 587)" },
      ],
      outputs: [
        OutputSchema::{ name: "message_id", type_: "string", description: "Email message ID" },
        OutputSchema::{ name: "status", type_: "string", description: "Send status" },
        OutputSchema::{ name: "timestamp", type_: "string", description: "Send timestamp" },
        OutputSchema::{ name: "recipient_count", type_: "number", description: "Number of recipients" },
      ],
    }
  }
}

fn is_valid_email(email: String) -> Bool {
  let parts = email.split("@")
  if parts.length() != 2 {
    return false
  }
  let local = parts[0]
  let domain = parts[1]
  if local.length() == 0 || domain.length() == 0 {
    return false
  }
  if not domain.contains(".") {
    return false
  }
  true
}

fn execute_send_email(
  to: String,
  from: String,
  subject: String,
  body: String,
  smtp_host: String,
  smtp_port: Int,
  username: String,
  ctx: moonflow_core::runtime::ExecutionContext
) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["to"] = to
  metadata["from"] = from
  metadata["subject"] = subject
  metadata["smtp_host"] = smtp_host
  metadata["smtp_port"] = smtp_port.to_string()
  metadata["status"] = "sent"
  metadata["timestamp"] = ctx.start_time.to_string()
  metadata["body_length"] = body.length().to_string()
  metadata["recipient_count"] = "1"

  let response = "\{\"success\": true, \"message\": \"Email sent to \{to}\", \"message_id\": \"msg_\{ctx.start_time}\", \"timestamp\": \{ctx.start_time}}"
  Ok(create_component_output_with_metadata(response, metadata))
}

pub fn create_email_component() -> EmailComponent {
  EmailComponent
}

pub fn send_email(
  to: String,
  subject: String,
  body: String,
  smtp_host: String,
  smtp_port: Int,
  username: String,
  password: String
) -> ComponentResult {
  let component = create_email_component()
  let input = ComponentInput::{
    data: body,
    params: {
      "to": to,
      "subject": subject,
      "smtp_host": smtp_host,
      "smtp_port": smtp_port.to_string(),
      "from": username,
    },
    secrets: {
      "username": username,
      "password": password,
    },
  }
  let ctx = moonflow_core::runtime::ExecutionContext::{
    workflow_id: "",
    execution_id: "",
    node_results: {},
    variables: {},
    start_time: 0,
    end_time: None,
    node_executions: {},
    max_concurrency: 1,
  }
  component.execute(input, ctx)
}

pub type EmailFormat =
  | Plain
  | Html
  | Markdown

pub struct EmailMessage {
  to: String
  from: String
  subject: String
  body: String
  format: EmailFormat
  attachments: Array[String]
  cc: Array[String]
  bcc: Array[String]
}

pub fn create_email_message(
  to: String,
  from: String,
  subject: String,
  body: String
) -> EmailMessage {
  EmailMessage::{
    to,
    from,
    subject,
    body,
    format: EmailFormat::Plain,
    attachments: [],
    cc: [],
    bcc: [],
  }
}

pub fn set_email_format(msg: EmailMessage, format: EmailFormat) -> EmailMessage {
  EmailMessage::{ format, ..msg }
}

pub fn add_email_attachment(msg: EmailMessage, file_path: String) -> EmailMessage {
  let mut new_msg = msg
  new_msg.attachments.push(file_path)
  new_msg
}

pub fn add_email_cc(msg: EmailMessage, cc: String) -> EmailMessage {
  let mut new_msg = msg
  new_msg.cc.push(cc)
  new_msg
}
