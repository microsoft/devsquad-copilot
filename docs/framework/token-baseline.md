# DevSquad Copilot: Token Usage Baseline

Estimation of GitHub Copilot token consumption when running the DevSquad framework end-to-end, so you can project the cost of adopting it. The baseline is expressed in tokens (which stay stable) and section 5 shows how to convert tokens to dollars or AI credits with your model's current rates. Use this as a planning baseline. Actual usage will vary with codebase size, model choice, retry loops, and how much context lives outside the framework.

## 1. Token-to-cost conversion

This document provides a **token usage baseline**, not a price list. Model pricing changes frequently and is intentionally omitted so the baseline stays accurate over time. To turn the token counts below into a dollar or AI-credit estimate, apply the method in section 5 using the per-token input and output rates of the model assigned to each agent, from the current "Models and pricing for GitHub Copilot" page in the GitHub docs.

Two model-dependent factors shape any cost calculation:

- **Output costs more than input.** On every model, output tokens are billed at a higher per-token rate than input tokens. The implement and generation phases skew output-heavy.
- **Cached input is much cheaper.** After the first turn in a session, the repeated prompt prefix is served from cache at up to 10x below the uncached input rate. Modern agentic harnesses keep cache hit rates high (around 94% on Anthropic models for agentic workloads), so most input on later turns bills at the cached rate. Extended prompt caching (up to 24h retention on supported OpenAI models) keeps the cache warm across pauses; only resumes after the retention window expires pay the full uncached rate again.

Code completions and Next Edit Suggestions remain unlimited and do not consume credits. For how the harness itself reduces token usage (prompt caching, tool search, sub-agents), see GitHub's writeup on [improving token efficiency in Copilot](https://code.visualstudio.com/blogs/2026/06/17/improving-token-efficiency-in-github-copilot).

Conversion used throughout: **1 token ≈ 4 characters** of English markdown/code.

## 2. Framework footprint

The full framework is roughly 125K tokens of static artifacts on disk (28 agents, 24 skills, path-specific instructions, distributed templates, and always-on instructions). The **entire framework is never loaded at once**: each phase invokes one coordinator agent, skills load just-in-time per their trigger description, and sub-agents run in isolated context windows that return summarized results. What matters for estimation is the per-phase static load below, not the on-disk total.

### Per-phase static load (system prompt the model sees on first turn)

| Phase | Coordinator | Sub-agents (isolated ctxs) | Skills auto-triggered | Root ctx framework tokens |
| --- | ---: | ---: | ---: | ---: |
| envision | 3.4K | — | — | **~3.4K** |
| kickoff | 2.9K | — | board-config (0.9K) | **~3.8K** |
| specify | 5.8K | — | deep-clarification, domain-glossary, quality-gate | **~13.3K** |
| plan | 6.1K | context, architecture, design (each ~0.6–0.9K, isolated) | adr-workflow, engineering-practices, diagram-design, quality-gate | **~17.0K** |
| decompose | 4.0K | — | work-item-creation, complexity-analysis, board-config | **~9.4K** |
| sprint | 5.9K | — | complexity-analysis, board-config | **~7.8K** |
| implement (per task) | 7.1K | validate, execute, verify, finalize (each isolated, ~1.0–2.4K) | test-discipline, git-commit, git-branch, debugging-recovery, harness-learnings, work-item-workflow, quality-gate, security-review (conditional), pull-request | **~7K root + ~9–15K per sub-agent ctx** |
| review | 4.0K | spec, code, adr, security, tests (isolated, ~0.4–1.4K each) | quality-gate, security-review | **~11K** |
| refine | 5.0K | artifacts, health (isolated) | adr-workflow, quality-gate | **~10K** |

Caching: after the first turn in a session, the coordinator agent prompt is served from cache at up to 10x below the uncached input price. Extended prompt caching (up to 24h retention on supported OpenAI models) keeps this warm across short pauses; only resumes after the cache-retention window pay the uncached price again.

## 3. Variable cost drivers (dominate the bill)

Framework prompts are a small fraction of real cost. The dominant terms are:

1. **Artifact re-reading between phases** (ADR-0003 explicitly trades tokens for isolation). Each phase reads spec, ADRs, related plans from disk: 5–30K input tokens per phase.
2. **Repository code reads during implement and review**: 20–200K tokens depending on familiarity and scope.
3. **Tool output ingestion**: test logs, build errors, lint output. Each failed test cycle adds 5–15K input tokens.
4. **Retry / debug loops**: a stuck implementation can multiply the per-task cost 3–5x.
5. **Generated output**: spec.md, plan.md, code edits, commit messages. Output tokens are billed at a higher per-token rate than input on every model.

## 4. Three reference scenarios

| Profile | Stories | Tasks per story | Total tasks | Code change |
| --- | ---: | ---: | ---: | --- |
| Small feature | 2 | 2 | 4 | ~200–500 LOC, well-scoped CRUD |
| Medium feature | 6 | 3 | 18 | ~1,500–3,000 LOC, new endpoint + integration |
| Large feature / migration | 18 | 3–4 | 60 | ~8,000+ LOC, cross-service, debug-heavy |

### Per-phase estimates (input + output tokens)

Token counts include all framework overhead, artifact reads, tool outputs, sub-agent calls, and produced artifacts.

| Phase | Small (tokens in/out) | Medium (tokens in/out) | Large (tokens in/out) |
| --- | --- | --- | --- |
| envision (one-time per product) | 15K / 3K | 15K / 3K | 15K / 3K |
| kickoff (one-time per product) | 20K / 4K | 25K / 5K | 40K / 8K |
| specify (per feature) | 30K / 5K | 60K / 10K | 120K / 20K |
| plan (per feature) | 50K / 8K | 120K / 15K | 250K / 30K |
| decompose (per feature) | 30K / 5K | 70K / 10K | 150K / 25K |
| sprint (per sprint, amortized) | 25K / 4K | 25K / 4K | 25K / 4K |
| implement (per task) | 80K / 15K | 200K / 35K | 500K / 80K |
| review (per feature) | 50K / 5K | 120K / 10K | 300K / 20K |
| refine (per run, weekly) | 50K / 5K | 50K / 5K | 50K / 5K |
| security (when triggered) | 30K / 5K | 60K / 8K | 100K / 12K |

### Total tokens per feature (planning + implement + review only)

| Profile | specify | plan | decompose | implement (sum) | review | **Per-feature total** |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Small (4 tasks) | 35K | 58K | 35K | 380K (4 × 95K) | 55K | **~563K** |
| Medium (18 tasks) | 70K | 135K | 80K | 4.23M (18 × 235K) | 130K | **~4.65M** |
| Large (60 tasks) | 140K | 280K | 175K | 34.8M (60 × 580K) | 320K | **~35.7M** |

Observation: **implementation phase consumes 70–98% of the feature budget**. Planning phases (specify/plan/decompose/review combined) are typically 5–25% of total spend.

## 5. Estimate your cost

The baseline stays in tokens so it never goes stale; you supply the one volatile input (your model's current per-token rate) at the moment you estimate.

### Method

1. Pick the token figure for your scope from section 4 (per feature) or section 6 (per month).
2. Look up your model's **input** and **output** rates (per 1M tokens) on the live [Models and pricing for GitHub Copilot](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing) page.
3. Apply:

```
USD        = (input_tokens_M * input_rate) + (output_tokens_M * output_rate)
AI credits = USD / credit_value
```

Where:

- `input_tokens_M` / `output_tokens_M`: token counts for your scope, expressed in millions (e.g. 4.65M tokens = `4.65`). Use the input/output split below.
- `input_rate` / `output_rate`: your model's price per 1M input and output tokens, from the live pricing page in step 2.
- `credit_value`: the USD value of one AI credit (1 AI credit = $0.01 at the time of writing). Confirm the current value on your billing page, as GitHub can change it.

Output tokens are billed roughly 5x input on most models, so the input/output split matters. Per-feature splits derived from section 4:

| Feature | Input tokens | Output tokens | Total |
| --- | ---: | ---: | ---: |
| Small | ~480K | ~83K | ~563K |
| Medium | ~3.97M | ~0.68M | ~4.65M |
| Large | ~30.8M | ~4.9M | ~35.7M |

Paid plans receive a 10% discount on model costs when using auto model selection. Cached input (after the first turn in a session) is billed well below the uncached input rate, so the figures above are a conservative upper bound on input cost.

### Worked example

Rates as of 2026-06-09 for a versatile default-class model ($3.00 per 1M input, $15.00 per 1M output). Verify current rates before quoting; pricing changes frequently.

| Feature | Calculation | USD | AI credits |
| --- | --- | ---: | ---: |
| Small | 0.48 × $3.00 + 0.083 × $15.00 | ~$2.69 | ~270 |
| Medium | 3.97 × $3.00 + 0.68 × $15.00 | ~$22.11 | ~2,210 |
| Large | 30.8 × $3.00 + 4.9 × $15.00 | ~$165.90 | ~16,600 |

The monthly squad volume in section 6 scales the same way: apply the same two rates to its input/output split. A cheaper model family lowers both rates; assigning routine agents (validate, verify, finalize, decompose) to a lightweight family and reserving a frontier family for plan, implement.execute, and review.code reduces the blended rate.

### Plan headroom

GitHub meters all of this in AI credits, and every paid plan includes a monthly credit allowance. To check whether your usage fits, compare your plan's allowance against the per-feature credit estimate above:

```
features per month before overage = monthly included AI credits / credits per feature
```

Read your plan's current included allowance (and the per-token overage rate) from the [GitHub Copilot billing page](https://docs.github.com/en/copilot/concepts/billing/about-billing-for-github-copilot). Allowances, plan tiers, and the variable flex portion change over time, so the live billing page is the only reliable source. Example: if your plan includes 7,000 credits and a medium feature costs ~2,210 credits at your current rates, you can ship roughly three medium features per month before additional usage applies.

## 6. Monthly forecasts for a typical squad

Assumptions: one squad of 3 developers, 1-week sprints, mixed feature sizes.

| Mix (per month) | Volume | Tokens |
| --- | --- | --- |
| 2 small features | 2 × 563K | ~1.13M |
| 3 medium features | 3 × 4.65M | ~13.95M |
| 1 large feature | 1 × 35.7M | ~35.7M |
| 4 sprints (sprint phase) | 4 × 29K | ~116K |
| 4 refine runs (weekly) | 4 × 55K | ~220K |
| Security reviews (2 triggered) | 2 × 68K | ~136K |
| Envision + kickoff (one-time amortized) | — | ~48K |
| **Monthly total per squad** | | **~51.3M** |
| **Per developer (3 devs)** | | **~17.1M** |

To turn this monthly volume into a bill, apply the method in section 5 to the input/output split. Assigning routine agents (validate, verify, finalize, decompose) to a smaller, cheaper model lowers the effective blended rate; reserving a premium model only for plan, implement.execute, and review.code keeps the high-rate share small.

Note: Copilot Business and Enterprise seats include per-user AI credits pooled across the organization. Verify the included allotment and per-token overage rates on your billing page.

## 7. Framework-specific overhead (what DevSquad adds on top of ad-hoc Copilot use)

Isolated cost of running through DevSquad versus an unstructured Copilot session producing similar code:

| Source of overhead | Tokens per feature (medium) |
| --- | ---: |
| Coordinator agent prompts (loaded per phase) | ~25K (mostly cached after first turn) |
| Sub-agent prompts (isolated contexts) | ~30K |
| Skill SKILL.md auto-triggers | ~15K |
| Artifact re-reading between phases (ADR-0003) | ~40K |
| Quality gates, handoff envelopes, reasoning logs | ~10K |
| **Total framework overhead per medium feature** | **~120K** |

That is **~1.5% of a medium feature's total spend** and **~0.2% of a large one**. The framework's prompt machinery is not what moves the bill. The real cost is the work being done (code reads, test loops, generation).

## 8. Cost-reduction levers (by impact)

Listed in order of leverage:

1. **Model selection per agent** (highest impact). The framework does not hardcode a model on any agent, since it has no control over which models, regions, or plan restrictions a given consumer can access. Models also change and are deprecated at a fast pace. Consumers can override an agent's frontmatter `model` field through open-source tooling such as [`agext-cli`](https://www.npmjs.com/package/agext-cli), which layers repo-local overrides on top of the installed plugin without modifying the originals. As a general rule, assign a smaller, cheaper model family (for example a Haiku-class or mini/flash-class model) to routine agents (validate, verify, finalize, decompose), and reserve a frontier family (for example a Sonnet-, Opus-, or GPT-5-class model) for plan, implement.execute, and review.code.
2. **Cap retry loops** in implement. A debugging-recovery skill that escalates to the user after N failed attempts prevents runaway sessions.
3. **Tighter task decomposition**. Smaller tasks read less surrounding code and have shorter debug tails. Average task cost drops linearly with scope.
4. **Honor ADR-0003 cleanup boundaries**. Running an entire delivery in one mega-session increases the risk of context contamination, which leads to retries. Use phase boundaries to keep context clean.
5. **Keep sessions warm and stable**. With extended prompt caching, resuming related work within the cache-retention window reuses the prompt prefix at the cached rate; a long idle gap forces a cold start that reprocesses the whole prefix at full price. Changing the model or reasoning effort mid-session can also invalidate the cache. Group related turns and avoid unnecessary cold starts.
6. **Pooled entitlements for Business/Enterprise**. With pooled credits, heavy implement sessions for one dev are offset by lighter envision/specify work elsewhere in the org.
7. **Code completions are still free**. Inline coding and Next Edit Suggestions remain unlimited. Encourage devs to use those for trivial edits instead of asking an agent.

## 9. Caveats and assumptions

- All figures use the 4 chars/token English approximation. Codex/Anthropic tokenizers can vary ±20%.
- The per-phase static load is derived from raw agent/skill/instruction file sizes, including YAML frontmatter. Frontmatter is largely declarative harness config (`tools`, `agents`, `handoffs`, `user-invocable`) and does not all reach the model verbatim, so the figure slightly over-counts there. Tool-schema definitions are not in the file sizes either, but modern harnesses defer most of them via tool search (loading a tool's full schema only when the model searches for it, and placing it outside the cached prefix), so per-turn tool overhead is small and shrinking rather than a fixed cost on every request. The model body below the frontmatter dominates the actual system prompt.
- Cache hit rates depend on session continuity. With extended prompt caching (up to 24h on supported OpenAI models) shorter pauses still hit cache; only resumes after the retention window pay uncached rates.
- Newer model generations trend toward more tokens per task, partially offset by ongoing harness efficiency gains (improved caching, tool search, cheaper sub-agents). Re-validate the baseline when you change your default model.
- Tool output (test logs, large file diffs) is input-billed and can be the single largest line item in a debug-heavy session.
- The "implement per task" figures assume TDD with 2–4 test cycles per task. Stuck tasks with 10+ cycles can easily 3–5x the figure.
- Copilot code review (the GitHub-native PR review feature) additionally consumes Actions minutes. Not included here.
- Numbers do not include third-party agent usage. MCP servers called from agents may have their own pricing.

## 10. How to validate this baseline in practice

1. Pick one medium feature.
2. Run the full sequence end-to-end: `/devsquad.specify`, then `/devsquad.plan`, then `/devsquad.decompose`, then `/devsquad.implement`, then `/devsquad.review`.
3. Download the **usage report CSV** from the premium request analytics page. Each row will include `aic_quantity` and `aic_gross_amount`.
4. Filter rows by the session window. Compare the AI-credit total against the medium-feature estimate in section 5 (and the token totals in section 4). Because your account converts tokens to credits at whatever per-token rates are current, this validates the baseline without the doc hardcoding any rate.
5. If actuals deviate by more than 2x, the dominant cause is almost always (a) model choice mismatch or (b) retry loops on a small number of tasks. Inspect with `harness-learnings` skill.

Re-run this validation whenever you change your default model or after major harness updates, since both shift the token baseline.

## 11. Headline numbers at a glance

- Small feature: **~0.5M tokens**
- Medium feature: **~4.6M tokens**
- Large feature/migration: **~36M tokens**
- Typical squad of 3 devs at sustainable cadence: **~51M tokens/month** (~17M per dev)
- Framework overhead vs ad-hoc Copilot: **~1–2%** on real work

Apply the section 5 method (input/output split × your model's current rates) to turn any of these into dollars or AI credits.
