///|
test "async driver completes timer-backed response" {
  let response : @ipc.IpcResponse[Int] = run_response(() => {
    @async.sleep(1)
    Ok(42)
  })
  match response {
    Ok(value) => assert_eq(value, 42)
    Err(err) => fail(err.to_json().stringify())
  }
}
