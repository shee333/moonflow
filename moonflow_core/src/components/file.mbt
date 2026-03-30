package moonflow_core::components

pub struct FileReadConfig {
  path: String
  encoding: String
  max_size: Int
}

pub struct FileWriteConfig {
  path: String
  encoding: String
  append: Bool
  create_dirs: Bool
}

pub struct FileDeleteConfig {
  path: String
  recursive: Bool
  must_exist: Bool
}

pub fn create_file_read_config(path: String) -> FileReadConfig {
  FileReadConfig::{ path, encoding: "utf-8", max_size: 10485760 }
}

pub fn create_file_write_config(path: String, content: String) -> FileWriteConfig {
  FileWriteConfig::{ path, encoding: "utf-8", append: false, create_dirs: false }
}

pub fn create_file_delete_config(path: String) -> FileDeleteConfig {
  FileDeleteConfig::{ path, recursive: false, must_exist: true }
}
