# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

## Project Structure

- This repository is organized as a MoonBit workspace. The toplevel directory
  contains a `moon.work` file listing workspace members. Each member has its own
  `moon.mod` file listing module metadata.

- Treat each `moon.mod` member as the actual module boundary and publication
  unit. Public APIs and package import paths are scoped to the member module,
  not to the workspace as a whole.

- MoonBit packages are organized per directory; each directory contains a
  `moon.pkg` file listing its dependencies. Each package has its files and
  blackbox test files (ending in `_test.mbt`) and whitebox test files (ending in
  `_wbtest.mbt`).

## Coding convention

- MoonBit code is organized in block style, each block is separated by `///|`,
  the order of each block is irrelevant. In some refactorings, you can process
  block by block independently.

- Try to keep deprecated blocks in file called `deprecated.mbt` in each
  directory.

## Tooling

- Prefer commands defined in `justfile` when there is a matching recipe. These
  recipes encode this project's expected workspace scope and command
  environment. They are the project entry points for the underlying `moon`
  commands.

- `just fmt` is used to format your code properly.

- `just check` is used to type-check the workspace.

- `moon ide` provides project navigation helpers like `peek-def`, `outline`, and
  `find-references`. See $moonbit-agent-guide for details. Use `moon ide`
  directly when doing code navigation or a focused semantic refactoring.

- `just info` is used to update generated package interface files. Check
  `.mbti` diffs to see whether package public APIs changed.

- In the last step, run `just info && just fmt` to update the interface and
  format the code. Check the diffs of `.mbti` file to see if the changes are
  expected.

- Run `just test` to check tests pass. MoonBit supports snapshot testing; when
  changes affect outputs, run the appropriate `moon test --update` command to
  refresh snapshots.

- For quick, narrowly scoped iteration, it is fine to run `moon check`,
  `moon test`, or other `moon` commands directly against a specific package,
  file, filter, or target.

- Prefer `assert_eq` or `assert_true(pattern is Pattern(...))` for results that
  are stable or very unlikely to change. For snapshot tests that record
  structured debugging output, derive `Debug` and use `debug_inspect`, rather
  than deriving `Show` for debugging. For solid, well-defined results (e.g.
  scientific computations), prefer assertion tests. You can use
  `moon coverage analyze > uncovered.log` to see which parts of your code are
  not covered by tests.

## Commit messages

- Prefer short commit messages in the existing conventional style:
  `type: imperative summary`.

- Use `feat`, `fix`, `refactor`, `docs`, or `chore` as the type when one fits.
  Add a scope only when it helps, for example `fix(webview): ...`.
