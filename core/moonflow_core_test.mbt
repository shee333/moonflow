test "core: simple assertion test" {
  inspect(1 + 1, content="2")
}

test "core: string operations" {
  let s = "Hello, MoonFlow!"
  inspect(s.length(), content="16")
}
