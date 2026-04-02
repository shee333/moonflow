package moonflow_core::utils

pub fn is_valid_email(email: String) -> Bool {
  if email.length() == 0 {
    return false
  }
  let at_index = index_of(email, "@")
  match at_index {
    Some(idx) => {
      if idx == 0 || idx == email.length() - 1 {
        return false
      }
      let local = email.substring(0, idx)
      let domain = email.substring(idx + 1, email.length() - idx - 1)
      if local.length() == 0 || domain.length() == 0 {
        return false
      }
      if not contains(domain, ".") {
        return false
      }
      if starts_with(domain, ".") || ends_with(domain, ".") {
        return false
      }
      true
    }
    None => false
  }
}

pub fn is_valid_url(url: String) -> Bool {
  if url.length() == 0 {
    return false
  }
  let schemes = ["http://", "https://", "ftp://", "file://"]
  let mut valid = false
  for scheme in schemes {
    if starts_with(to_lower(url), scheme) {
      valid = true
      break
    }
  }
  if not valid {
    return false
  }
  let without_scheme = if starts_with(to_lower(url), "https://") {
    url.substring(8, url.length() - 8)
  } else if starts_with(to_lower(url), "http://") {
    url.substring(7, url.length() - 7)
  } else if starts_with(to_lower(url), "ftp://") {
    url.substring(6, url.length() - 6)
  } else {
    url.substring(5, url.length() - 5)
  }
  if without_scheme.length() == 0 {
    return false
  }
  let path_start = index_of(without_scheme, "/")
  let host = match path_start {
    Some(idx) => without_scheme.substring(0, idx)
    None => without_scheme
  }
  if host.length() == 0 {
    return false
  }
  let port_separator = index_of(host, ":")
  let actual_host = match port_separator {
    Some(idx) => host.substring(0, idx)
    None => host
  }
  if actual_host.length() == 0 {
    return false
  }
  for c in actual_host {
    if not ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '-' || c == '.') {
      return false
    }
  }
  true
}

pub fn is_valid_phone(phone: String) -> Bool {
  if phone.length() < 7 {
    return false
  }
  let digits = StringBuilder::new()
  for c in phone {
    if c >= '0' && c <= '9' {
      digits.write_char(c)
    }
  }
  let digit_count = digits.to_string().length()
  digit_count >= 7 && digit_count <= 15
}

pub fn is_numeric(s: String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let mut has_digit = false
  let mut has_decimal = false
  let mut has_sign = false
  let chars = to_lower(s)
  for (i, c) in chars {
    if c == '-' || c == '+' {
      if has_digit || has_decimal {
        return false
      }
      has_sign = true
    } else if c == '.' {
      if has_decimal {
        return false
      }
      has_decimal = true
    } else if c >= '0' && c <= '9' {
      has_digit = true
    } else {
      return false
    }
  }
  has_digit
}

pub fn is_alpha(s: String) -> Bool {
  if s.length() == 0 {
    return false
  }
  for c in s {
    if not ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')) {
      return false
    }
  }
  true
}

pub fn is_alphanumeric(s: String) -> Bool {
  if s.length() == 0 {
    return false
  }
  for c in s {
    if not ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')) {
      return false
    }
  }
  true
}

pub fn is_hex_color(s: String) -> Bool {
  if not starts_with(s, "#") {
    return false
  }
  let hex = s.substring(1, s.length() - 1)
  if hex.length() != 3 && hex.length() != 6 && hex.length() != 8 {
    return false
  }
  for c in hex {
    if not ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) {
      return false
    }
  }
  true
}

pub fn is_ipv4(ip: String) -> Bool {
  let parts = split(ip, ".")
  if parts.length() != 4 {
    return false
  }
  for part in parts {
    if not is_numeric(part) {
      return false
    }
    let num = string_to_int(part)
    match num {
      Some(n) => {
        if n < 0 || n > 255 {
          return false
        }
      }
      None => return false
    }
  }
  true
}

pub fn is_ipv6(ip: String) -> Bool {
  if ip.length() == 0 {
    return false
  }
  let double_colon_count = count_occurrences(ip, "::")
  if double_colon_count > 1 {
    return false
  }
  let groups = split(ip.replace("::", ":"), ":")
  if groups.length() > 8 {
    return false
  }
  if double_colon_count == 1 && groups.length() < 2 {
    return false
  }
  for group in groups {
    if group.length() == 0 {
      continue
    }
    if group.length() > 4 {
      return false
    }
    for c in group {
      if not ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) {
        return false
      }
    }
  }
  true
}

fn count_occurrences(s: String, substr: String) -> Int {
  if substr.length() == 0 {
    return 0
  }
  let mut count = 0
  let mut i = 0
  while i <= s.length() - substr.length() {
    if s.substring(i, substr.length()) == substr {
      count = count + 1
      i = i + substr.length()
    } else {
      i = i + 1
    }
  }
  count
}

pub fn is_json(s: String) -> Bool {
  let trimmed = trim(s)
  if trimmed.length() == 0 {
    return false
  }
  let first = trimmed[0]
  let last = trimmed[trimmed.length() - 1]
  if first == '{' && last == '}' {
    return true
  }
  if first == '[' && last == ']' {
    return true
  }
  false
}

pub fn is_yaml(s: String) -> Bool {
  let lines_arr = lines(s)
  if lines_arr.length() == 0 {
    return false
  }
  for line in lines_arr {
    let trimmed_line = trim(line)
    if trimmed_line.length() == 0 || starts_with(trimmed_line, "#") {
      continue
    }
    if contains(trimmed_line, ":") {
      return true
    }
    if starts_with(trimmed_line, "-") {
      return true
    }
  }
  false
}

pub fn is_uuid(s: String) -> Bool {
  let pattern = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  if s.length() != pattern.length() {
    return false
  }
  let mut i = 0
  while i < s.length() {
    let pc = pattern[i]
    let sc = s[i]
    if pc == '-' {
      if sc != '-' {
        return false
      }
    } else if pc == 'x' {
      if not ((sc >= '0' && sc <= '9') || (sc >= 'a' && sc <= 'f') || (sc >= 'A' && sc <= 'F')) {
        return false
      }
    }
    i = i + 1
  }
  true
}

pub fn is_md5(s: String) -> Bool {
  if s.length() != 32 {
    return false
  }
  for c in s {
    if not ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f')) {
      return false
    }
  }
  true
}

pub fn is_sha256(s: String) -> Bool {
  if s.length() != 64 {
    return false
  }
  for c in s {
    if not ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f')) {
      return false
    }
  }
  true
}

pub fn is_base64(s: String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let valid_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
  for c in s {
    let mut found = false
    for vc in valid_chars {
      if c == vc {
        found = true
        break
      }
    }
    if not found {
      return false
    }
  }
  let padding = count_occurrences(s, "=")
  if padding > 2 {
    return false
  }
  let content_length = s.length() - padding
  if content_length % 4 != 0 {
    return false
  }
  true
}

pub fn is_port(port: String) -> Bool {
  match string_to_int(port) {
    Some(n) => n >= 1 && n <= 65535
    None => false
  }
}

pub fn is_port_range(port_range: String) -> Bool {
  let parts = split(port_range, "-")
  if parts.length() != 2 {
    return false
  }
  match (string_to_int(parts[0]), string_to_int(parts[1])) {
    (Some(start), Some(end)) => {
      start >= 1 && start <= 65535 && end >= 1 && end <= 65535 && start <= end
    }
    _ => false
  }
}

pub fn is_credit_card(card: String) -> Bool {
  let digits = StringBuilder::new()
  for c in card {
    if c >= '0' && c <= '9' {
      digits.write_char(c)
    }
  }
  let digit_str = digits.to_string()
  if digit_str.length() < 13 || digit_str.length() > 19 {
    return false
  }
  let mut sum = 0
  let mut alternate = false
  let mut i = digit_str.length() - 1
  while i >= 0 {
    let num = digit_str[i].to_int() - '0'.to_int()
    if alternate {
      let doubled = num * 2
      sum = sum + if doubled > 9 { doubled - 9 } else { doubled }
    } else {
      sum = sum + num
    }
    alternate = not alternate
    if i == 0 {
      break
    }
    i = i - 1
  }
  sum % 10 == 0
}

pub fn validate_length(s: String, min: Int, max: Int) -> Bool {
  let len = s.length()
  len >= min && len <= max
}

pub fn validate_pattern(s: String, pattern: String) -> Bool {
  match pattern {
    "email" => is_valid_email(s)
    "url" => is_valid_url(s)
    "phone" => is_valid_phone(s)
    "ipv4" => is_ipv4(s)
    "ipv6" => is_ipv6(s)
    "json" => is_json(s)
    "uuid" => is_uuid(s)
    "md5" => is_md5(s)
    "sha256" => is_sha256(s)
    "hex_color" => is_hex_color(s)
    "numeric" => is_numeric(s)
    "alpha" => is_alpha(s)
    "alphanumeric" => is_alphanumeric(s)
    "credit_card" => is_credit_card(s)
    "port" => is_port(s)
    _ => false
  }
}

pub struct ValidationResult {
  valid: Bool
  errors: Array[String]
}

pub fn validate_required(value: String, field_name: String) -> ValidationResult {
  if is_blank(value) {
    ValidationResult::{ valid: false, errors: ["\{field_name} is required"] }
  } else {
    ValidationResult::{ valid: true, errors: [] }
  }
}

pub fn validate_email(value: String, field_name: String) -> ValidationResult {
  if not is_valid_email(value) {
    ValidationResult::{ valid: false, errors: ["\{field_name} must be a valid email"] }
  } else {
    ValidationResult::{ valid: true, errors: [] }
  }
}

pub fn validate_url(value: String, field_name: String) -> ValidationResult {
  if not is_valid_url(value) {
    ValidationResult::{ valid: false, errors: ["\{field_name} must be a valid URL"] }
  } else {
    ValidationResult::{ valid: true, errors: [] }
  }
}

pub fn validate_min_length(value: String, min: Int, field_name: String) -> ValidationResult {
  if value.length() < min {
    ValidationResult::{ valid: false, errors: ["\{field_name} must be at least \{min} characters"] }
  } else {
    ValidationResult::{ valid: true, errors: [] }
  }
}

pub fn validate_max_length(value: String, max: Int, field_name: String) -> ValidationResult {
  if value.length() > max {
    ValidationResult::{ valid: false, errors: ["\{field_name} must be at most \{max} characters"] }
  } else {
    ValidationResult::{ valid: true, errors: [] }
  }
}

pub fn validate_range(value: String, min: Int, max: Int, field_name: String) -> ValidationResult {
  match string_to_int(value) {
    Some(n) => {
      if n < min || n > max {
        ValidationResult::{ valid: false, errors: ["\{field_name} must be between \{min} and \{max}"] }
      } else {
        ValidationResult::{ valid: true, errors: [] }
      }
    }
    None => ValidationResult::{ valid: false, errors: ["\{field_name} must be a valid number"] }
  }
}

pub fn validate_pattern_custom(value: String, pattern: String, error_msg: String, field_name: String) -> ValidationResult {
  if not validate_pattern(value, pattern) {
    ValidationResult::{ valid: false, errors: ["\{field_name}: \{error_msg}"] }
  } else {
    ValidationResult::{ valid: true, errors: [] }
  }
}

fn string_to_int(s: String) -> Int? {
  if s.length() == 0 {
    return None
  }
  let mut result = 0
  let mut negative = false
  let chars = s.to_bytes()
  let mut i = 0
  if chars[0] == '-' {
    negative = true
    i = 1
  } else if chars[0] == '+' {
    i = 1
  }
  while i < chars.length() {
    let c = chars[i]
    if c < '0'.to_int() || c > '9'.to_int() {
      return None
    }
    result = result * 10 + (c - '0'.to_int())
    i = i + 1
  }
  if negative {
    Some(-result)
  } else {
    Some(result)
  }
}
