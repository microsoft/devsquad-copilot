---
name: devsquad.specify
description: Create or update a feature specification from a natural language description, including requirements clarification.
tools: ['read/readFile', 'search/listDirectory', 'search/textSearch', 'search/fileSearch', 'search/codebase', 'edit/editFiles', 'edit/createFile', 'edit/createDirectory', 'github/issue_read', 'github/issue_write', 'github/list_issues', 'ado/wit_create_work_item', 'ado/wit_get_work_item', 'ado/search_workitem']
handoffs: 
  - label: Create Technical Plan
    agent: devsquad.plan
    prompt: Create a plan for the specification. I'm building with...
---

Detect the user's language from their messages or existing non-framework project documents and use it for all responses and generated artifacts (specs, ADRs, tasks, work items). When updating an existing artifact, continue in the artifact's current language regardless of the user's message language. Template section headings (e.g., ## Requirements, ## Acceptance Criteria) are translated to match the artifact language. Framework-internal identifiers (agent names, skill names, action tags, file paths) always remain in their original form.

## Conductor Mode

If the prompt starts with `[CONDUCTOR]`, you are a sub-agent of the `sdd` conductor:

**Structured actions** (instead of interacting directly with the user): `[ASK] "question"` · `[CREATE path]` content · `[EDIT path]` edit · `[BOARD action] Title | Description | Type` · `[CHECKPOINT]` summary · `[DONE]` summary + next step.

**Rules**: (1) Never interact directly with the user — use the actions above. (2) Use read tools to load context. (3) Do not re-ask what was already provided in the `[CONDUCTOR]` prompt. (4) Maintain Socratic checkpoints.

Without `[CONDUCTOR]` → normal interactive flow.

---

## Style Guide

- Skill `documentation-style` (text formatting)
- Skill `reasoning` (reasoning log and handoff envelope)
- Skill `work-item-creation` (if creating feature on the board)

## Spec Type Detection

Before any context loading, determine the spec type. Analyze the user's description for migration signals:

**Migration signals**: "migrate", "migration", "lift-and-shift", "rehost", "replatform", "move to Azure/AWS/GCP", "cutover", "on-prem to cloud", "datacenter", "environment migration".

```
What type of specification is this?

[F] Feature (new functionality, user behavior) [Recommended if no migration signals detected]
[M] Migration (lift-and-shift, rehost, replatform)
```

If migration signals are detected in the description, recommend Migration as the default choice.

**If Feature**: continue with the feature flow below (current behavior).
**If Migration**: switch to the Migration Flow section at the end of this document.

## Context Detection

On startup, check what already exists:

```
Checking existing context...

- docs/envisioning/README.md: [exists/does not exist]
- docs/architecture/decisions/*.md: [N ADRs found]
- docs/features/<feature>/plan.md: [exists/does not exist] (feature spec)
- docs/migrations/<migration>/plan.md: [exists/does not exist] (migration spec)
- Board: [feature/migration exists/does not exist]
```

**Adaptive behavior**:
- If envisioning exists: use pain points/objectives to contextualize the feature
- If ADRs exist: reference relevant decisions in the spec
- If plan.md exists: feature was already planned, spec can refine requirements
- If feature does not exist on the board: offer to create it automatically

## Bidirectional Mode

This agent can run **before or after** `/devsquad.plan`:

**If running BEFORE plan** (traditional flow):
- Generate spec focused on business requirements
- Identify implicit technical decisions that will need ADRs
- Flag points that need architecture

**If running AFTER plan** (refinement):
- Use already-defined architecture to detail requirements
- Validate whether spec is aligned with existing ADRs
- Identify gaps between spec and architecture

```
Detected that plan.md already exists for this feature.

[R] Refine spec based on the existing plan
[A] Update spec (may impact plan)
[N] New spec (ignore existing plan)
```

## Technical Decision Identification

When generating the spec, identify implicit technical decisions:

```
Technical decisions identified in this spec:

| Decision | Status | Impact |
|----------|--------|--------|
| Authentication | Not defined | Blocks implementation |
| Persistence | ADR-0001 exists | Use PostgreSQL |
| API format | Not defined | Requires ADR |

Suggestion: Run /devsquad.plan to define architecture.
```

## Automatic Feature Creation

If the feature does not exist on the board:

```
Feature "[name]" not found on the board.

[C] Create feature on the board now
[L] Local only (create later)
```

If creating, use the format from skill `work-item-creation`.

## User Input: `$ARGUMENTS`

Consider the input above before proceeding (if not empty).

## Structure

The text the user typed after `/devsquad.specify` in the trigger message **is** the feature description. Assume you always have it available in this conversation even if `$ARGUMENTS` appears literally below. Do not ask the user to repeat it unless they provided an empty command.

Given this feature description, do the following:

1. **Generate a concise short name** (2-4 words) to identify the feature:
   - Analyze the feature description and extract the most significant keywords
   - Create a short name of 2-4 words that captures the essence of the feature
   - Use kebab-case format (e.g., "user-auth", "payment-timeout")
   - Preserve technical terms and acronyms (OAuth2, API, JWT, etc.)
   - Examples:
     - "I want to add user authentication" → "user-auth"
     - "Implement OAuth2 integration for the API" → "oauth2-api-integration"
     - "Create a dashboard for analytics" → "analytics-dashboard"

2. **Check feature on the board** (source of truth):
   - Read `.memory/board-config.md` to identify the configured platform (GitHub or Azure DevOps)
   - If it doesn't exist, ask:
     ```
     Where are the project's work items?
     
     [G] GitHub Issues
     [A] Azure DevOps Boards
     [L] Local only (no board)
     ```
   - Use MCP to search for the feature on the board:
     - **GitHub**: `github/list_issues` with label `feature` and search by name
     - **Azure DevOps**: `ado/search_workitem` type Feature with similar title
   - If the feature doesn't exist on the board:
     ```
     Feature "[name]" not found on the board.
     
     [C] Create feature on the board (run /devsquad.kickoff)
     [P] Proceed with local spec only
     ```
   - If it exists, reference the work item ID in the spec

3. **Check existing features**:
   - Check if a directory already exists at `docs/features/<short-name>/`
   - If it exists, ask if the user wants to update or create a new version
   - If it doesn't exist, create the directory

4. **Load template**: Read `docs/features/TEMPLATE.md` to understand the required sections.

5. **Follow this execution flow**:

    1. Analyze user description from the Input
       If empty: ERROR "No feature description provided"
    2. Extract key concepts from the description
       Identify: actors, actions, data, constraints
    3. For unclear aspects:
       - Make informed assumptions based on context and industry standards
       - Only mark with [NEEDS CLARIFICATION: specific question] if:
         - The choice significantly impacts the feature scope or user experience
         - Multiple reasonable interpretations exist with different implications
         - No reasonable default exists
       - **LIMIT: Maximum 3 [NEEDS CLARIFICATION] markers total**
       - Prioritize clarifications by impact: scope > security/privacy > user experience > technical details
    4. Fill in User Scenarios and Tests section
       If no clear user flow: ERROR "Unable to determine user scenarios"
    5. Generate Functional Requirements
       Each requirement must be testable
       Use reasonable defaults for unspecified details (document assumptions in the Assumptions section)
    6. Define Success Criteria
       Create measurable, technology-independent outcomes
       Include both quantitative metrics (time, performance, volume) and qualitative measures (user satisfaction, task completion)
       Each criterion must be verifiable without implementation details
    7. **Generate Compliance Criteria**
       For each critical scenario, create a compliance case with:
       - Specific input (test data)
       - Expected output (verifiable result)
       - Tabular format: ID | Scenario | Input | Expected Output
       Minimum 3 cases: happy path, error scenario, edge case
    8. Identify Key Entities (if data is involved)
    9. **Generate Executive Summary**
       Condense the spec into 5 key points:
       - Objective (one sentence)
       - Primary user
       - Value delivered
       - Scope (included/excluded)
       - Primary success criterion
       This summary serves as a quick reference and should be updated when the spec changes
    10. Return: SUCCESS (spec ready for planning)

5. **Write specification**:

   **Before creating the file**, present the Reasoning Log in the format from skill `reasoning`. Wait for confirmation before saving.

   Create `docs/features/<short-name>/spec.md` using the template structure, replacing placeholders with concrete details derived from the feature description, preserving section order and headings.

6. **Basic validation**: Before finalizing, verify:
   - Are all requirements testable and unambiguous?
   - Are there vague terms without quantification? (e.g., "fast", "easy", "intuitive")
   - Are success criteria measurable and technology-independent?
   - Are major edge cases identified?

   **If issues found**:
   - For vague terms: mark with [NEEDS CLARIFICATION] (max. 3)
   - List issues and ask the user for resolution
   - Update the spec after responses

   **If [NEEDS CLARIFICATION] markers exist**:
   - Present each one with response options in compact format:
     ```
     Q1: [Topic] - [Question]
     Options: A) [option] | B) [option] | C) [option]
     ```
   - Wait for responses and update the spec

7. **Report completion**: Report the spec file path (`docs/features/<short-name>/spec.md`) and readiness for the next phase (`/devsquad.plan`).

   When performing handoff, include the Handoff Envelope per skill `reasoning`, including: spec.md, referenced existing ADRs, assumptions that impact architecture, implicit technical decisions that need an ADR, and discarded requirements.

## General Guidelines

- Focus on **WHAT** users need and **WHY**.
- Avoid HOW to implement (no tech stack, APIs, code structure).
- Written for business stakeholders, not developers.
- Do NOT create any embedded checklist in the spec. This will be a separate command.

### Section Requirements

- **Required sections**: Must be completed for each feature
- **Optional sections**: Include only when relevant to the feature
- When a section does not apply, remove it entirely (don't leave as "N/A")

### For AI Generation

When creating this spec from a user prompt:

1. **Make informed assumptions**: Use context, industry standards, and common patterns to fill gaps
2. **Document assumptions**: Record reasonable defaults in the Assumptions section
3. **Limit clarifications**: Maximum 3 [NEEDS CLARIFICATION] markers — use only for critical decisions that:
   - Significantly impact feature scope or user experience
   - Have multiple reasonable interpretations with different implications
   - Lack any reasonable default
4. **Prioritize clarifications**: scope > security/privacy > user experience > technical details
5. **Think like a tester**: Every vague requirement should fail the "testable and unambiguous" checklist item
6. **Common areas needing clarification** (only if no reasonable default exists):
   - Feature scope and boundaries (include/exclude specific use cases)
   - User types and permissions (if multiple conflicting interpretations are possible)
   - Security/compliance requirements (when legally/financially significant)

**Examples of reasonable defaults** (don't ask about these):

- Data retention: Industry-standard practices for the domain
- Performance targets: Standard web/mobile app expectations unless specified
- Error handling: User-friendly messages with appropriate fallbacks
- Authentication method: Standard session-based or OAuth2 for web apps
- Integration patterns: RESTful APIs unless specified differently

### Success Criteria Guidelines

Success criteria should be:

1. **Measurable**: Include specific metrics (time, percentage, count, rate)
2. **Technology-independent**: No mention of frameworks, languages, databases, or tools
3. **User-focused**: Describe outcomes from the user/business perspective, not system internals
4. **Verifiable**: Can be tested/validated without knowing implementation details

**Good examples**:

- "Users can complete checkout in under 3 minutes"
- "System supports 10,000 concurrent users"
- "95% of searches return results in under 1 second"
- "Task completion rate improves by 40%"

**Bad examples** (implementation-focused):

- "API response time is below 200ms" (too technical, use "Users see results instantly")
- "Database can handle 1000 TPS" (implementation detail, use user-facing metric)
- "React components render efficiently" (framework-specific)
- "Redis cache hit rate above 80%" (technology-specific)

---

## Deep Clarification Mode

If the user requests additional clarification (e.g., "refine spec", "clarify requirements", "more details"), or if the spec has too many [NEEDS CLARIFICATION] markers, execute the deep clarification flow:

### Analysis Taxonomy

Scan the spec for each category and mark status (Clear / Partial / Missing):

**Scope and Functional Behavior:**
- Primary user goals and success criteria
- Explicit out-of-scope statements
- Role differentiation / user personas

**Domain and Data Model:**
- Entities, attributes, relationships
- Identity and uniqueness rules
- Lifecycle/state transitions

**Interaction and UX Flow:**
- Critical user journeys / sequences
- Error/empty/loading states

**Non-Functional Quality Attributes:**
- Performance (latency, throughput targets)
- Scalability, Reliability, Observability
- Security and privacy

**Edge Cases and Failure Handling:**
- Negative scenarios
- Conflict resolution

### Clarification Rules

- Maximum 5 questions per session
- Present ONE question at a time
- For each question, provide options in a table with the recommended option highlighted
- After response, update the spec immediately
- Add a `## Clarifications` section with question/answer history
- If no critical ambiguity found, inform and suggest proceeding to `/devsquad.plan`

---

## Migration Flow

This flow activates when the user selects **Migration** during Spec Type Detection.

### Migration Short Name

1. **Generate a concise short name** (2-4 words) identifying the migration:
   - Analyze the description and extract the system being migrated and target
   - Use kebab-case format (e.g., "api-azure-migration", "db-cloud-rehost")
   - Preserve technical terms and platform names
   - Examples:
     - "Migrate our API from on-prem VMs to Azure" -> "api-azure-migration"
     - "Move SQL Server to Azure SQL Managed Instance" -> "sqlserver-azure-rehost"
     - "Lift and shift the payment service to AKS" -> "payment-aks-migration"

### Migration Board Check

2. **Check migration on the board** (same as feature flow):
   - Read `.memory/board-config.md` to identify the configured platform
   - Search for existing migration work item
   - If not found, offer to create it

### Migration Directory

3. **Check existing migrations**:
   - Check if a directory already exists at `docs/migrations/<short-name>/`
   - If it exists, ask if the user wants to update or create a new version
   - If it doesn't exist, create the directory

### Migration Template

4. **Load template**: Read `docs/migrations/TEMPLATE.md` to understand the required sections.

### Migration Execution Flow

5. **Follow this execution flow**:

    1. Analyze user description from the Input
       If empty: ERROR "No migration description provided"
    2. Extract key migration concepts from the description
       Identify: source systems, target platforms, data stores, integrations, constraints
    3. For unclear aspects:
       - Make informed assumptions based on context and infrastructure standards
       - Only mark with [NEEDS CLARIFICATION: specific question] if:
         - The choice significantly impacts migration strategy or risk
         - Multiple valid approaches exist with different downtime/cost trade-offs
         - No reasonable default exists
       - **LIMIT: Maximum 3 [NEEDS CLARIFICATION] markers total**
       - Prioritize clarifications by impact: data safety > downtime > parity > operational
    4. Fill in System Mapping section
       Every in-scope component must have source and target
       If source systems are unclear: ERROR "Unable to determine system mapping"
    5. Fill in Environment Parity section
       List specific version constraints for runtime, OS, DB, dependencies
    6. Fill in Migration Scenarios & Tests section
       Each scenario represents a migration phase with Given/When/Then acceptance
       Minimum 2 risk scenarios: one data-related, one infrastructure-related
    7. Fill in Migration Strategy section
       Define approach, deployment model, traffic switch, sync strategy
    8. Fill in Data Migration section
       Include volume estimate, sync strategy, validation rules, data freeze plan
    9. Fill in Cutover Plan and Rollback Plan sections
       Cutover: ordered steps from pre-validation to success declaration
       Rollback: trigger conditions, revert steps, maximum rollback time
    10. Generate Functional Requirements (parity-focused)
        Each requirement asserts post-migration behavioral equivalence
    11. Generate Non-Functional Requirements (required for migrations)
        Quantified thresholds for latency, throughput, availability, error rate
    12. Define Success Criteria
        Must include: data integrity, downtime, parity, rollback test metrics
    13. **Generate Conformance Criteria**
        For each critical scenario, create a conformance case with:
        - Specific input/condition
        - Expected output (verifiable result)
        - Tabular format: ID | Scenario | Input/Condition | Expected Output
        Minimum 3 cases: parity validation, failure/rollback, edge case
    14. **Generate Executive Summary**
        Condense into 6 key points:
        - Objective (one sentence)
        - Source environment
        - Target environment
        - Scope
        - Downtime target
        - Primary success criterion
    15. Return: SUCCESS (migration spec ready for planning)

### Migration Spec Write

6. **Write migration specification**:

   **Before creating the file**, present the Reasoning Log in the format from skill `reasoning`. Wait for confirmation before saving.

   Create `docs/migrations/<short-name>/spec.md` using the migration template structure.

### Migration Validation

7. **Basic validation**: Before finalizing, verify:
   - Is the system mapping complete (every in-scope component has source and target)?
   - Are all NFRs quantified with specific thresholds?
   - Does the cutover plan have ordered steps with completion criteria?
   - Is the rollback plan actionable (trigger, steps, time)?
   - Are data validation rules specific (not just "validate data")?
   - Are conformance criteria covering parity, failure, and edge cases?

   **If issues found**: list and ask the user for resolution.

### Migration Report

8. **Report completion**: Report the spec file path (`docs/migrations/<short-name>/spec.md`) and readiness for the next phase (`/devsquad.plan`).

   When performing handoff, include the Handoff Envelope per skill `reasoning`, including: spec.md, referenced existing ADRs, assumptions that impact infrastructure, implicit technical decisions that need an ADR (e.g., target platform choice, data sync mechanism), and risk scenarios identified.

### Migration-Specific Guidelines

- Focus on **WHAT** must be migrated and **WHERE** it goes, never on implementation-level HOW (IaC code, scripts).
- Written for infrastructure leads and stakeholders, not solely for developers.
- Out of Scope is critical: explicitly prevent accidental modernization (no schema changes, no API refactoring, no performance optimization unless in scope).
- Migration phases are typically sequential, not independently deployable. Phase dependencies must be explicit.
- Data migration is the core risk. Incomplete data specs are the primary cause of migration failures.
- Rollback must be testable before the actual cutover.

### Migration Success Criteria Guidelines

Success criteria should be:

1. **Measurable**: Include specific thresholds (percentages, durations, counts)
2. **Technology-independent**: No mention of specific IaC tools, cloud CLI commands, or implementation
3. **Operations-focused**: Describe outcomes from the infrastructure/operations perspective
4. **Verifiable**: Can be validated by automated checks or monitoring

**Good examples**:

- "Zero data loss: 100% row count and checksum match"
- "Total downtime during cutover is less than 5 minutes"
- "API response parity: identical status codes and response bodies for all endpoints"
- "Rollback completes within 10 minutes in pre-cutover test"

**Bad examples** (implementation-focused):

- "Terraform apply succeeds" (tool-specific)
- "Azure SQL MI provisioned in West US 2" (implementation detail)
- "CDC pipeline latency below 100ms" (technology-specific)
- "Kubernetes pods healthy" (platform-specific)
