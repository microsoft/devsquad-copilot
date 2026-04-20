---
name: harness-learnings
description: "Capture and consult codebase-specific learnings across the lifecycle. Use when an agent encounters a correction loop, review finding, test prerequisite, or recurring pattern that future sessions should know about. Also use at the start of implement, verify, or review to check for known patterns. Do not use for architecture decisions (use ADRs), for debugging the current failure (use debugging-recovery), or for one-time context that will not recur."
---

# Harness Learnings

## Principle

Agent sessions are ephemeral. Codebase knowledge is not. When an agent discovers
a pattern through trial and error (failed tests, correction loops, review findings),
that knowledge should persist so the next session starts smarter.

## Operations

This skill has two modes: **capture** (write a learning) and **consult** (read
learnings relevant to the current task).

---

## 1. Capture: Record a Learning

### When to Capture

| Trigger | What to capture |
|---------|-----------------|
| Self-correction loop needed (test failure, lint failure) | Root cause, fix pattern, affected files |
| Max correction attempts (2) exhausted | What the agent could not self-correct and why |
| Build/lint/test prerequisite missed | Required setup step (seed scripts, env vars, build order) |
| Review finding classified Major or Critical | Anti-pattern detected, correct pattern for this codebase |
| Recurring drift detected by refine.health | What drifts and how to prevent it |
| Successful debugging triage of non-obvious issue | Root cause pattern, diagnostic path |
| Human PR feedback on preventable issue | What the human caught that the agent missed |

### When NOT to Capture

- Generic best practices already covered by `coding-guidelines.md` or `.instructions.md`
- One-time errors caused by typos, environment issues, or transient failures
- Learnings about the framework itself (report as issues instead)
- Context that only applies to a single task and will not recur
- Observations with no actionable guidance ("this was hard" is not a learning)

### Capture Procedure

1. Read `.memory/harness-learnings.md` (create from template if it does not exist)
2. **Deduplicate**: scan existing entries for overlap
   - Match criteria: overlapping `Scope` (shared file paths or modules) AND similar failure type
   - If match found: increment `Occurrences`, update `Last seen`, upgrade `Confidence` if warranted
   - If no match: append new entry with next sequential `L-NNN` ID
3. **Assign fields** for new entries:
   - `Phase`: the lifecycle phase where this learning is most relevant for **consumption** (not necessarily where it was captured). A review finding about missing error handling should have Phase = implement if the fix belongs at coding time.
   - `Dimension`: what it regulates (maintainability, architecture, behaviour)
   - `Scope`: concrete file paths, directories, or module names. Use glob patterns when appropriate (e.g., `src/api/**`, `*.controller.ts`). This is the primary field agents use to match learnings to their current task.
   - `Pattern`: factual description of what happened (the observation)
   - `Guidance`: actionable instruction for what to do differently (the prescription). Must include file paths, commands, or specific checks.
   - `Confidence`: low (first observation), medium (seen twice or confirmed by human), high (3+ occurrences or human-validated)
   - `Occurrences`: 1 for new entries
   - `First seen` / `Last seen`: current date (YYYY-MM-DD)
4. **Auto-prune** stale entries (see Hygiene section)
5. Write updated file

### Confidence Progression

```text
low ──[seen again]──> medium ──[seen again OR human-validated]──> high
```

Human validation (explicit confirmation or PR feedback) can jump to `medium` or `high` directly.

### Format

Each learning is a level-2 heading in `.memory/harness-learnings.md`:

```markdown
## L-NNN: [short descriptive title]

- Phase: [implement|verify|review|refine|debug|plan|specify]
- Dimension: [maintainability|architecture|behaviour]
- Scope: [file paths, module names, or glob patterns]
- Pattern: [factual description of what happened]
- Guidance: [actionable instruction for next time]
- Confidence: [low|medium|high]
- Occurrences: [N]
- First seen: [YYYY-MM-DD]
- Last seen: [YYYY-MM-DD]
```

### Example

```markdown
## L-003: Integration tests require database seed before running

- Phase: verify
- Dimension: maintainability
- Scope: tests/integration/**, scripts/db-seed.sh
- Pattern: Test suite failed because agent ran `npm test` without
  `npm run db:seed` first. Debugging took 3 self-correction attempts
  before discovering the prerequisite.
- Guidance: Before running the full test suite, execute
  `npm run db:seed` to populate test fixtures. The seed script is
  idempotent. Check `scripts/db-seed.sh` for the expected schema.
- Confidence: high
- Occurrences: 5
- First seen: 2026-02-20
- Last seen: 2026-04-19
```

---

## 2. Consult: Read Learnings Before Acting

### When to Consult

| Agent / Phase | Filter | How to use |
|---------------|--------|------------|
| `implement.execute` (before coding) | Scope overlaps with task files | Apply Guidance proactively to avoid known pitfalls |
| `implement.verify` (before tests) | Phase = verify, Scope overlaps | Check for known prerequisites (seeds, env vars) |
| `review.code` (before checking) | Scope overlaps with diff files | Check for known anti-patterns; elevate severity if matched |
| `plan` (during design) | Dimension = architecture | Anticipate known architectural constraints |
| `specify` (writing conformance cases) | Dimension = behaviour | Include known edge cases from past failures |

### Consult Procedure

1. Read `.memory/harness-learnings.md`
   - If file does not exist, skip (no learnings yet)
2. Filter entries by relevance (both filters apply):
   - `Scope` overlaps with the current task's files or modules (primary)
   - `Phase` matches the current lifecycle phase (secondary)
   - Either filter matching is sufficient to include the entry
3. Apply confidence-based signal strength:
   - `high`: strong signal, apply Guidance proactively
   - `medium`: recommendation, apply if applicable
   - `low`: note but do not change behavior (insufficient evidence)

### Context Cost Management

- Read the file header and `## L-NNN:` heading lines first (first 2-3 lines per entry) to identify relevant IDs by Scope and Phase
- Read full entries only for matching learnings
- If file exceeds 100 entries, skip entries with Confidence = low

---

## 3. Promotion to Permanent Harness Control

When a learning reaches **Confidence = high AND Occurrences >= 3**, suggest promotion:

| Dimension | Target mechanism |
|-----------|-----------------|
| Maintainability | Instruction rule (`.instructions.md`) or coding-guidelines |
| Architecture | ADR or architecture fitness check |
| Behaviour | Approved test fixture or test guard |
| Prerequisites | Hook script (sessionStart or postToolUse) |

Present the promotion to the developer:

```text
Learning L-NNN has been confirmed 3+ times with high confidence.
Consider promoting it to a permanent harness control:

- Current: .memory/harness-learnings.md (workspace-local)
- Suggested target: [specific file and content]
- Mechanism: [instruction rule | hook | skill amendment | ADR]

[P] Promote via devsquad.extend
[K] Keep as learning (do not promote yet)
[D] Dismiss (remove learning)
```

After promotion, add `Promoted: [target file]` to the entry. Do not remove it (audit trail).

---

## 4. Hygiene

Run on each **capture** operation:

- **Prune**: remove entries with Confidence = low AND Last seen > 60 days
- **Downgrade**: entries with Confidence = medium AND Last seen > 120 days become low
- **Conflict detection**: if the new learning has overlapping Scope AND opposite Guidance to an existing entry, flag `CONFLICT: may contradict L-NNN` instead of overwriting
- **Size cap**: if file exceeds 200 entries, remove all low-confidence entries older than 30 days, then suggest promotion for all high-confidence entries

---

## 5. File Management

When `.memory/harness-learnings.md` does not exist, create it with the header from `references/learning-template.md` in this skill's directory.

`.memory/` is typically gitignored (learnings are workspace-local). For teams that want shared learnings: commit the file (add a `.gitignore` exception) or rely on Tier 2 promotion to share durable patterns via instructions/hooks/skills.

---

## Anti-patterns

- Do not capture vague observations without actionable Guidance ("API is hard to use" provides no fix)
- Do not capture learnings that duplicate existing `.instructions.md` rules or `coding-guidelines.md`
- Do not set Confidence to high on first observation (it must be earned through recurrence)
- Do not skip deduplication: duplicate entries dilute signal and waste context
- Do not capture framework behavior as codebase learnings (report framework issues instead)
- Do not bloat Scope with `**/*` or other overly broad patterns; learnings with broad scope match everything and lose filtering value
