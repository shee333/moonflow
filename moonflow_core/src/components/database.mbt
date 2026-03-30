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
