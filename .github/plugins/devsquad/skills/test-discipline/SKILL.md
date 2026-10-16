---
name: test-discipline
description: "Testing practices for behavior-focused, refactor-resistant tests. Use when implementing features, fixing bugs, refactoring, or adding or reviewing tests to ensure they verify intent through public interfaces and avoid tautological assertions. Also use when adding regression tests after bug fixes. Consulted by the implement agent during coding and by the review agent when validating test quality. Do not use for test strategy decisions (use complexity-analysis), for failure triage and root-cause analysis (use debugging-recovery, then after root cause is localized use test-discipline to add the reproducing regression test and fix), or for integration test infrastructure setup."
---

# Test Discipline

## Philosophy

Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests should not break unless behavior changes. A good test reads like a specification.

Use TDD **strategically, not dogmatically**. The goal is high-quality tests that verify intent — the ordering of when tests are written is a means to that end, not the end itself.

## When to Write Tests First

Test-first (red-green-refactor) works best when:

- **Fixing a bug**: Write a test that reproduces the bug before fixing it. The test **must** fail BEFORE the fix and pass AFTER. If the bug is not reproducible via automated test (race condition, environment-specific), document why and what alternative evidence proves the fix.
- **Behavior is unclear**: The test forces you to define expected behavior precisely before writing code.
- **Working on a well-defined interface**: The contract is clear and the test is straightforward to write.

## When to Write Tests After (or Interleave)

Design-first-then-test works best when:

- **Exploring a new domain**: The design is not yet clear. Sketch interfaces and responsibilities first, write code in meaningful blocks, then add tests.
- **Prototyping**: Rapid iteration where the interface is still evolving. Tests written too early against an unstable interface create waste.
- **Well-understood patterns**: When applying a known pattern (CRUD, adapter, pipeline), write the implementation, then test the behavior.

In both approaches, the quality criteria for the resulting tests are identical.

## Vertical Slices

Regardless of test-first or design-first, deliver work in **vertical slices** — thin end-to-end paths through all layers.

**Anti-pattern: horizontal slicing**

Writing all tests first (or all of one layer first), then all implementation. This produces tests that verify *imagined* behavior and delays integration feedback.

```text
AVOID (horizontal):
  All tests → All implementation
  All models → All services → All endpoints

PREFER (vertical):
  Slice 1: User can create an order (all layers, happy path)
  Slice 2: Order validates required fields (error handling)
  Slice 3: Order calculates totals (business logic)
```

The first slice should be a **tracer bullet**: a thin end-to-end path that proves the architecture works.

## Per-Task Procedure

1. **Choose the next vertical slice** (tracer bullet first)
2. **Design**: Sketch the interface and responsibilities for this slice
3. **Implement + Test**: Either test-first (RED → GREEN) or implement-then-test, based on the context guidance above
4. **Verify**: Run the full test suite to confirm relevant existing tests and any justified new tests pass without regressions
5. **Refactor**: Clean up while all tests are green. Never refactor with failing tests.
6. **Repeat**: Next slice

## Test Quality Criteria

Every test must satisfy these criteria regardless of when it was written:

| Criterion | Check |
|-----------|-------|
| **Behavior-focused** | Tests what the system does, not how it does it |
| **Public interface only** | Uses the same API that callers use |
| **Refactor-resistant** | Would survive internal restructuring without changes |
| **Independent oracle** | Expected outcomes follow a requirement, concrete example, or independently justified property rather than repeating the implementation |
| **Independent** | Does not depend on other tests or test execution order |
| **Deterministic** | Same result every run, no timing dependencies |
| **Readable** | Test name describes the behavior being verified |

For unit test rules, integration test rules, and test doubles hierarchy, follow `coding-guidelines.md` (always in context). This skill focuses on what coding-guidelines does not cover: the decision framework, per-task procedure, quality criteria, and anti-patterns.

## What Makes a Good Test

**Good tests** exercise real code paths through public APIs. They describe *what* the system does, not *how*. They read like a specification: "user can checkout with valid cart" tells you exactly what capability exists.

**Bad tests** are coupled to implementation:
- Mock internal collaborators
- Test private methods or internal state
- Bypass the public interface of the component under test with side-channel assertions (unless persistence itself is the behavior being verified)
- Break when you refactor, even though behavior has not changed

**Warning sign**: a test breaks when you refactor, but behavior has not changed. That test was testing implementation, not behavior.

## Avoid Tautological Tests

A tautological test derives its expectation from the implementation it is meant to verify, so the same mistake can appear on both sides of the assertion. Passing results then provide false confidence.

1. **Establish the oracle**: Derive expected outcomes from requirements, concrete examples, externally visible contracts, or independently justified properties. Do not use the result under test to generate its own expectation or copy the production algorithm into the assertion.
2. **Name a regression the assertion would catch**: Identify a plausible contract violation and check that the assertion would fail for it. This is a reasoning check and does not require mutation-testing tooling.
3. **Keep helpers independent of the behavior under test**: Shared fixture builders are fine. Avoid using the same formatting or calculation helper on both sides when correctness of that operation is part of the asserted contract.
4. **Assess what the assertion proves**: Computed expectations, property-based tests, independent reference implementations, snapshots, and mocks can be valid. A round-trip property alone can miss matching encoder and decoder bugs, and an unreviewed snapshot can preserve a defect. Asserting a stubbed value is meaningful when forwarding that value is the public contract, but does not verify the stubbed dependency's calculation.

For a contract where a 20 percent discount on 1,000 cents leaves 800 cents payable, avoid copying a buggy production calculation that returns the discount amount instead:

```python
assert discounted_total(1000, 20) == 1000 * 20 // 100
```

Use the independently established payable amount:

```python
assert discounted_total(1000, 20) == 800
```

The second assertion catches returning the discount amount. Additional cases should address relevant contract gaps, such as rounding, rather than repeat the same formula across many inputs.

Reference: [Tautological Tests by Randy Coulman](https://randycoulman.com/blog/2016/12/20/tautological-tests/).

## Behavior-Preserving Refactoring

1. Run the existing behavioral tests before changing code to establish a baseline, then run them after the refactor.
2. Reuse existing tests when they already protect the affected contract. Add tests only for a concrete coverage gap in behavior that must remain stable, preferably before restructuring that code.
3. Do not add tests solely for extracted private helpers, delegation details, renamed classes, or structural equivalence between old and new implementations. Comparing two implementations can support a refactor but does not independently establish that either meets the requirements.
4. Preserve behavioral assertions when adapting setup or call sites to an intentional interface change. Do not rewrite expected outcomes merely to match the refactored output.

## Integration with SDD Lifecycle

| Agent | How test discipline is used |
|-------|----------------------------|
| `devsquad.implement.execute` | Follows per-task procedure for each task |
| `devsquad.review.tests` | Uses test quality criteria as review rubric |
| `quality-gate` (code rubric) | Verifies behavior coverage and independent oracles, including existing tests for refactors |
| `debugging-recovery` | Adds regression test (test that reproduces bug, then fix) |

## Anti-patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| All tests first, then all code | Tests verify imagined behavior | Work in vertical slices |
| Mocking what you own | Tests break on refactor | Test through public interface with real implementations |
| Testing private methods | Coupled to implementation | Test the behavior those methods enable |
| Tautological assertions | The same bug can appear in implementation and expectation | Derive the expectation from an independent behavioral oracle |
| New tests for every refactor | Tests mirror new structure without protecting additional behavior | Reuse behavioral tests and add only concrete coverage gaps |
| 100% coverage as a goal | Coverage without behavior focus is noise | Cover critical paths and edge cases |
| Copy-paste test setup | Fragile, hard to maintain | Extract test helpers and fixtures |
| Testing the framework | Verifying framework behavior, not yours | Trust the framework, test your logic |
| Tests without assertions | False confidence — tests pass but verify nothing | Every test must assert observable behavior |
| Dogmatic test-first in unfamiliar domains | Premature tests lock in unstable interfaces | Design first, then test when the interface stabilizes |

## Checklist Per Slice

```text
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Expected outcome has an independent behavioral oracle
[ ] Assertion would catch a plausible contract violation
[ ] New tests address concrete behavior gaps rather than refactoring structure
[ ] Test doubles follow coding-guidelines hierarchy
[ ] No speculative features added
[ ] Refactoring done only while all tests pass
[ ] Suite runs green before moving to next slice
```
