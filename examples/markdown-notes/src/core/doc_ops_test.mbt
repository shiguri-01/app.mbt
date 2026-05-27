///|
test "file_name handles common paths" {
  assert_eq(@core.file_name(None), "Untitled.md")
  assert_eq(@core.file_name(Some("C:\\notes\\daily.md")), "daily.md")
  assert_eq(@core.file_name(Some("/tmp/readme.md")), "readme.md")
}

///|
test "add_recent moves existing path to front and limits" {
  assert_true(
    @core.add_recent(["a.md", "b.md", "c.md"], "b.md", limit=3) ==
    ["b.md", "a.md", "c.md"],
  )
  assert_true(
    @core.add_recent(["a.md", "b.md", "c.md"], "d.md", limit=3) ==
    ["d.md", "a.md", "b.md"],
  )
}
