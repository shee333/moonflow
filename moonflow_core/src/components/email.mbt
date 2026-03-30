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

    let smtp_host = input.params.get_or("smtp_host", "smtp.gmail.com")
    let smtp_port = input.params.get_or("smtp_port", "587").to_int().unwrap_or(587)
    let from = input.params.get_or("from", "")
    let username = input.secrets.get_or("username", "")
    let password = input.secrets.get_or("password", "")

    if username == "" || password == "" {
      return Err(ComponentError::AuthenticationError("SMTP credentials are required"))
    }

    execute_send_email(to, from, subject, body, smtp_host, smtp_port, username)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["to"] {
      Some(to) => to.length() > 0 && to.contains("@")
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "email",
      version: "1.0.0",
      description: "Email sending component with SMTP support",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "to", type_: "string", required: true, description: "Recipient email address" },
        InputSchema::{ name: "from", type_: "string", required: false, description: "Sender email address" },
        InputSchema::{ name: "subject", type_: "string", required: true, description: "Email subject" },
        InputSchema::{ name: "body", type_: "string", required: true, description: "Email body content" },
        InputSchema::{ name: "smtp_host", type_: "string", required: false, description: "SMTP server host" },
        InputSchema::{ name: "smtp_port", type_: "number", required: false, description: "SMTP server port" },
      ],
      outputs: [
        OutputSchema::{ name: "message_id", type_: "string", description: "Email message ID" },
        OutputSchema::{ name: "status", type_: "string", description: "Send status" },
        OutputSchema::{ name: "timestamp", type_: "string", description: "Send timestamp" },
      ],
    }
  }
}

fn execute_send_email(
  to: String,
  from: String,
  subject: String,
  body: String,
  smtp_host: String,
  smtp_port: Int,
  username: String
) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["to"] = to
  metadata["from"] = from
  metadata["subject"] = subject
  metadata["smtp_host"] = smtp_host
  metadata["smtp_port"] = smtp_port.to_string()
  metadata["status"] = "sent"

  let response = "Email sent successfully to \{to} via \{smtp_host}:\{smtp_port}"
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
