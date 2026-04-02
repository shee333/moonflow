package moonflow_core::utils

pub struct DateTime {
  year: Int
  month: Int
  day: Int
  hour: Int
  minute: Int
  second: Int
  millisecond: Int
}

pub fn now() -> DateTime {
  DateTime::{
    year: 2026,
    month: 4,
    day: 2,
    hour: 12,
    minute: 0,
    second: 0,
    millisecond: 0,
  }
}

pub fn create_date_time(
  year: Int,
  month: Int,
  day: Int,
  hour: Int,
  minute: Int,
  second: Int
) -> DateTime {
  DateTime::{
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond: 0,
  }
}

pub fn create_date(year: Int, month: Int, day: Int) -> DateTime {
  create_date_time(year, month, day, 0, 0, 0)
}

pub fn to_timestamp(dt: DateTime) -> Int {
  let days = days_since_epoch(dt.year, dt.month, dt.day)
  let seconds = days * 86400 + dt.hour * 3600 + dt.minute * 60 + dt.second
  seconds * 1000 + dt.millisecond
}

pub fn from_timestamp(timestamp: Int) -> DateTime {
  let total_seconds = timestamp / 1000
  let ms = timestamp % 1000
  let days = total_seconds / 86400
  let remaining = total_seconds % 86400
  let hour = remaining / 3600
  let minute = (remaining % 3600) / 60
  let second = remaining % 60
  
  let (year, month, day) = date_from_days(days)
  
  DateTime::{
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond: ms,
  }
}

fn days_since_epoch(year: Int, month: Int, day: Int) -> Int {
  let total_days = day - 32045
  let year_month = year + 4800 - if month <= 2 { 1 } else { 0 }
  let total_days2 = total_days + (year_month * 365) + (year_month / 4) - (year_month / 100) + (year_month / 400)
  total_days2 - 2447088
}

fn date_from_days(days: Int) -> (Int, Int, Int) {
  let z = days + 2447088
  let a = (4 * z + 3) / 146097
  let b = z - (146097 * a) / 4
  let c = (4 * b + 3) / 1461
  let d = b - (1461 * c) / 4
  let m = (5 * d + 2) / 153
  let day = d - (153 * m + 2) / 5 + 1
  let month = m + 3 - 12 * (m / 10)
  let year = 100 * a + c + m / 10 - 4800 + if m >= 10 { 1 } else { 0 }
  (year, month, day)
}

pub fn format_datetime(dt: DateTime, format: String) -> String {
  let result = replace(format, "YYYY", pad_left(dt.year.to_string(), 4, '0'))
  let result = replace(result, "YY", pad_left((dt.year % 100).to_string(), 2, '0'))
  let result = replace(result, "MM", pad_left(dt.month.to_string(), 2, '0'))
  let result = replace(result, "DD", pad_left(dt.day.to_string(), 2, '0'))
  let result = replace(result, "HH", pad_left(dt.hour.to_string(), 2, '0'))
  let result = replace(result, "mm", pad_left(dt.minute.to_string(), 2, '0'))
  let result = replace(result, "ss", pad_left(dt.second.to_string(), 2, '0'))
  let result = replace(result, "SSS", pad_left(dt.millisecond.to_string(), 3, '0'))
  result
}

pub fn format_date(dt: DateTime) -> String {
  format_datetime(dt, "YYYY-MM-DD")
}

pub fn format_time(dt: DateTime) -> String {
  format_datetime(dt, "HH:mm:ss")
}

pub fn format_iso8601(dt: DateTime) -> String {
  format_datetime(dt, "YYYY-MM-DDTHH:mm:ss.SSSZ")
}

pub fn parse_datetime(date_str: String, format: String) -> DateTime? {
  let parts = parse_datetime_parts(date_str, format)
  match parts {
    Some((year, month, day, hour, minute, second, ms)) => {
      if is_valid_date(year, month, day) && is_valid_time(hour, minute, second, ms) {
        Some(DateTime::{ year, month, day, hour, minute, second, millisecond: ms })
      } else {
        None
      }
    }
    None => None
  }
}

fn parse_datetime_parts(
  date_str: String,
  format: String
) -> (Int, Int, Int, Int, Int, Int, Int)? {
  let year_idx = index_of(format, "YYYY")
  let month_idx = index_of(format, "MM")
  let day_idx = index_of(format, "DD")
  let hour_idx = index_of(format, "HH")
  let minute_idx = index_of(format, "mm")
  let second_idx = index_of(format, "ss")
  
  let year = match year_idx {
    Some(idx) => {
      let s = date_str.substring(idx, 4)
      string_to_int(s)
    }
    None => Some(0)
  }
  
  let month = match month_idx {
    Some(idx) => {
      let s = date_str.substring(idx, 2)
      string_to_int(s)
    }
    None => Some(1)
  }
  
  let day = match day_idx {
    Some(idx) => {
      let s = date_str.substring(idx, 2)
      string_to_int(s)
    }
    None => Some(1)
  }
  
  let hour = match hour_idx {
    Some(idx) => {
      let s = date_str.substring(idx, 2)
      string_to_int(s)
    }
    None => Some(0)
  }
  
  let minute = match minute_idx {
    Some(idx) => {
      let s = date_str.substring(idx, 2)
      string_to_int(s)
    }
    None => Some(0)
  }
  
  let second = match second_idx {
    Some(idx) => {
      let s = date_str.substring(idx, 2)
      string_to_int(s)
    }
    None => Some(0)
  }
  
  match (year, month, day, hour, minute, second) {
    (Some(y), Some(m), Some(d), Some(h), Some(mi), Some(s)) => {
      Some((y, m, d, h, mi, s, 0))
    }
    _ => None
  }
}

pub fn is_valid_date(year: Int, month: Int, day: Int) -> Bool {
  if month < 1 || month > 12 {
    return false
  }
  if day < 1 {
    return false
  }
  let max_day = days_in_month(year, month)
  day <= max_day
}

pub fn is_valid_time(hour: Int, minute: Int, second: Int, ms: Int) -> Bool {
  hour >= 0 && hour <= 23 &&
  minute >= 0 && minute <= 59 &&
  second >= 0 && second <= 59 &&
  ms >= 0 && ms <= 999
}

pub fn days_in_month(year: Int, month: Int) -> Int {
  let days_per_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  if month == 2 && is_leap_year(year) {
    return 29
  }
  if month >= 1 && month <= 12 {
    days_per_month[month - 1]
  } else {
    0
  }
}

pub fn is_leap_year(year: Int) -> Bool {
  (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
}

pub fn day_of_year(dt: DateTime) -> Int {
  let mut total = 0
  let mut m = 1
  while m < dt.month {
    total = total + days_in_month(dt.year, m)
    m = m + 1
  }
  total + dt.day
}

pub fn day_of_week(dt: DateTime) -> Int {
  let z = days_since_epoch(dt.year, dt.month, dt.day)
  let day = (z + 1) % 7
  if day < 0 { day + 7 } else { day }
}

pub fn weekday_name(dt: DateTime) -> String {
  let names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  names[day_of_week(dt)]
}

pub fn weekday_short_name(dt: DateTime) -> String {
  let names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  names[day_of_week(dt)]
}

pub fn month_name(dt: DateTime) -> String {
  let names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
  names[dt.month - 1]
}

pub fn month_short_name(dt: DateTime) -> String {
  let names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  names[dt.month - 1]
}

pub fn add_years(dt: DateTime, years: Int) -> DateTime {
  DateTime::{
    year: dt.year + years,
    month: dt.month,
    day: dt.day,
    hour: dt.hour,
    minute: dt.minute,
    second: dt.second,
    millisecond: dt.millisecond,
  }
}

pub fn add_months(dt: DateTime, months: Int) -> DateTime {
  let total_months = dt.month - 1 + months
  let year_offset = total_months / 12
  let new_month = (total_months % 12) + 1
  let new_year = dt.year + year_offset
  let max_day = days_in_month(new_year, new_month)
  let new_day = if dt.day > max_day { max_day } else { dt.day }
  
  DateTime::{
    year: new_year,
    month: new_month,
    day: new_day,
    hour: dt.hour,
    minute: dt.minute,
    second: dt.second,
    millisecond: dt.millisecond,
  }
}

pub fn add_days(dt: DateTime, days: Int) -> DateTime {
  let total_days = days_since_epoch(dt.year, dt.month, dt.day) + days
  let (year, month, day) = date_from_days(total_days)
  DateTime::{
    year,
    month,
    day,
    hour: dt.hour,
    minute: dt.minute,
    second: dt.second,
    millisecond: dt.millisecond,
  }
}

pub fn add_hours(dt: DateTime, hours: Int) -> DateTime {
  let total_seconds = dt.hour * 3600 + dt.minute * 60 + dt.second + hours * 3600
  let days_offset = total_seconds / 86400
  let remaining = total_seconds % 86400
  let new_hour = remaining / 3600
  let new_minute = (remaining % 3600) / 60
  let new_second = remaining % 60
  
  let base_date = add_days(dt, days_offset)
  DateTime::{
    year: base_date.year,
    month: base_date.month,
    day: base_date.day,
    hour: new_hour,
    minute: new_minute,
    second: new_second,
    millisecond: dt.millisecond,
  }
}

pub fn add_minutes(dt: DateTime, minutes: Int) -> DateTime {
  let total_seconds = dt.hour * 3600 + dt.minute * 60 + dt.second + minutes * 60
  let days_offset = total_seconds / 86400
  let remaining = total_seconds % 86400
  let new_hour = remaining / 3600
  let new_minute = (remaining % 3600) / 60
  let new_second = remaining % 60
  
  let base_date = add_days(dt, days_offset)
  DateTime::{
    year: base_date.year,
    month: base_date.month,
    day: base_date.day,
    hour: new_hour,
    minute: new_minute,
    second: new_second,
    millisecond: dt.millisecond,
  }
}

pub fn add_seconds(dt: DateTime, seconds: Int) -> DateTime {
  let total_seconds = dt.hour * 3600 + dt.minute * 60 + dt.second + seconds
  let days_offset = total_seconds / 86400
  let remaining = total_seconds % 86400
  let new_hour = remaining / 3600
  let new_minute = (remaining % 3600) / 60
  let new_second = remaining % 60
  
  let base_date = add_days(dt, days_offset)
  DateTime::{
    year: base_date.year,
    month: base_date.month,
    day: base_date.day,
    hour: new_hour,
    minute: new_minute,
    second: new_second,
    millisecond: dt.millisecond,
  }
}

pub fn difference_in_days(dt1: DateTime, dt2: DateTime) -> Int {
  let days1 = days_since_epoch(dt1.year, dt1.month, dt1.day)
  let days2 = days_since_epoch(dt2.year, dt2.month, dt2.day)
  days2 - days1
}

pub fn difference_in_hours(dt1: DateTime, dt2: DateTime) -> Int {
  let seconds1 = dt1.hour * 3600 + dt1.minute * 60 + dt1.second
  let seconds2 = dt2.hour * 3600 + dt2.minute * 60 + dt2.second
  let days_diff = difference_in_days(dt1, dt2)
  days_diff * 24 + (seconds2 - seconds1) / 3600
}

pub fn difference_in_minutes(dt1: DateTime, dt2: DateTime) -> Int {
  let seconds1 = dt1.hour * 3600 + dt1.minute * 60 + dt1.second
  let seconds2 = dt2.hour * 3600 + dt2.minute * 60 + dt2.second
  let days_diff = difference_in_days(dt1, dt2)
  days_diff * 1440 + (seconds2 - seconds1) / 60
}

pub fn difference_in_seconds(dt1: DateTime, dt2: DateTime) -> Int {
  let seconds1 = dt1.hour * 3600 + dt1.minute * 60 + dt1.second
  let seconds2 = dt2.hour * 3600 + dt2.minute * 60 + dt2.second
  let days_diff = difference_in_days(dt1, dt2)
  days_diff * 86400 + (seconds2 - seconds1)
}

pub fn start_of_day(dt: DateTime) -> DateTime {
  DateTime::{
    year: dt.year,
    month: dt.month,
    day: dt.day,
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
  }
}

pub fn end_of_day(dt: DateTime) -> DateTime {
  DateTime::{
    year: dt.year,
    month: dt.month,
    day: dt.day,
    hour: 23,
    minute: 59,
    second: 59,
    millisecond: 999,
  }
}

pub fn start_of_week(dt: DateTime) -> DateTime {
  let dow = day_of_week(dt)
  let days_to_subtract = dow
  let start = add_days(dt, -days_to_subtract)
  start_of_day(start)
}

pub fn end_of_week(dt: DateTime) -> DateTime {
  let dow = day_of_week(dt)
  let days_to_add = 6 - dow
  let end = add_days(dt, days_to_add)
  end_of_day(end)
}

pub fn start_of_month(dt: DateTime) -> DateTime {
  DateTime::{
    year: dt.year,
    month: dt.month,
    day: 1,
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
  }
}

pub fn end_of_month(dt: DateTime) -> DateTime {
  let last_day = days_in_month(dt.year, dt.month)
  DateTime::{
    year: dt.year,
    month: dt.month,
    day: last_day,
    hour: 23,
    minute: 59,
    second: 59,
    millisecond: 999,
  }
}

pub fn start_of_year(dt: DateTime) -> DateTime {
  DateTime::{
    year: dt.year,
    month: 1,
    day: 1,
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
  }
}

pub fn end_of_year(dt: DateTime) -> DateTime {
  DateTime::{
    year: dt.year,
    month: 12,
    day: 31,
    hour: 23,
    minute: 59,
    second: 59,
    millisecond: 999,
  }
}

pub fn is_same_day(dt1: DateTime, dt2: DateTime) -> Bool {
  dt1.year == dt2.year && dt1.month == dt2.month && dt1.day == dt2.day
}

pub fn is_same_month(dt1: DateTime, dt2: DateTime) -> Bool {
  dt1.year == dt2.year && dt1.month == dt2.month
}

pub fn is_same_year(dt1: DateTime, dt2: DateTime) -> Bool {
  dt1.year == dt2.year
}

pub fn is_weekend(dt: DateTime) -> Bool {
  let dow = day_of_week(dt)
  dow == 0 || dow == 6
}

pub fn is_weekday(dt: DateTime) -> Bool {
  not is_weekend(dt)
}

pub fn is_before(dt1: DateTime, dt2: DateTime) -> Bool {
  if dt1.year != dt2.year {
    return dt1.year < dt2.year
  }
  if dt1.month != dt2.month {
    return dt1.month < dt2.month
  }
  if dt1.day != dt2.day {
    return dt1.day < dt2.day
  }
  if dt1.hour != dt2.hour {
    return dt1.hour < dt2.hour
  }
  if dt1.minute != dt2.minute {
    return dt1.minute < dt2.minute
  }
  if dt1.second != dt2.second {
    return dt1.second < dt2.second
  }
  dt1.millisecond < dt2.millisecond
}

pub fn is_after(dt1: DateTime, dt2: DateTime) -> Bool {
  is_before(dt2, dt1)
}

pub fn min_datetime(dt1: DateTime, dt2: DateTime) -> DateTime {
  if is_before(dt1, dt2) {
    dt1
  } else {
    dt2
  }
}

pub fn max_datetime(dt1: DateTime, dt2: DateTime) -> DateTime {
  if is_after(dt1, dt2) {
    dt1
  } else {
    dt2
  }
}

pub fn clamp_datetime(dt: DateTime, min_dt: DateTime, max_dt: DateTime) -> DateTime {
  if is_before(dt, min_dt) {
    min_dt
  } else if is_after(dt, max_dt) {
    max_dt
  } else {
    dt
  }
}

fn string_to_int(s: String) -> Int? {
  if s.length() == 0 {
    return None
  }
  let mut result = 0
  let mut i = 0
  let bytes = s.to_bytes()
  let negative = bytes[0] == '-'.to_int()
  if negative {
    i = 1
  }
  while i < bytes.length() {
    let c = bytes[i]
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

fn pad_left(s: String, length: Int, char: Char) -> String {
  let len = s.length()
  if len >= length {
    return s
  }
  let result = StringBuilder::new()
  let mut i = 0
  while i < length - len {
    result.write_char(char)
    i = i + 1
  }
  result.write_string(s)
  result.to_string()
}

fn replace(s: String, old: String, new: String) -> String {
  if old.length() == 0 {
    return s
  }
  let result = StringBuilder::new()
  let mut i = 0
  while i < s.length() {
    if i <= s.length() - old.length() && s.substring(i, old.length()) == old {
      result.write_string(new)
      i = i + old.length()
    } else {
      result.write_char(s[i])
      i = i + 1
    }
  }
  result.to_string()
}

fn index_of(s: String, substr: String) -> Int? {
  if substr.length() == 0 {
    return Some(0)
  }
  if substr.length() > s.length() {
    return None
  }
  let mut i = 0
  while i <= s.length() - substr.length() {
    if s.substring(i, substr.length()) == substr {
      return Some(i)
    }
    i = i + 1
  }
  None
}
