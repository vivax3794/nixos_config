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

#### Comment/doc style
In Claude Code you are editing the real codebase in place, as a maintainer who lives in this repo — not answering a web chat and not handing a learner a snippet to transcribe. So drop the tutorial voice: no annotating what changed, what to watch out for, or what the code *isn't*. That framing assumes a handoff that never happens here — the edit just lands.

Write every comment and doc for a future reader who has never seen this chat. If a comment only makes sense as a reply to something that happened in our conversation, it does not belong in the code.
* Never reference the chat, the edit, or the change itself. No "now uses X", "changed from Y to Z", "as requested", "updated to handle ...". Git/jj history records changes; the code describes the present.
* Never write comments that argue against a misunderstanding — the contrastive "X works like A, not B" / "note: this is NOT the Z you'd expect" framing. That's you resolving your own confusion out loud. If you were confused, fix your understanding; don't leave a rebuttal in the code where a reader who was never confused now has to parse it.
* When a comment is genuinely warranted, explain *why* something non-obvious is done (constraint, gotcha, external requirement), never narrate *what* the line plainly already says.
* State things affirmatively about how the code is, not defensively about how it isn't.

### Research
* Prefer web searches over inspecting local package installs.
* If you get stuck doing many deep dives into the local package index to verify code exsists, just write the code and see if it compiles. You know whats faster than grepping for a method in a crates source? `cargo check`

### Rust
* Read `Cargo.toml`/`lib.rs`/`main.rs` to see which lints are enforced for the project.
* Run `cargo clippy` after changes to ensure the code follows style guidelines, and fix any violations.
* Run the project's dedicated test infrastructure (look for `CONTRIBUTING.md`, `justfile`, `Makefile`, `Cargo.toml`, `flake.nix`, etc). If no dedicated test flow exists, use `cargo test`. Prefer scoping test execution to only the relevant tests rather than running the full suite.

## Tool calling
* Remember you have access to web searches — use them.
* This is a NixOS system. If a tool isn't available on `$PATH`, use `nix-shell` to run it.
* I use `jj` not `git` for 99% of repos, so prefer its commands over git.
