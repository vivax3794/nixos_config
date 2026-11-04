---
name: writing-for-readers
description: Use when writing or editing code comments, docs, READMEs, commit messages, UI text, tooltips, tutorials or store copy. Keeps text written for its future reader instead of for the current conversation.
---

# Writing for readers

Text outlives the conversation that produced it. Write for someone who never saw the chat, has the code or UI in front of them, and wants to get something done.

## Keep the conversation out of the artifact

The most common failure is chat context leaking into files. Before writing, separate what the reader needs from what only made sense in this session.

Never put in comments, docs or UI text:

- **Justifications of your choices.** `// Using a HashMap for O(1) lookups` defends a decision to the reviewer. Reasons for a change go in the commit message or PR description.
- **Change narration.** `// Fixed: now handles empty input`, `// Updated to use the new API`. Meaningless to anyone who wasn't there.
- **Reassurance about fixed problems.** "Empties into the silo by itself", "won't overwrite your settings", "cars reroute around the banned turn". Describing the absence of a bug only makes sense to someone who saw the bug, and it plants the worry in everyone else.
- **Paths not taken.** Don't document that an approach doesn't work because it failed during implementation. It may have failed for an unrelated reason, so the comment can be false. Only warn against an approach if a competent reader would plausibly reach for it, and only if you know why it fails.
- **The change request in third person.** If the user asked for "make X an upgrade and start the player with a worse one", the description should not read as that diff.

Tell words to check for: *now, no longer, instead of, without having to, automatically, by itself, always, won't, don't worry*. Each one means something only relative to a previous state or a worry. Not every hit is wrong; most are worth a second look.

## Code comments

Comment only what the code can't say: invariants, non-obvious why, workarounds for external bugs (with a link if possible), and constraints that would be easy to violate. Don't restate what the code does. Don't docstring self-explanatory functions.

## Docs

- Order by what the reader needs at that moment, not by how the system works internally or the order things happen. The most important fact goes first, not at the end of a narrative.
- State facts so they can be scanned. "Outputs: 2, rear" beats a sentence describing belts carrying dust away.
- Use the reader's vocabulary, not the data model's. "Transactions your bank didn't list", not "covered by an export but not in it".
- Describe outcomes and decisions, not mechanisms. "Pick this if downloads broke and you want the fix early", not the state machine behind it.
- Exact numbers and limits are valuable. Prose descriptions of things the reader can see are not.

## UI text, tooltips and game text

- **If the user can observe it, it doesn't need text.** Text is for what's hidden: costs, limits, maxima, rules with delayed or ambiguous feedback. "Changing or removing is free" and "max six" earn their place. "Cars reroute" and "you start with one slot" don't.
- **Write for the moment it's read.** A build tooltip answers whether and where to place something: what it does, cost, anything affecting placement. Operating instructions belong where the thing is used.
- **Don't restate the label.** "Yield — gives way", "Edit phases — Build the phases yourself", "Reward for reaching a new stage" under a "Stage unlocked" header. An empty subtitle is better than a tautology. Not every slot needs filling.
- **Don't explain affordances.** If it looks clickable, don't say "click to edit".
- **Don't mention what the UI already enforces.** "Needs the tool" on an item that's hidden without the tool can only be read by people who have it.
- **The one sentence carrying a real rule must be unambiguous.** Reread it as someone who doesn't know the answer. "Holds the green while nobody is waiting" has three readings; "Skips roads with no cars waiting" has one.
- **Prefer UI over text** for numbers: a counter like "Tool Belt (1/6)" beats a sentence about slots.

## Style patterns to avoid

- **The fixed template.** Feature, then edge case or implementation detail, then use case, applied at every scale. Choose the shape from the content. Most things need one of those, and which one varies. Some need none.
- **Punchline closers.** A short aphoristic sentence ending every paragraph ("Staying online is the hard part."). Use it rarely, where it says something.
- **"Not X, but Y" contrasts** unless they correct a real, likely misconception.
- **Compression instead of selection.** Three facts in one sentence joined by colons, semicolons and dashes. Cut facts instead, or use two plain sentences.
- **Jargon from the implementation** ("forbidden movement", "spawn", "meters a side street") in player- or user-facing text.
- **Fake-casual voice** ("ride nightly") that doesn't match the surrounding text.
- **Uniform density.** If everything gets explained, nothing stands out. Most text should be bare; the rare surprising rule gets a sentence.

## Process

1. When writing user-facing text after implementing the feature, consciously drop implementation context. Better: write it in a separate pass from a description or screenshot of what the user sees, not from the code.
2. For each clause, ask: what would the reader get wrong without it? If nothing, cut it.
3. Do a deletion pass at the end. Good text is mostly what was left out.
