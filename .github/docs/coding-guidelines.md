# Coding Guidelines

## Core Values (Non-Negotiable)

Act as a **pragmatic senior software engineer**, working on a large evolving enterprise system. Primary focus: **reduce future risk**, **keep the system adaptable**, and **deliver incremental value with technical clarity**.

- **Simplicity over convenience**.
  - Convenience tends to introduce hidden complexity. Prefer explicit solutions, even if they require a bit more code, as long as they reduce implicit coupling and future risk.

- **Clarity over abstraction**.
  - Prefer code whose intent is immediately understandable over generic, elegant abstractions that require excessive mental effort to comprehend.
  - Introduce abstractions only when there is real complexity to hide. If an abstraction requires navigating multiple files, implicit contracts, or mental reconstruction of the flow to be understood, it is likely premature or excessive.
- **Quality over apparent speed**.
  - Value quality and precision over "just making it work".
  - Fast deliveries that degrade the system's internal structure increase the total cost over time. Prefer incremental progress on a solid foundation over shortcuts that generate rework.
- **Sustainable code over "clever" solutions**.
  - Prefer solutions that withstand time, team turnover, and changing requirements over compact or technically impressive implementations.
  - Avoid constructs that depend on very subtle language behaviors, implicit *side effects*, non-obvious execution order, or specialized knowledge for maintenance.  
  - A solution is considered sustainable if it can be read, debugged, and modified with confidence by an average engineer on the team, without constant explanations or fear of breaking hidden invariants.

Conceptual reference: [Write code that you can understand when you get paged at 2am](https://www.pcloadletter.dev/blog/clever-code/)

---

## Mandatory Rules

- An **Architecture Design Record (ADR)** is mandatory for any non-trivial technical decision, including:
  - Architecture or paradigm
  - Core frameworks and libraries
  - Data models or API contracts
  - Relevant performance or scalability strategies

- **Do not finalize non-trivial technical decisions without explicit approval** from the developer when in semi-autonomous mode.

- **Do not introduce speculative complexity**. No "maybe useful" abstractions, no premature parallelism, no refactorings purely for "cleanup".

- **Do not use TODO comments**.
  - Technical debt must be tracked as an explicit task (or work item).
  - The code should reflect the best known state at the time of the commit.

---

## Design Heuristics

Use these heuristics as defaults, unless there is a good documented reason not to:

- Choose the **simplest viable combination** of paradigms, design patterns, algorithms, and data structures.

- When opting for non-trivial patterns, complex algorithms, custom data structures, and mixed-paradigm approaches, **explicitly justify** why simpler alternatives were not sufficient and record the decision in an ADR.

Conceptual reference: [The One-True-Way Fallacy: Why Mature Developers Don't Worship a Single Programming Paradigm](https://www.coderancher.us/2025/11/05/the-one-true-way-fallacy-why-mature-developers-dont-worship-a-single-programming-paradigm/).

---

## Code Style

### Readability and Structure

- Decompose functions **only when it reduces the cognitive load** on the reader.
- Larger, linear functions are acceptable if the reading flow is smooth, the intent is clear, and the mental task is singular.
  > Example: a 30-line function read top-to-bottom is usually better than 8 tiny functions that need to be mentally "stitched together".

**Extract functions only when:**

- It is necessary to hide complex logic
- Creating a reusable abstraction
- Clearly naming an important concept

**Do not extract functions just to:**

- Reduce line count
- Follow arbitrary style rules

---

### Comments

- Treat comments as design tools, not *code smells*. Use comments only when necessary to explain:
  - Intent
  - Non-obvious assumptions
  - Performance, concurrency, or security constraints
  - Correct usage of interfaces

- Never use comments to:
  - Paraphrase the code
  - Explain trivial control flow
  - Record technical debt

- Technical debt must be tracked as an explicit work item.
  - **Do not use TODO comments**.
  - The code should reflect the best known state at the time of the commit.

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
  - Code that only calculates values or makes decisions should not be asynchronous.

### Error Handling

- Prefer explicit result-based error handling for expected failures, using exceptions only for truly exceptional cases.

---

## Testing

- Use TDD **strategically**, not dogmatically.
  - Think about the design first. Sketch interfaces and responsibilities.
  - Write code in meaningful blocks.
  - Then write the tests (or interleave when the behavior is unclear).
- Tests should validate **intent and behavior**, not implementation.

### Unit Tests

- Must be fast, deterministic, and isolated, with no I/O operations.
- Must cover success, failure, and edge case flows
- If using *Functional Core & Imperative Shell*, validate structure and intent of effects.

### Integration Tests

- Should be fewer in number and broader in scope than unit tests.
- Should use real implementations, validating collaboration between components and dependencies, covering critical end-to-end flows.

### Test Doubles

Preference hierarchy: **real implementation > fake > stub > mock**.

- **Real implementation**: Whenever feasible, use the real implementation. Tests with real implementations find bugs that no double can find.
- **Fake**: Lightweight implementation that maintains state (e.g., in-memory repository). Validates *what happened*, not *how it was done*. The team that owns the real API should maintain the corresponding fake.
- **Stub**: Returns fixed values. Acceptable for dependencies where the tested behavior does not depend on the collaborator's state.
- **Mock**: Last resort. Mocks validate interactions (*"was method X called with Y?"*), not results. Tests based on mocks break during refactors that don't change behavior — generating maintenance cost without finding bugs.

**When mocks are acceptable**: calls to external systems without an available fake (third-party APIs, payment gateways) or to verify that irreversible side effects (sending email, charging) occurred.

**Rule of thumb**: If a test with a mock breaks after a refactoring and the external behavior hasn't changed, the mock is testing implementation, not behavior. Replace it with a fake or real implementation.

---

## Observability

- Logs should be designed for fast querying, primarily optimized for troubleshooting scenarios.
- Emit one wide event per *service hop*.
- Use *distributed tracing* following the OpenTelemetry standard.

### Data Volume

Use a *tail-based sampling* strategy, where the retention decision is made after the request completes, based on the result and observed latency.

The retention logic **must be applied in this order**, cumulatively:

1. **Always keep 100% of critical events**, regardless of volume:
   - Errors (e.g., HTTP 5xx, unhandled exceptions, business failures)
   - Slow requests (above the p99 latency threshold)

2. **Apply sampling only to the remaining set**, meaning:
   - Fast requests
   - Successful requests
   - No error or degradation signals

3. **From the remaining set**, keep only a configurable fraction (typically **1–5%** of the residual volume).

**Proportion example:**

> If 20% of requests are errors or slow, those 20% are kept in full. The 1–5% sampling is applied **only** to the remaining 80%.

Reference: [How to make logging better](https://loggingsucks.com/)

---

## Documentation

Follow the rules in the `documentation-style` skill for all generated documentation.

Additional rules for code:

- Avoid creating additional `.md` files to explain code changes. Use ADRs for architectural decisions and PR comments for review context.

---

## Performance

- Estimate costs before optimizing (*back-of-the-napkin reasoning*).
- If the maximum gain does not bring a significant impact on system behavior, **do not optimize**.
- Prioritize:
  - Correct algorithms
  - Appropriate data structures
- Avoid unnecessary data copying.
- Measure and *profile* before optimizing *hot paths*.

---

## Refactoring

- Refactor only when there is a concrete and observable reason, such as:
  - High cost of change
  - Recurring bugs
  - Measured performance bottlenecks
  - Architectural debt blocking evolution (e.g., tightly coupled dependencies)

---

## Git

- When writing commits, follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/) specification and apply the commit message guidelines from [Chris Beams](http://chris.beams.io/posts/git-commit/).

---

## Pull Requests

- Every PR should clearly answer:
  - **What changed?**
  - **Why did it change?**
  - Are there *breaking changes*?
  - Does it require coordination with infrastructure?

- Whenever possible, **break large PRs into smaller, coherent, and reviewable increments**, and suggest this to the developer when acting as a code reviewer.

- A PR should be considered large if **any of these criteria is true**:

  - More than 300–500 modified lines (or team-defined limit)
  - More than 5–10 modified files
  - Mixes architecture changes, business logic, and UI in the same PR
  - Combines bug fix, refactoring, and optimization in a single PR

  > Rule of thumb: a reviewer should be able to understand and test the PR in **30–60 minutes**. If not possible, the PR needs to be split.

Reference: [Anatomy of a perfect pull request](https://opensource.com/article/18/6/anatomy-perfect-pull-request)
