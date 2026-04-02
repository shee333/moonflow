package moonflow_core::utils

pub fn trim(s: String) -> String {
  trim_left(trim_right(s))
}

pub fn trim_left(s: String) -> String {
  let mut i = 0
  let len = s.length()
  while i < len {
    let c = s[i]
    if c != ' ' && c != '\t' && c != '\n' && c != '\r' {
      break
    }
    i = i + 1
  }
  if i >= len {
    return ""
  }
  s.substring(i, len - i)
}

pub fn trim_right(s: String) -> String {
  let len = s.length()
  if len == 0 {
    return ""
  }
  let mut i = len - 1
  while i >= 0 {
    let c = s[i]
    if c != ' ' && c != '\t' && c != '\n' && c != '\r' {
      break
    }
    i = i - 1
  }
  if i < 0 {
    return ""
  }
  s.substring(0, i + 1)
}

pub fn is_empty(s: String) -> Bool {
  trim(s).length() == 0
}

pub fn is_blank(s: String) -> Bool {
  s.length() == 0 || is_empty(s)
}

pub fn capitalize(s: String) -> String {
  if s.length() == 0 {
    return ""
  }
  let first = s[0]
  let upper = capitalize_char(first)
  if upper == first.to_string() {
    return s
  }
  upper + s.substring(1, s.length() - 1)
}

fn capitalize_char(c: Char) -> String {
  if c >= 'a' && c <= 'z' {
    let code = c.to_int() - 32
    Char::from_int(code).to_string()
  } else {
    c.to_string()
  }
}

pub fn to_upper(s: String) -> String {
  let result = StringBuilder::new()
  for c in s {
    if c >= 'a' && c <= 'z' {
      let code = c.to_int() - 32
      result.write_char(Char::from_int(code))
    } else {
      result.write_char(c)
    }
  }
  result.to_string()
}

pub fn to_lower(s: String) -> String {
  let result = StringBuilder::new()
  for c in s {
    if c >= 'A' && c <= 'Z' {
      let code = c.to_int() + 32
      result.write_char(Char::from_int(code))
    } else {
      result.write_char(c)
    }
  }
  result.to_string()
}

pub fn reverse(s: String) -> String {
  let result = StringBuilder::new()
  let len = s.length()
  let mut i = len - 1
  while i >= 0 {
    result.write_char(s[i])
    i = i - 1
  }
  result.to_string()
}

pub fn contains(s: String, substr: String) -> Bool {
  index_of(s, substr).is_some()
}

pub fn not_contains(s: String, substr: String) -> Bool {
  not contains(s, substr)
}

pub fn starts_with(s: String, prefix: String) -> Bool {
  if prefix.length() > s.length() {
    return false
  }
  s.substring(0, prefix.length()) == prefix
}

pub fn ends_with(s: String, suffix: String) -> Bool {
  if suffix.length() > s.length() {
    return false
  }
  s.substring(s.length() - suffix.length(), suffix.length()) == suffix
}

pub fn index_of(s: String, substr: String) -> Int? {
  if substr.length() == 0 {
    return Some(0)
  }
  if substr.length() > s.length() {
    return None
  }
  let max_start = s.length() - substr.length()
  let mut i = 0
  while i <= max_start {
    if s.substring(i, substr.length()) == substr {
      return Some(i)
    }
    i = i + 1
  }
  None
}

pub fn last_index_of(s: String, substr: String) -> Int? {
  if substr.length() == 0 {
    return Some(s.length())
  }
  if substr.length() > s.length() {
    return None
  }
  let mut i = s.length() - substr.length()
  while i >= 0 {
    if s.substring(i, substr.length()) == substr {
      return Some(i)
    }
    i = i - 1
  }
  None
}

pub fn replace(s: String, old: String, new: String) -> String {
  if old.length() == 0 {
    return s
  }
  let result = StringBuilder::new()
  let mut i = 0
  while i < s.length() {
    if s.substring(i, old.length()) == old {
      result.write_string(new)
      i = i + old.length()
    } else {
      result.write_char(s[i])
      i = i + 1
    }
  }
  result.to_string()
}

pub fn replace_all(s: String, old: String, new: String) -> String {
  if old.length() == 0 {
    return s
  }
  let result = StringBuilder::new()
  let mut i = 0
  let mut replaced = false
  while i < s.length() {
    if not replaced && i <= s.length() - old.length() && s.substring(i, old.length()) == old {
      result.write_string(new)
      i = i + old.length()
      replaced = true
    } else {
      result.write_char(s[i])
      i = i + 1
      replaced = false
    }
  }
  result.to_string()
}

pub fn split(s: String, delimiter: String) -> Array[String] {
  if delimiter.length() == 0 {
    return [s]
  }
  let result: Array[String] = []
  let mut start = 0
  let mut i = 0
  while i <= s.length() - delimiter.length() {
    if s.substring(i, delimiter.length()) == delimiter {
      result.push(s.substring(start, i - start))
      start = i + delimiter.length()
      i = start - 1
    }
    i = i + 1
  }
  result.push(s.substring(start, s.length() - start))
  result
}

pub fn join(arr: Array[String], separator: String) -> String {
  if arr.length() == 0 {
    return ""
  }
  let result = StringBuilder::new()
  result.write_string(arr[0])
  let mut i = 1
  while i < arr.length() {
    result.write_string(separator)
    result.write_string(arr[i])
    i = i + 1
  }
  result.to_string()
}

pub fn repeat(s: String, count: Int) -> String {
  if count <= 0 {
    return ""
  }
  let result = StringBuilder::new()
  let mut i = 0
  while i < count {
    result.write_string(s)
    i = i + 1
  }
  result.to_string()
}

pub fn pad_left(s: String, length: Int, char: Char) -> String {
  let pad_len = length - s.length()
  if pad_len <= 0 {
    return s
  }
  repeat(char.to_string(), pad_len) + s
}

pub fn pad_right(s: String, length: Int, char: Char) -> String {
  let pad_len = length - s.length()
  if pad_len <= 0 {
    return s
  }
  s + repeat(char.to_string(), pad_len)
}

pub fn truncate(s: String, max_length: Int, suffix: String) -> String {
  if s.length() <= max_length {
    return s
  }
  let actual_max = max_length - suffix.length()
  if actual_max <= 0 {
    return truncate(s, max_length, "")
  }
  s.substring(0, actual_max) + suffix
}

pub fn word_count(s: String) -> Int {
  if s.length() == 0 {
    return 0
  }
  let mut count = 0
  let mut in_word = false
  for c in s {
    let is_word_char = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_'
    if is_word_char && not in_word {
      count = count + 1
      in_word = true
    } else if not is_word_char {
      in_word = false
    }
  }
  count
}

pub fn lines(s: String) -> Array[String] {
  split(s, "\n")
}

pub fn unlines(arr: Array[String]) -> String {
  join(arr, "\n")
}

pub fn words(s: String) -> Array[String] {
  let words_array: Array[String] = []
  let mut current = StringBuilder::new()
  for c in s {
    let is_word_char = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_'
    if is_word_char {
      current.write_char(c)
    } else if current.to_string().length() > 0 {
      words_array.push(current.to_string())
      current = StringBuilder::new()
    }
  }
  if current.to_string().length() > 0 {
    words_array.push(current.to_string())
  }
  words_array
}

pub fn escape_json(s: String) -> String {
  let result = StringBuilder::new()
  for c in s {
    match c {
      '"' => result.write_string("\\\"")
      '\\' => result.write_string("\\\\")
      '/' => result.write_string("\\/")
      '\b' => result.write_string("\\b")
      '\u000c' => result.write_string("\\f")
      '\n' => result.write_string("\\n")
      '\r' => result.write_string("\\r")
      '\t' => result.write_string("\\t")
      _ => result.write_char(c)
    }
  }
  result.to_string()
}

pub fn unescape_json(s: String) -> String {
  let result = StringBuilder::new()
  let mut i = 0
  while i < s.length() {
    if s[i] == '\\' && i + 1 < s.length() {
      let next = s[i + 1]
      match next {
        '"' => { result.write_char('"'); i = i + 2 }
        '\\' => { result.write_char('\\'); i = i + 2 }
        '/' => { result.write_char('/'); i = i + 2 }
        'b' => { result.write_char('\b'); i = i + 2 }
        'f' => { result.write_char('\u000c'); i = i + 2 }
        'n' => { result.write_char('\n'); i = i + 2 }
        'r' => { result.write_char('\r'); i = i + 2 }
        't' => { result.write_char('\t'); i = i + 2 }
        _ => { result.write_char(s[i]); i = i + 1 }
      }
    } else {
      result.write_char(s[i])
      i = i + 1
    }
  }
  result.to_string()
}

pub fn slugify(s: String) -> String {
  let lower = to_lower(s)
  let no_special = StringBuilder::new()
  for c in lower {
    if (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-' || c == '_' {
      no_special.write_char(c)
    } else if c == ' ' || c == '-' || c == '_' {
      no_special.write_char('-')
    }
  }
  let result = no_special.to_string()
  let parts = split(result, "-")
  let filtered: Array[String] = []
  for part in parts {
    if part.length() > 0 {
      filtered.push(part)
    }
  }
  join(filtered, "-")
}

pub fn camel_case(s: String) -> String {
  let words_arr = words(s)
  if words_arr.length() == 0 {
    return ""
  }
  let result = StringBuilder::new()
  result.write_string(to_lower(words_arr[0]))
  let mut i = 1
  while i < words_arr.length() {
    result.write_string(capitalize(words_arr[i]))
    i = i + 1
  }
  result.to_string()
}

pub fn snake_case(s: String) -> String {
  let words_arr = words(s)
  let lower_words: Array[String] = []
  for word in words_arr {
    lower_words.push(to_lower(word))
  }
  join(lower_words, "_")
}

pub fn kebab_case(s: String) -> String {
  let words_arr = words(s)
  let lower_words: Array[String] = []
  for word in words_arr {
    lower_words.push(to_lower(word))
  }
  join(lower_words, "-")
}
