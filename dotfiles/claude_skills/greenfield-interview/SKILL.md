---
name: greenfield-interview
description: Use when starting a new project (app, game, tool, library), scaffolding a repo, or building a large feature with no existing code to follow. Interviews the user about what they're building and how, turns vague ideas into concrete requirements, raises objections, and maps future features so the design leaves room for them.
---

# Greenfield interview

The user's requirements usually start vague, and they rely on your questions to work out what they want. Treat the interview as design work, not a checklist before the real work starts. A project with no existing code has no conventions to copy, so the user's answers are the only source. Early guesses are expensive to undo once code builds on them.

Spend most of the interview on **what the thing is and does**. The tech stack follows from the features, so features come first.

## 1. What is it?

Start open-ended, and turn what you hear into something concrete:

- **The core experience.** What does using it feel like, minute to minute? For a game: the core loop, what the player does most of the time, and why it's fun. For a tool: the task it replaces and what's painful about the current way.
- **References.** Which existing games, apps or tools is it like, and what should it do differently from them? This is often the fastest way to pin down a vague idea.
- **Who it's for.** Just the user, friends, the public? This changes polish, distribution and how much configuration is needed.
- **Walk through a session.** Ask the user to describe one session from launch to quit, or describe one yourself and ask what's wrong with it. Concrete scenarios expose gaps that abstract questions miss.

When an answer is vague, don't accept it as-is. Propose two or three concrete interpretations and ask which one is meant. "Crafting" could mean a recipe book, freeform combining, or factory-style automation, and each is a different game.

## 2. Where is it going?

Ask about features beyond the first version, even ones the user isn't sure about. The goal is to know what the design must leave room for, not to build it now.

- **The roadmap.** What should v1 do, what might come later, and what will it never do?
- **Architecture-shaping features.** Probe these early even if they're far off, because retrofitting them is painful: multiplayer or networking, save/load and save compatibility, undo, modding or plugins, scripting, localization, multiple platforms, sync between devices, procedural vs hand-made content.
- **Scale.** How big does it get? Ten levels or a thousand, one user or many, a weekend project or years of work?

If a future feature would change the architecture, say so and ask whether to design for it now.

## 3. Push back

Raise concerns as you hear them, not only when asked. The user wants a collaborator with opinions.

- **Scope.** If v1 is too big to finish, say which parts to cut or defer and why.
- **Design problems.** Mechanics that work against each other, a loop with no reason to keep playing, a feature that makes another one pointless, an exploit, a tedious flow.
- **Contradictions.** If two answers conflict, or an answer conflicts with the stated goal, point it out.
- **Missing pieces.** Edge cases and unglamorous parts the user hasn't mentioned: onboarding, failure states, what happens when the player is stuck, empty states, error handling, settings.
- **Better ideas.** If you think a different approach serves the goal better, pitch it.

Disagree once, clearly, with a reason, then go with the user's decision.

## 4. How is it built?

Once the features are clear, cover the technical decisions, driven by what came up above:

- Language, engine or framework, and why it fits these features.
- Data model, persistence, and process model (CLI, daemon, web service, library).
- Repo layout, config format, error handling, logging.
- Tooling: dev environment (Nix flake devshell?), tests, lints, CI, packaging, license.

Skip anything already answered by the request, the user's CLAUDE.md files, memory, or their other projects. Check those first.

## How to ask

- Mix tools: use `AskUserQuestion` (up to 4 questions per round) for choices between concrete options, and plain questions in chat for open-ended ones like "what should this feel like?" Most feature questions are open-ended at first.
- **Lead with a recommendation.** For multiple-choice questions, put your pick first, marked "(Recommended)", with a one-line reason. For open questions, offer your own take for the user to react to.
- **Make options concrete.** "Turn-based, one action per turn" beats "a combat system". Use `preview` for competing layouts, mechanics, API shapes or config.
- **Explain consequences.** "Lets players share levels, but needs a stable save format from day one" says more than naming the feature.
- **Go in rounds.** Several rounds are normal and expected. Ask follow-ups when an answer opens new questions, and summarize what's settled every round or two so the user can correct it.
- **Know when to stop.** Stop once v1 is concrete enough to build and the architecture-shaping questions are answered. Leave small details to implementation.

## During implementation

Keep asking at real forks: a mechanic that turns out not to work, a feature interaction nobody anticipated, a new dependency, a public API, a schema, a naming scheme that will spread. Batch small questions instead of interrupting for each one. Where there's an obvious conventional answer, pick it and mention it.

## Record the decisions

Once the interview settles, write the outcome into the project's `CLAUDE.md` (create it if needed): what the project is, the v1 scope, planned and possible future features the design accounts for, non-goals, and the technical decisions with their reasons. Later sessions follow it without asking again. Record the decisions, not the conversation.
