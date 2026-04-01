test "core: simple assertion test" {
  inspect(1 + 1, content="2")
}

test "core: string operations" {
  let s = "Hello, MoonFlow!"
  inspect(s.length(), content="16")
}

test "core: array operations" {
  let arr = [1, 2, 3, 4, 5]
  inspect(arr.length(), content="5")
}

test "core: map operations" {
  let map = { "key": "value", "name": "test" }
  inspect(map.length(), content="2")
}

test "core: string interpolation" {
  let name = "MoonFlow"
  let result = "Hello, \{name}!"
  inspect(result, content="Hello, MoonFlow!")
}
