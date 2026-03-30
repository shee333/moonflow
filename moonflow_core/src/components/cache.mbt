package moonflow_core::components

pub struct CacheComponent

pub enum CacheOperation {
  | Get
  | Set
  | Delete
  | Clear
  | Exists
}

pub enum CacheBackend {
  | Memory
  | Redis
  | Memcached
  | File
}

pub struct CacheConfig {
  backend: CacheBackend
  host: String
  port: Int
  database: Int
  password: String?
  ttl: Int
  max_size: Int
  prefix: String
}

pub fn create_cache_component() -> CacheComponent {
  CacheComponent
}

pub fn create_cache_config(backend: CacheBackend, ttl: Int) -> CacheConfig {
  CacheConfig::{
    backend,
    host: "localhost",
    port: 6379,
    database: 0,
    password: None,
    ttl,
    max_size: 1000,
    prefix: "moonflow:",
  }
}

pub fn create_cache_config_with_host(
  backend: CacheBackend,
  host: String,
  port: Int,
  ttl: Int
) -> CacheConfig {
  CacheConfig::{
    backend,
    host,
    port,
    database: 0,
    password: None,
    ttl,
    max_size: 1000,
    prefix: "moonflow:",
  }
}
