# Upstream Fix

When an agent does something wrong, the durable fix lives in an upstream artifact (spec, ADR, validation surface, agent file), not in the prompt that produced the wrong output. Prompt patches that mask a symptom without reconciling the upstream contradiction are leaks; they accumulate and degrade the framework over time.

## Classification

Three categories, each pointing at one upstream artifact:

| Category | When | Upstream artifact | Spec Evolution Log trigger |
|---|---|---|---|
| `failure (spec)` | Agent did the wrong thing because the spec was silent, ambiguous, or did not bound scope correctly | `spec.md`, ADR, glossary, or Non-Scope section | `failure (spec)` |
| `failure (validation)` | The spec required the right behavior but conformance criteria, tests, or quality-gate rubric did not catch the miss | Conformance criteria, tests, or rubric file | `failure (validation)` |
| `failure (agent)` | Agent body, composition declaration, tool config, or coordination contract was misaligned with the spec | Agent file (body or `agents:` frontmatter), composition declaration, MCP/tool config, or handoff | `failure (agent)` |

Selection test: **Was the expected behavior already required by a normative obligation in the artifact stack?** If no, the failure is `spec`. If yes but the validation surface did not check it, the failure is `validation`. If yes and the validation surface would have caught it but the agent did not reach validation (skipped a step, acted out of role, invoked the wrong sub-agent), the failure is `agent`.

## Worked example

**Symptom**: A consumer's feature spec described a "user signup" flow but did not state what should happen when the email field is empty. The implementation agent generated code that silently accepted empty emails and created accounts with `null` in the `email` column. A downstream service then crashed when it tried to send a welcome email.

**Misclassification trap**: This looks like `failure (validation)` — the test suite did not catch it. It is not. The test suite could not catch behavior the spec did not require. The downstream artifact (test) cannot be expected to cover behavior the upstream artifact (spec) did not specify.

**Classification**: `failure (spec)`.

**Upstream artifact**: `spec.md`. Add a conformance case `CC-005` with input `email=""` and expected output "validation error, account not created". Add a corresponding invariant if appropriate (`accounts.email` is never null when state is `active`).

**Wrong fix (prompt patch)**: telling the implementation agent in its body "always validate email is non-empty before creating an account." Works for this session, not for the next consumer using the plugin without the prompt update.

**Spec Evolution Log row**: `1.1 | YYYY-MM-DD | Added CC-005 (empty email) and invariant on accounts.email | failure (spec) | <author>`.
