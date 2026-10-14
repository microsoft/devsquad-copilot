---
description: "Use the interactive chat UI (vscode_askQuestions) for option menus, checkpoints, and next-phase suggestions, instead of printing options as text like [A]/[B]/[C] or [C]/[R]/[O]/[P]."
applyTo: '**'
---
# Interactive prompts (radio / checkbox)
Whenever you present **discrete options** for the user to choose from, use the
`vscode_askQuestions` tool (the same native chat UI) instead of printing the options as text.
## When to use
Use `vscode_askQuestions` for:
- Choice menus with letters/numbers — e.g. `[A]/[B]/[C]`, `[C] Continue [R] Review [O] Other phase [P] Pause`, "Next:".
- Phase transitions and `[CHECKPOINT]` / `[DONE]` actions that ask for confirmation or the next step.
- `[ASK]` questions with fixed alternatives or `NEEDS CLARIFICATION` markers with defined options.
- Any question where you would currently ask the user to "type one of the options".
**Do not** print the options with letters (`[C]/[R]/[O]/[P]`) as markdown when the tool is
available. Fall back to plain text only if the tool call fails or if the question is
narrative/open-ended (without discrete alternatives).
## How to configure
- **Radio (choose 1 option) + free text**: provide `options` and do **not** set `multiSelect`
  (single choice is the default). Keep `allowFreeformInput` at its default (`true`) so the user
  can type their own alternative in addition to the options.
- **Checkbox (choose multiple) + additional information**: set `multiSelect: true`. The free-text
  box (enabled by default) lets the user add details. Note: the chat does not expose a text field
  per item; the extra information is provided in a single field.
- **Default recommended option**: mark the preferred alternative with `recommended: true`.
- Use short labels (`label`) and put the details in `description`.
- Preserve the formatting and content of relayed questions (do not filter out `[ASK]`).
## Mapping example
The text menu:
```text
Next:
- [R] Review
- [O] Other phase
- [P] Pause
```
should become a `vscode_askQuestions` call with a single-choice question, three `options`
(`Review`, `Other phase`, `Pause`), `allowFreeformInput` enabled and, when it makes sense, the
most likely option marked with `recommended: true`.
