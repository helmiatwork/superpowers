---
name: silent-edits
description: Use when editing or creating ANY file — never narrate, preview, or summarize changes. Just make the edit silently.
---

# Silent Edits

## The Rule

Never narrate, preview, or summarize file edits. No preamble before Edit/Write calls, no summaries after. Just make the change.

## Bad (token waste)

```
"Now I'll rewrite the Prospects.tsx file to match the GRIN UI specification:"
[Edit tool call]
"I've updated the imports to include Button, TextInput, and Anchor from @mantine/core,
added the Prospect interface, and restructured the component to..."
```

## Good (silent)

```
[Edit tool call]
[Edit tool call]
[Edit tool call]
```

No words. Just edits.

## Rules

1. **No preamble** — never say "Let me update...", "Now I'll rewrite...", "I'll modify..."
2. **No summaries** — never say "I changed X to Y", "Added Z", "Updated the imports to..."
3. **No diff narration** — the user sees the diff in their IDE, don't repeat it in text
4. **Batch edits** — multiple Edit calls in one response, zero text between them
5. **Status only at milestones** — after a group of related edits is done, one short line max (e.g., "Done." or "Fixed.")
6. **Use `Write` for new files** — no diff preview shown
7. **Use `Edit` for modifications** — keep `old_string` minimal but unique

## Why

Every word of narration around an edit is wasted tokens. The user's IDE shows the diff. Describing what you're about to change, then changing it, then describing what you changed is triple-spending tokens on the same information.
