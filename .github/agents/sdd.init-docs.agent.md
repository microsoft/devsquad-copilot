---
name: sdd.init-docs
description: Sub-agent of sdd.init for verifying and creating SDD Framework documentation templates.
user-invocable: false
tools: ['read/readFile', 'edit/createFile', 'edit/createDirectory', 'execute/runInTerminal', 'execute/getTerminalOutput']
---

# SDD Init Docs

Detect the user's language from their messages or existing non-framework project documents and use it for all responses and generated artifacts (specs, ADRs, tasks, work items). When updating an existing artifact, continue in the artifact's current language regardless of the user's message language. Template section headings (e.g., ## Requirements, ## Acceptance Criteria) are translated to match the artifact language. Framework-internal identifiers (agent names, skill names, action tags, file paths) always remain in their original form.

You are the sub-agent responsible for the **documentation templates** of the SDD Framework. You manage 3 files.

## Operating Modes

### Verification Mode

When requested to **verify status**, for each file listed below:

1. Try to read the existing file in the project
2. Compare with the template embedded in this agent
3. Return the status of each file:
   - **✅ Up to date**: file exists and is identical to the template
   - **🔄 Outdated**: file exists but has differences (include summary: "X lines added, Y removed")
   - **❌ Missing**: file does not exist

To compare, write the template to `/tmp/sdd-init-<name>` and run `diff --unified <existing> /tmp/sdd-init-<name>`.

### Creation Mode

When requested to **create or update files**:

1. Ensure directories exist: `mkdir -p docs/features docs/envisioning docs/architecture/decisions`
2. For each requested file, create it with the exact content from the template below
3. To update: delete the existing one (`rm <file>`) and recreate
4. Clean up temporary files: `rm -f /tmp/sdd-init-*`

---

## Templates

### FILE: docs/features/TEMPLATE.md

```markdown

# Feature Specification: [FEATURE_NAME]

**Created on**: [DATE]  
**Status**: Draft  

## Executive Summary

<!--
  Condensation of the spec into 3-5 key points.
  Serves as a quick reference for the agent and developers.
  Update whenever the spec changes significantly.
-->

- **Objective**: [One sentence describing what the feature does]
- **Primary user**: [Who uses it]
- **Value delivered**: [Why it matters]
- **Scope**: [What is included / excluded]
- **Primary success criterion**: [Most important metric]

## Non-Scope *(required)*

<!--
  Explicitly declare what is NOT part of this feature.
  Protects the scope against implicit expansion and aligns expectations.
  Minimum 1 item.
-->

- [What is out of scope and reason for exclusion]

## Assumptions

<!--
  Document reasonable defaults assumed during specification.
  Example: "Session-based authentication (web standard, no explicit requirement)"
-->

- [Assumption and basis for making it]

## User Scenarios & Tests *(required)*

<!--
  IMPORTANT: User stories must be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning that if you implement only ONE of them,
  you will still have an MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as an independent slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in simple language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g.: "Can be fully tested by [specific action] and delivers [specific value]"]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected result]
2. **Given** [initial state], **When** [action], **Then** [expected result]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in simple language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected result]

---

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in simple language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected result]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content of this section represents placeholders.
  Fill them in with the correct edge cases.
-->

- What happens when [boundary condition]?
- How does the system handle [error scenario]?

## Requirements *(required)*

<!--
  ACTION REQUIRED: The content of this section represents placeholders.
  Fill them in with the correct functional requirements.
-->

### Functional Requirements

- **FR-001**: The system MUST [specific capability, e.g.: "allow users to create accounts"]
- **FR-002**: The system MUST [specific capability, e.g.: "validate email addresses"]  
- **FR-003**: Users MUST be able to [key interaction, e.g.: "reset their password"]
- **FR-004**: The system MUST [data requirement, e.g.: "persist user preferences"]
- **FR-005**: The system MUST [behavior, e.g.: "log all security events"]

*Example of marking unclear requirements:*

- **FR-006**: The system MUST authenticate users via [NEEDS CLARIFICATION: authentication method not specified - email/password, SSO, OAuth?]
- **FR-007**: The system MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]

### Key Entities *(include if the feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships with other entities]

## Success Criteria *(required)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-independent and measurable.
-->

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g.: "Users can complete account creation in less than 2 minutes"]
- **SC-002**: [Measurable metric, e.g.: "System supports 1000 concurrent users without degradation"]
- **SC-003**: [User satisfaction metric, e.g.: "90% of users successfully complete the main task on the first attempt"]
- **SC-004**: [Business metric, e.g.: "Reduce support tickets related to [X] by 50%"]

## Compliance Criteria *(required)*

<!--
  Acceptance tests derived directly from the spec.
  Any implementation must pass all these criteria.
  Format: Input → Expected Output (technology-independent).
-->

### Compliance Cases

| ID | Scenario | Input | Expected Output |
|----|----------|-------|-----------------|
| CC-001 | [Main happy path scenario] | [Valid input data] | [Expected result] |
| CC-002 | [Error scenario] | [Invalid or incomplete data] | [Error message or behavior] |
| CC-003 | [Edge case] | [Boundary or extreme condition] | [Expected behavior] |

<!--
  These criteria serve as a contract between spec and implementation.
  The agent must verify the implementation against these cases.
-->
```

### END FILE

---

### FILE: docs/envisioning/TEMPLATE.md

```markdown
# Envisioning: [Project/Product Name]

> **Status:** [In Discovery / In Validation / Approved]  
> **Last updated:** [YYYY-MM-DD]  
> **Version:** 1.0

---

## 1. Client Context

### 1.1 Direct Client

The team or organization we are serving directly (our client).

| Aspect | Information |
|--------|-------------|
| **Company/Team** | [Name of the company/organization/team that contracted or requested the project] |
| **Domain** | [E.g.: fintech, e-commerce, healthcare, logistics, government] |
| **Team scale** | [Small: <10 devs / Medium: 10-50 devs / Large: 50+ devs] |
| **Channels** | [Web, mobile, API, etc.] |

### 1.2 End Client

The user or consumer served by the direct client.

| Aspect | Information |
|--------|-------------|
| **Profile** | [Who are the end users of the product/service] |
| **Volume** | [Number of users, transactions, or other relevant metric] |
| **Usage context** | [How and where the end client interacts with the product] |

### 1.3 Additional Context

[Describe existing products/systems being consolidated or replaced, if applicable]

---

## 2. Project Focus

### Prioritized Problem

[Describe the main problem this project solves]

| Aspect | Decision |
|--------|----------|
| **Chosen focus** | [What will be solved] |
| **Justification** | [Why this focus was chosen] |
| **Initial scope** | [What is included] |
| **Out of initial scope** | [What was excluded and why] |

---

## 3. Target Users

### 3.1 [User Profile Name 1]

[Profile description]

**Key needs:**
- [Need 1]
- [Need 2]
- [Need 3]

### 3.2 [User Profile Name 2] (if applicable)

[Profile description]

**Key needs:**
- [Need 1]
- [Need 2]

---

## 4. Diagnosis: Known Pain Points

### 4.1 Business Pain Points

| Problem | Impact | Source |
|---------|--------|--------|
| [Pain 1] | [Cost, revenue loss, churn, etc.] | [Data origin] |
| [Pain 2] | [Measurable impact] | [Data origin] |
| [Pain 3] | [Measurable impact] | [Data origin] |

**Main impact area:**
- [ ] End user experience
- [ ] Internal operations
- [ ] Costs/efficiency
- [ ] Growth/scalability
- [ ] Multiple areas

### 4.2 Technical Pain Points

Categories: Fragmentation, Scalability, Security, Observability, Agility, Integration, Performance, Maintainability

| Category | Problem | Impact |
|----------|---------|--------|
| [Category] | [Description] | [Impact on system/business] |
| [Category] | [Description] | [Impact on system/business] |
| [Category] | [Description] | [Impact on system/business] |

---

## 5. User Journey

[Mapping of the main journey phases]

:::mermaid
flowchart LR
    subgraph Phase1[Phase 1: Name]
        A1[Step 1] --> A2[Step 2]
    end
    
    subgraph Phase2[Phase 2: Name]
        B1[Step 1] --> B2[Step 2]
    end
    
    Phase1 --> Phase2
:::

### 5.1 Phase: [Phase Name]

| Moment | Channel | Status |
|--------|---------|--------|
| [Moment 1] | [Channel] | [OK / CRITICAL / TO MAP] |
| [Moment 2] | [Channel] | [Status] |

---

## 6. Strategic Objectives

### Business Objective

[What does the business want to achieve? Focus on measurable outcomes.]

### Technical Objective

[How will technology enable the business objective?]

### Success KPIs

| KPI | Target | Current Baseline |
|-----|--------|------------------|
| [Metric 1] | [Target value] | [Current value if known] |
| [Metric 2] | [Target value] | [Current value if known] |
| [Metric 3] | [Target value] | [Current value if known] |

---

## 7. Constraints and Considerations

### Critical Constraints

[Regulatory, budget, deadline, mandatory technologies, compatibility]

- [Constraint 1]
- [Constraint 2]

### System Dependencies

[Legacy systems, external APIs, third-party integrations]

- [Dependency 1]
- [Dependency 2]

### Non-Negotiable Principles

[E.g.: API-first, Mobile-first, Zero downtime]

- [Principle 1]
- [Principle 2]

---

## 8. Prioritization Hypotheses

| Priority | Area | Justification |
|----------|------|---------------|
| **P0** | [Critical area] | [Why it is top priority] |
| **P1** | [Important area] | [Justification] |
| **P2** | [Secondary area] | [Justification] |

---

## 9. Open Items

### Decisions Awaiting Validation

| Decision | Status | Responsible |
|----------|--------|-------------|
| [Decision 1] | To be defined | [Name] |
| [Decision 2] | To be defined | [Name] |

### Missing Information

| Item | Impact |
|------|--------|
| [Information 1] | [Why it is needed] |
| [Information 2] | [Why it is needed] |

### Hypotheses to Validate

| Hypothesis | Required Validation |
|------------|---------------------|
| [Hypothesis 1] | [How to validate] |
| [Hypothesis 2] | [How to validate] |

---

## 10. Next Steps

- [ ] [Action 1] (Responsible, Deadline)
- [ ] [Action 2] (Responsible, Deadline)
- [ ] [Action 3] (Responsible, Deadline)

### Project Team

**Client:** [Names and roles]

**Technical team:** [Names and roles]

---

## References

- [Link to relevant document 1]
- [Link to relevant document 2]

---

## Update History

| Date | Author | Change |
|------|--------|--------|
| [YYYY-MM-DD] | [Name] | Document creation |
```

### END FILE

---

### FILE: docs/architecture/decisions/ADR-TEMPLATE.md

```markdown
# [Decision Domain]

<!--
  File name: NNNN-domain.md
  Use the decision domain/area, not the choice made.
  Examples: data-persistence, authentication, inter-service-communication
-->

**Status**: [Proposed | Accepted | Superseded by NNNN]
**Date**: [YYYY-MM-DD]

## Context

Describe the problem or need that motivated this decision.

## Priorities and Requirements (ordered)

<!--
  List what actually matters for this decision, in order of importance.
  Be specific and quantifiable when possible.
  This defines the evaluation criteria for the options.
  People often disagree on decisions because they prioritize differently —
  making priorities explicit is where real alignment happens.
-->

1. **[Priority name]** — [Why it matters. What is the business or technical requirement?]
2. **[Priority name]** — [Why it matters?]
3. **[Priority name]** — [Why it matters?]

## Options Considered

### Option 1: [Name]

[Description of the approach]

**Evaluation against priorities**:
- **[Priority 1]**: [How this option meets or fails to meet it. ✅/❌/⚠️]
- **[Priority 2]**: [How this option meets or fails to meet it]
- **[Priority 3]**: [How this option meets or fails to meet it]

### Option 2: [Name]

[Description of the approach]

**Evaluation against priorities**:
- **[Priority 1]**: [How this option meets or fails to meet it. ✅/❌/⚠️]
- **[Priority 2]**: [How this option meets or fails to meet it]
- **[Priority 3]**: [How this option meets or fails to meet it]

## Decision

Describe the chosen option and link the justification to the ranked priorities above.

## Implementation Notes (optional)

<!--
  Practical considerations for whoever will implement this decision.
  Include only if there is information that does not belong in the feature's plan.md,
  such as: migration strategy, feature flags, rollout order, or
  considerations that impact multiple features.
  If there are no relevant notes, remove this section.
-->

## References

* 
```

### END FILE
