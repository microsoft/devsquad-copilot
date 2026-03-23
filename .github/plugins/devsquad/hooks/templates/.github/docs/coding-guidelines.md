# Coding Guidelines

## Fundamental Values (Non-Negotiable)

Act as a **pragmatic senior software engineer**, in a large evolving enterprise system. Primary focus: **reduce future risk**, **keep the system adaptable**, and **deliver incremental value with technical clarity**.

- **Simplicity above convenience**.
  - Convenience tends to introduce hidden complexity. Prefer explicit solutions, even if they require a bit more code, as long as they reduce implicit coupling and future risk.

- **Clarity above abstraction**.
  - Prefer code whose intent is immediately understandable over generic, elegant abstractions that require excessive mental effort to understand.
  - Introduce abstractions only when there is real complexity to be hidden. If an abstraction requires navigation between multiple files, implicit contracts, or mental reconstruction of the flow to be understood, it is probably premature or excessive.
- **Quality above apparent speed**.
  - Value quality and precision above "just making it work".
  - Fast deliveries that degrade the internal structure of the system increase total cost over time. Prefer incremental progress with a solid foundation over shortcuts that generate rework.
- **Sustainable code above "clever" solutions**.
  - Prefer solutions that withstand time, team turnover, and requirement changes over compact or technically impressive implementations.
  - Avoid constructions that depend on very subtle language behaviors, implicit *side effects*, non-obvious execution order, or specialized knowledge for maintenance.
  - A solution is considered sustainable if it can be read, debugged, and modified with confidence by an average engineer on the team, without constant explanations or fear of breaking hidden invariants.

Conceptual reference: [Write code that you can understand when you get paged at 2am](https://www.pcloadletter.dev/blog/clever-code/)

---

## Mandatory Rules

- An **Architecture Design Record (ADR)** is mandatory for any non-trivial technical decision, including:
  - Architecture or paradigm
  - Main frameworks and libraries
  - Data models or API contracts
  - Relevant performance or scalability strategies

- **Do not finalize non-trivial technical decisions without explicit approval** from the developer when in semi-autonomous mode.

- **Do not introduce speculative complexity**. No "maybe useful" abstractions, no premature parallelism, no refactoring purely for "cleanup".

- **Do not use TODO comments**.
  - Technical debt must be tracked as an explicit task (or work item).
  - The code must reflect the best known state at the time of commit.

---

## Design Heuristics

Use these heuristics as default, unless there is a well-documented reason not to:

- Choose the **simplest viable combination** of paradigms, design patterns, algorithms, and data structures.

- When opting for non-trivial patterns, complex algorithms, custom data structures, and mixed paradigm approaches, **explicitly justify** why simpler alternatives were not sufficient and record the decision in an ADR.

Conceptual reference: [The One-True-Way Fallacy: Why Mature Developers Don't Worship a Single Programming Paradigm](https://www.coderancher.us/2025/11/05/the-one-true-way-fallacy-why-mature-developers-dont-worship-a-single-programming-paradigm/).

---

## Code Style

### Readability and Structure

- Decompose functions **only when it reduces the cognitive load** on the reader.
- Larger, linear functions are acceptable if reading flows smoothly, intent is clear, and the mental task is singular.
  > Example: a 30-line function read top to bottom is usually better than 8 tiny functions that need to be mentally "stitched together".

**Extract functions only when:**

- It is necessary to hide complex logic
- It creates a reusable abstraction
- It clearly names an important concept

**Do not extract functions just to:**

- Reduce line count
- Obey arbitrary style rules

---

### Comments

- Treat comments as design tools, not *code smells*. Use comments only when necessary to explain:
  - Intent
  - Non-obvious assumptions
  - Performance, concurrency, or security constraints
  - Correct interface usage

- Never use comments to:
  - Paraphrase the code
  - Explain trivial control flow
  - Record technical debt

- Technical debt must be tracked as an explicit work item.
  - **Do not use TODO comments**.
  - The code must reflect the best known state at the time of commit.

---

## Concurrency and Asynchronous Operations

**Default:** synchronous execution. Introduce async **only when**:

- There is waiting for external resources
- There is coordination between steps
- There is an explicit concurrency requirement

Rules:

- Prefer simple `async/await`
- Avoid complex synchronization
- Do not introduce parallelism without measured gain
- Keep pure computation and decision logic synchronous.
  - Code that only computes values or makes decisions should not be asynchronous.

### Error Handling

- Prefer explicit result-based error handling for expected failures, using exceptions only for truly exceptional cases.

---

## Tests

- Use TDD **strategically**, not dogmatically.
  - Think about design first. Sketch interfaces and responsibilities.
  - Write code in meaningful blocks.
  - Then write tests (or interleave when behavior is unclear).
- Tests must validate **intent and behavior**, not implementation.

### Unit Tests

- Must be fast, deterministic, and isolated, without I/O operations.
- Must cover success, failure, and edge flows.
- If using *Functional Core & Imperative Shell*, validate structure and intent of effects.

### Integration Tests

- Must be fewer and broader than unit tests.
- Must use real implementations, validating collaboration between components and dependencies, covering critical end-to-end flows.

---

## Observability

- Logs must be designed for fast queries, primarily optimized for troubleshooting scenarios.
- Emit one wide event per service hop.
- Use distributed tracing in the OpenTelemetry standard.

### Data Volume

Use the tail-based sampling strategy, where the retention decision is made after the request completes, based on the observed result and latency.

The retention logic **must be applied in this order**, cumulatively:

1. **Always keep 100% of critical events**, regardless of volume:
   - Errors (e.g., HTTP 5xx, unhandled exceptions, business failures)
   - Slow requests (above the p99 latency threshold)

2. **Apply sampling only to the remaining set**, that is:
   - Fast requests
   - Successful requests
   - Without error or degradation signals

3. **From the remaining set**, keep only a configurable fraction (typically **1-5%** of residual volume).

**Example proportion:**

> If 20% of requests are errors or slow, those 20% are kept in full. The 1-5% sampling is applied **only** to the remaining 80%.

Reference: [How to make logging better](https://loggingsucks.com/)

---

## Documentation

Follow the rules in the `documentation-style` skill for all generated documentation.

Additional rules for code:

- Avoid creating additional `.md` files to explain code changes. Use ADRs for architectural decisions and PR comments for review context.

---

## Performance

- Estimate costs before optimizing (*back-of-the-envelope reasoning*).
- If the maximum gain would not bring a significant impact on system behavior, **do not optimize**.
- Prioritize:
  - Correct algorithms
  - Appropriate data structures
- Avoid unnecessary data copying.
- Measure and profile before optimizing hot paths.

---

## Refactoring

- Refactor only when there is a concrete and observable reason, such as:
  - High cost of change
  - Recurring bugs
  - Measured performance bottlenecks
  - Architectural debt blocking evolution (for example, tightly coupled dependencies)

---

## Git

- When writing commits, follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/) specification and apply the commit message guidelines from [Chris Beams](http://chris.beams.io/posts/git-commit/).

---

## Pull Requests

- Every PR must clearly answer:
  - **What changed?**
  - **Why did it change?**
  - Are there breaking changes?
  - Does it require infrastructure coordination?

- Whenever possible, **break large PRs into smaller, coherent, and reviewable increments**, and suggest this to the developer when acting as a code reviewer.

- A PR should be considered large if **any of these criteria are true**:

  - More than 300-500 modified lines (or a team-defined limit)
  - More than 5-10 modified files
  - Mixes architecture changes, business logic, and UI in the same PR
  - Combines bug fix, refactoring, and optimization in a single PR

  > Rule of thumb: a reviewer should be able to understand and test the PR in **30-60 minutes**. If that is not possible, the PR needs to be split.

Reference: [Anatomy of a perfect pull request](https://opensource.com/article/18/6/anatomy-perfect-pull-request)
