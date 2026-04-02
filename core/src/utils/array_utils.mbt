package moonflow_core::utils

pub fn is_empty[T](arr: Array[T]) -> Bool {
  arr.length() == 0
}

pub fn is_not_empty[T](arr: Array[T]) -> Bool {
  arr.length() > 0
}

pub fn first[T](arr: Array[T]) -> T? {
  if arr.length() == 0 {
    None
  } else {
    Some(arr[0])
  }
}

pub fn last[T](arr: Array[T]) -> T? {
  let len = arr.length()
  if len == 0 {
    None
  } else {
    Some(arr[len - 1])
  }
}

pub fn head[T](arr: Array[T]) -> Array[T] {
  if arr.length() <= 1 {
    []
  } else {
    arr.substring(0, arr.length() - 1)
  }
}

pub fn tail[T](arr: Array[T]) -> Array[T] {
  if arr.length() <= 1 {
    []
  } else {
    arr.substring(1, arr.length() - 1)
  }
}

pub fn init[T](arr: Array[T]) -> Array[T] {
  head(arr)
}

pub fn append[T](arr: Array[T], item: T) -> Array[T] {
  let result = arr.to_array()
  result.push(item)
  result
}

pub fn prepend[T](arr: Array[T], item: T) -> Array[T] {
  let result: Array[T] = []
  result.push(item)
  for item2 in arr {
    result.push(item2)
  }
  result
}

pub fn concat[T](arr1: Array[T], arr2: Array[T]) -> Array[T] {
  let result = arr1.to_array()
  for item in arr2 {
    result.push(item)
  }
  result
}

pub fn flatten[T](arr: Array[Array[T]]) -> Array[T] {
  let result: Array[T] = []
  for inner in arr {
    for item in inner {
      result.push(item)
    }
  }
  result
}

pub fn flatten_map[T, U](arr: Array[T], f: (T) -> Array[U]) -> Array[U] {
  let result: Array[U] = []
  for item in arr {
    let mapped = f(item)
    for mapped_item in mapped {
      result.push(mapped_item)
    }
  }
  result
}

pub fn reverse[T](arr: Array[T]) -> Array[T] {
  let len = arr.length()
  let result: Array[T] = []
  let mut i = len - 1
  while i >= 0 {
    result.push(arr[i])
    i = i - 1
  }
  result
}

pub fn unique[T](arr: Array[T]) -> Array[T] {
  let result: Array[T] = []
  for item in arr {
    let mut found = false
    for existing in result {
      if existing == item {
        found = true
        break
      }
    }
    if not found {
      result.push(item)
    }
  }
  result
}

pub fn deduplicate[T](arr: Array[T]) -> Array[T] {
  unique(arr)
}

pub fn chunk[T](arr: Array[T], size: Int) -> Array[Array[T]] {
  if size <= 0 {
    return []
  }
  let result: Array[Array[T]] = []
  let mut i = 0
  while i < arr.length() {
    let end = if i + size > arr.length() { arr.length() } else { i + size }
    result.push(arr.substring(i, end - i))
    i = i + size
  }
  result
}

pub fn group_by[T, K](arr: Array[T], key_fn: (T) -> K) -> Map[K, Array[T]] {
  let result: Map[K, Array[T]] = {}
  for item in arr {
    let key = key_fn(item)
    match result[key] {
      Some(existing) => existing.push(item)
      None => {
        let new_arr: Array[T] = [item]
        result[key] = new_arr
      }
    }
  }
  result
}

pub fn count_by[T](arr: Array[T], pred: (T) -> Bool) -> Int {
  let mut count = 0
  for item in arr {
    if pred(item) {
      count = count + 1
    }
  }
  count
}

pub fn filter_map[T, U](arr: Array[T], f: (T) -> U?) -> Array[U] {
  let result: Array[U] = []
  for item in arr {
    let mapped = f(item)
    match mapped {
      Some(value) => result.push(value)
      None => ()
    }
  }
  result
}

pub fn partition[T](arr: Array[T], pred: (T) -> Bool) -> (Array[T], Array[T]) {
  let left: Array[T] = []
  let right: Array[T] = []
  for item in arr {
    if pred(item) {
      left.push(item)
    } else {
      right.push(item)
    }
  }
  (left, right)
}

pub fn intersperse[T](arr: Array[T], separator: T) -> Array[T] {
  if arr.length() <= 1 {
    return arr.to_array()
  }
  let result: Array[T] = []
  let mut i = 0
  while i < arr.length() {
    if i > 0 {
      result.push(separator)
    }
    result.push(arr[i])
    i = i + 1
  }
  result
}

pub fn intercalate[T](arr: Array[Array[T]], separator: Array[T]) -> Array[T] {
  if arr.length() == 0 {
    return []
  }
  let result: Array[T] = []
  let mut i = 0
  while i < arr.length() {
    if i > 0 {
      for sep_item in separator {
        result.push(sep_item)
      }
    }
    for item in arr[i] {
      result.push(item)
    }
    i = i + 1
  }
  result
}

pub fn take[T](arr: Array[T], n: Int) -> Array[T] {
  if n <= 0 {
    return []
  }
  if n >= arr.length() {
    return arr.to_array()
  }
  arr.substring(0, n)
}

pub fn drop[T](arr: Array[T], n: Int) -> Array[T] {
  if n <= 0 {
    return arr.to_array()
  }
  if n >= arr.length() {
    return []
  }
  arr.substring(n, arr.length() - n)
}

pub fn take_while[T](arr: Array[T], pred: (T) -> Bool) -> Array[T] {
  let result: Array[T] = []
  for item in arr {
    if pred(item) {
      result.push(item)
    } else {
      break
    }
  }
  result
}

pub fn drop_while[T](arr: Array[T], pred: (T) -> Bool) -> Array[T] {
  let mut i = 0
  while i < arr.length() && pred(arr[i]) {
    i = i + 1
  }
  if i >= arr.length() {
    return []
  }
  arr.substring(i, arr.length() - i)
}

pub fn zip[T1, T2](arr1: Array[T1], arr2: Array[T2]) -> Array[(T1, T2)] {
  let min_len = if arr1.length() < arr2.length() { arr1.length() } else { arr2.length() }
  let result: Array[(T1, T2)] = []
  let mut i = 0
  while i < min_len {
    result.push((arr1[i], arr2[i]))
    i = i + 1
  }
  result
}

pub fn zip_with[T1, T2, U](arr1: Array[T1], arr2: Array[T2], f: (T1, T2) -> U) -> Array[U] {
  let min_len = if arr1.length() < arr2.length() { arr1.length() } else { arr2.length() }
  let result: Array[U] = []
  let mut i = 0
  while i < min_len {
    result.push(f(arr1[i], arr2[i]))
    i = i + 1
  }
  result
}

pub fn unzip[T1, T2](arr: Array[(T1, T2)]) -> (Array[T1], Array[T2]) {
  let arr1: Array[T1] = []
  let arr2: Array[T2] = []
  for (a, b) in arr {
    arr1.push(a)
    arr2.push(b)
  }
  (arr1, arr2)
}

pub fn all[T](arr: Array[T], pred: (T) -> Bool) -> Bool {
  for item in arr {
    if not pred(item) {
      return false
    }
  }
  true
}

pub fn any[T](arr: Array[T], pred: (T) -> Bool) -> Bool {
  for item in arr {
    if pred(item) {
      return true
    }
  }
  false
}

pub fn none[T](arr: Array[T], pred: (T) -> Bool) -> Bool {
  not any(arr, pred)
}

pub fn sum(arr: Array[Int]) -> Int {
  let mut total = 0
  for item in arr {
    total = total + item
  }
  total
}

pub fn product(arr: Array[Int]) -> Int {
  if arr.length() == 0 {
    return 0
  }
  let mut total = 1
  for item in arr {
    total = total * item
  }
  total
}

pub fn sum_float(arr: Array[Double]) -> Double {
  let mut total = 0.0
  for item in arr {
    total = total + item
  }
  total
}

pub fn product_float(arr: Array[Double]) -> Double {
  if arr.length() == 0 {
    return 0.0
  }
  let mut total = 1.0
  for item in arr {
    total = total * item
  }
  total
}

pub fn minimum(arr: Array[Int]) -> Int? {
  if arr.length() == 0 {
    return None
  }
  let mut min_val = arr[0]
  let mut i = 1
  while i < arr.length() {
    if arr[i] < min_val {
      min_val = arr[i]
    }
    i = i + 1
  }
  Some(min_val)
}

pub fn maximum(arr: Array[Int]) -> Int? {
  if arr.length() == 0 {
    return None
  }
  let mut max_val = arr[0]
  let mut i = 1
  while i < arr.length() {
    if arr[i] > max_val {
      max_val = arr[i]
    }
    i = i + 1
  }
  Some(max_val)
}

pub fn minimum_by[T](arr: Array[T], cmp: (T, T) -> Int) -> T? {
  if arr.length() == 0 {
    return None
  }
  let mut min_val = arr[0]
  let mut i = 1
  while i < arr.length() {
    if cmp(arr[i], min_val) < 0 {
      min_val = arr[i]
    }
    i = i + 1
  }
  Some(min_val)
}

pub fn maximum_by[T](arr: Array[T], cmp: (T, T) -> Int) -> T? {
  if arr.length() == 0 {
    return None
  }
  let mut max_val = arr[0]
  let mut i = 1
  while i < arr.length() {
    if cmp(arr[i], max_val) > 0 {
      max_val = arr[i]
    }
    i = i + 1
  }
  Some(max_val)
}

pub fn sort[T](arr: Array[T], cmp: (T, T) -> Int) -> Array[T] {
  let result = arr.to_array()
  bubble_sort(result, cmp)
  result
}

fn bubble_sort[T](arr: Array[T], cmp: (T, T) -> Int) -> Unit {
  let n = arr.length()
  let mut i = 0
  while i < n - 1 {
    let mut j = 0
    while j < n - i - 1 {
      if cmp(arr[j], arr[j + 1]) > 0 {
        let temp = arr[j]
        arr[j] = arr[j + 1]
        arr[j + 1] = temp
      }
      j = j + 1
    }
    i = i + 1
  }
}

pub fn find[T](arr: Array[T], pred: (T) -> Bool) -> T? {
  for item in arr {
    if pred(item) {
      return Some(item)
    }
  }
  None
}

pub fn find_index[T](arr: Array[T], pred: (T) -> Bool) -> Int? {
  let mut i = 0
  while i < arr.length() {
    if pred(arr[i]) {
      return Some(i)
    }
    i = i + 1
  }
  None
}

pub fn contains_elem[T](arr: Array[T], item: T) -> Bool {
  find(arr, fn(x) -> Bool { x == item }).is_some()
}

pub fn elem_index[T](arr: Array[T], item: T) -> Int? {
  find_index(arr, fn(x) -> Bool { x == item })
}

pub fn remove[T](arr: Array[T], index: Int) -> Array[T] {
  if index < 0 || index >= arr.length() {
    return arr.to_array()
  }
  let result: Array[T] = []
  let mut i = 0
  while i < arr.length() {
    if i != index {
      result.push(arr[i])
    }
    i = i + 1
  }
  result
}

pub fn update[T](arr: Array[T], index: Int, value: T) -> Array[T] {
  if index < 0 || index >= arr.length() {
    return arr.to_array()
  }
  let result = arr.to_array()
  result[index] = value
  result
}

pub fn insert[T](arr: Array[T], index: Int, value: T) -> Array[T] {
  if index < 0 || index > arr.length() {
    return arr.to_array()
  }
  let result: Array[T] = []
  let mut i = 0
  while i < arr.length() {
    if i == index {
      result.push(value)
    }
    result.push(arr[i])
    i = i + 1
  }
  if index >= arr.length() {
    result.push(value)
  }
  result
}

pub fn range(start: Int, end: Int, step: Int) -> Array[Int] {
  if step == 0 {
    return []
  }
  let result: Array[Int] = []
  if step > 0 {
    let mut i = start
    while i < end {
      result.push(i)
      i = i + step
    }
  } else {
    let mut i = start
    while i > end {
      result.push(i)
      i = i + step
    }
  }
  result
}

pub fn range_inclusive(start: Int, end: Int, step: Int) -> Array[Int] {
  if step == 0 {
    return []
  }
  let result: Array[Int] = []
  if step > 0 {
    let mut i = start
    while i <= end {
      result.push(i)
      i = i + step
    }
  } else {
    let mut i = start
    while i >= end {
      result.push(i)
      i = i + step
    }
  }
  result
}

pub fn replicate[T](item: T, count: Int) -> Array[T] {
  let result: Array[T] = []
  let mut i = 0
  while i < count {
    result.push(item)
    i = i + 1
  }
  result
}

pub fn cycle[T](arr: Array[T]) -> Array[T] {
  arr
}

pub fn lookup[K, V](arr: Array[(K, V)], key: K) -> V? {
  for (k, v) in arr {
    if k == key {
      return Some(v)
    }
  }
  None
}

pub fn from_list[T](list: List[T]) -> Array[T] {
  let result: Array[T] = []
  let mut current = Some(list)
  while current.is_some() {
    match current {
      Some(Cons(head, tail)) => {
        result.push(head)
        current = Some(tail)
      }
      Some(Nil) => break
      None => break
    }
  }
  result
}

pub fn to_list[T](arr: Array[T]) -> List[T] {
  let mut result: List[T] = Nil
  let mut i = arr.length() - 1
  while i >= 0 {
    result = Cons(arr[i], result)
    i = i - 1
  }
  result
}
