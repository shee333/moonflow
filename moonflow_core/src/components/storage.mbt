package moonflow_core::components

pub struct StorageComponent

pub enum StorageType {
  | Local
  | S3
  | GCS
  | AzureBlob
  | OSS
}

pub struct StorageConfig {
  storage_type: StorageType
  bucket: String
  region: String
  access_key: String?
  secret_key: String?
  endpoint: String?
  base_path: String
}

pub fn create_storage_component() -> StorageComponent {
  StorageComponent
}

pub fn create_storage_config(
  storage_type: StorageType,
  bucket: String,
  region: String
) -> StorageConfig {
  StorageConfig::{
    storage_type,
    bucket,
    region,
    access_key: None,
    secret_key: None,
    endpoint: None,
    base_path: "/",
  }
}

pub fn create_storage_config_with_credentials(
  storage_type: StorageType,
  bucket: String,
  region: String,
  access_key: String,
  secret_key: String
) -> StorageConfig {
  StorageConfig::{
    storage_type,
    bucket,
    region,
    access_key: Some(access_key),
    secret_key: Some(secret_key),
    endpoint: None,
    base_path: "/",
  }
}