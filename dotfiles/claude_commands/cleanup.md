---
description: Review code for cleanup opportunities — idiomatic patterns, docs, method ordering
allowed-tools: Read, Glob, Grep, Edit, Bash, Agent
---

Review the code in the current repository (or the changed files if on a branch/PR) for cleanup opportunities. Apply fixes directly.

## General

- Fix misleading, incorrect, or stale docs and comments. Remove comments that merely restate the code.
- Remove dead code and unused imports.
- Simplify overly complex or roundabout expressions.
- Ensure consistent naming conventions throughout.
- **Method ordering**: group related methods together. Within each group order: public API → private helpers → deeply-nested helpers. Functions should be defined *before* the functions they call (callers first, callees deeper). Match any ordering pattern already established in the file.

## Rust

Beyond the general rules, apply these Rust-specific improvements:

### Types & ownership
- `Box<str>` (or `Box<[T]>`, `Box<Path>`, …) over `String`/`Vec<T>`/`PathBuf` when the value is never mutated after creation.
- `Cow<'_, str>` (or `Cow<'_, T>`) when a function only *sometimes* needs to allocate.
- `&str` over `&String`, `&[T]` over `&Vec<T>`, `&Path` over `&PathBuf` in function parameters.
- Prefer `impl AsRef<str>` / `impl Into<String>` in public API boundaries where it improves ergonomics.
- Avoid unnecessary `.clone()` — prefer borrowing or restructuring to remove the need.

### Idiomatic patterns
- Use `From`/`Into` conversions instead of manual field-by-field construction where a standard conversion exists.
- Prefer `Option::map` / `and_then` / `unwrap_or_else` over `match` / `if let` when the result is cleaner.
- Prefer iterator chains over manual `for` loops when the intent is clearer (but don't force it when a loop reads better).
- Use `#[must_use]` on pure functions that return a value.
- Prefer `impl Trait` in argument position where it simplifies generic bounds without hurting readability.

### After changes
- Run `cargo clippy` and fix any new warnings.
- Run the project's test suite (scoped to affected code where possible) and fix any regressions.
