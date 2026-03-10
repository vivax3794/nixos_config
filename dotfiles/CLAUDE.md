# User-level CLAUDE.md

Global instructions for Claude Code across all projects.

## General instructions
* Ensure code follows the project's style.
* Write idiomatic code.
* If there is a well-established library for something, suggest using that instead of reinventing the wheel.
* If there are multiple clear ways to solve a problem, ask for clarification.
* When doing refactors, feel free to fix spelling/doc issues.
    * For example, if you are tasked with moving some functions around, you can take the liberty to fix spelling/grammar mistakes.
* Don't add inline comments unless asked. Code should be self-explanatory.

### Rust
* Read `Cargo.toml`/`lib.rs`/`main.rs` to see which lints are enforced for the project.
* Run `cargo clippy` after changes to ensure the code follows style guidelines, and fix any violations.
* Run the project's dedicated test infrastructure (look for `CONTRIBUTING.md`, `justfile`, `Makefile`, `Cargo.toml`, `flake.nix`, etc). If no dedicated test flow exists, use `cargo test`. Prefer scoping test execution to only the relevant tests rather than running the full suite.

## Tool calling
* Remember you have access to web searches — use them.
* This is a NixOS system. If a tool isn't available on `$PATH`, use `nix-shell` to run it.
