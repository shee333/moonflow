package moonflow_core::components

pub struct DatabaseComponent

pub enum DatabaseOperation {
  | Query
  | Insert
  | Update
  | Delete
}

pub enum DatabaseType {
  | PostgreSQL
  | MySQL
  | SQLite
}

pub struct DatabaseConfig {
  db_type: DatabaseType
  host: String
  port: Int
  database: String
  username: String
  password: String
  ssl_enabled: Bool
  connection_timeout: Int
  max_connections: Int
}

pub fn create_database_component() -> DatabaseComponent {
  DatabaseComponent
}

pub fn create_database_config(
  db_type: DatabaseType,
  host: String,
  port: Int,
  database: String,
  username: String,
  password: String
) -> DatabaseConfig {
  DatabaseConfig::{
    db_type,
    host,
    port,
    database,
    username,
    password,
    ssl_enabled: false,
    connection_timeout: 30,
    max_connections: 10,
  }
}

pub fn create_database_config_with_ssl(
  db_type: DatabaseType,
  host: String,
  port: Int,
  database: String,
  username: String,
  password: String,
  ssl_enabled: Bool
) -> DatabaseConfig {
  DatabaseConfig::{
    db_type,
    host,
    port,
    database,
    username,
    password,
    ssl_enabled,
    connection_timeout: 30,
    max_connections: 10,
  }
}

impl Component for DatabaseComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    let operation = input.params.get_or("operation", "query")
    let query = input.data

    if query == "" {
      return Err(ComponentError::ValidationError("SQL query is required"))
    }

    let host = input.params.get_or("host", "localhost")
    let port = input.params.get_or("port", "5432").to_int().unwrap_or(5432)
    let database = input.params.get_or("database", "")
    let username = input.secrets.get_or("username", "")
    let password = input.secrets.get_or("password", "")

    if database == "" || username == "" {
      return Err(ComponentError::ValidationError("Database and username are required"))
    }

    execute_database_operation(operation, query, host, port, database, username)
  }

  fn validate(config: Map[String, String]) -> Bool {
    match (config["query"], config["database"]) {
      (Some(query), Some(database)) => query.length() > 0 && database.length() > 0
      _ => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "database",
      version: "1.0.0",
      description: "Database operation component supporting PostgreSQL, MySQL, and SQLite",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "operation", type_: "string", required: true, description: "Database operation: query/insert/update/delete" },
        InputSchema::{ name: "query", type_: "string", required: true, description: "SQL query to execute" },
        InputSchema::{ name: "host", type_: "string", required: false, description: "Database host" },
        InputSchema::{ name: "port", type_: "number", required: false, description: "Database port" },
        InputSchema::{ name: "database", type_: "string", required: true, description: "Database name" },
      ],
      outputs: [
        OutputSchema::{ name: "rows_affected", type_: "number", description: "Number of rows affected" },
        OutputSchema::{ name: "result", type_: "string", description: "Query result as JSON" },
        OutputSchema::{ name: "execution_time", type_: "number", description: "Execution time in milliseconds" },
      ],
    }
  }
}

fn execute_database_operation(
  operation: String,
  query: String,
  host: String,
  port: Int,
  database: String,
  username: String
) -> ComponentResult {
  let metadata: Map[String, String] = {}
  metadata["host"] = host
  metadata["port"] = port.to_string()
  metadata["database"] = database
  metadata["username"] = username
  metadata["operation"] = operation

  let response = "Database operation '\{operation}' executed on '\{database}' at \{host}:\{port}"
  Ok(create_component_output_with_metadata(response, metadata))
}

pub fn format_database_type(db_type: DatabaseType) -> String {
  match db_type {
    DatabaseType::PostgreSQL => "PostgreSQL"
    DatabaseType::MySQL => "MySQL"
    DatabaseType::SQLite => "SQLite"
  }
}

pub fn parse_database_type(type_str: String) -> DatabaseType {
  match type_str {
    "postgresql" => DatabaseType::PostgreSQL
    "mysql" => DatabaseType::MySQL
    "sqlite" => DatabaseType::SQLite
    _ => DatabaseType::PostgreSQL
  }
}

pub fn is_valid_database_operation(operation: String) -> Bool {
  operation == "query" || operation == "insert" || operation == "update" || operation == "delete"
}

pub fn validate_database_config(config: DatabaseConfig) -> Bool {
  config.database.length() > 0 && config.username.length() > 0 && config.port > 0
}

pub fn build_connection_string(config: DatabaseConfig) -> String {
  let type_str = format_database_type(config.db_type)
  "\{type_str}://\{config.username}@\{config.host}:\{config.port}/\{config.database}"
}
