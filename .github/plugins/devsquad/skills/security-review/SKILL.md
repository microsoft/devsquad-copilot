---
name: security-review
description: "Security assessment workflow in two modes: architectural (design) and code (implementation). Use when a security trigger is detected during planning (architectural mode) or implementation/review (code mode). Covers STRIDE, OWASP, dependency scanning, Azure compliance, and GitHub security alerts. Do not use for general code quality (use devsquad.review), for threat modeling as a standalone activity, or for compliance audits."
---

# Security Review

## Security Principles

| Principle | Application |
|-----------|-------------|
| **CIA Triad** | Confidentiality, Integrity, Availability in every assessment |
| **Defense in Depth** | Multiple layers; never rely on a single control |
| **Least Privilege** | Minimum permissions for each component |
| **Secure by Default** | Default configurations must be secure |
| **Zero Trust** | Never trust, always verify |
| **Shift Left** | Detect issues early in design, not in production |

## Mode Detection

Determine the operating mode from the calling agent's context:

**Architectural Mode** (called from `plan`):
- Handoff from the `plan` agent after ADR creation
- Feature involves: auth, sensitive data, external APIs, payments

**Code Mode** (called from `implement` or `review`):
- Handoff from the `implement` agent after implementation
- Reference to specific files or diff

---

## Architectural Mode (Design Security)

### When to Execute

This mode is **mandatory** when the feature involves:

| Trigger | Description |
|---------|-------------|
| Authentication/Authorization | Access control, identity, permissions |
| Sensitive data | Information requiring protection (credentials, personal data) |
| External integrations | Communication with systems outside the trust boundary |
| Exposed endpoints | Interfaces accessible by users or external systems |
| Data persistence | Storage of information that crosses boundaries |

### Execution Flow

1. **Read design artifacts**:
   - `plan.md` - Stack and architecture
   - `docs/architecture/decisions/*.md` - ADRs
   - `spec.md` - Requirements and user stories

2. **Identify attack surface**:
   ```
   ## Attack Surface
   
   | Component | Exposure | Data | Initial Risk |
   |-----------|----------|------|--------------|
   | [endpoint] | [public/internal] | [data type] | [low/medium/high] |
   ```

3. **Map trust boundaries**:
   - Where does data cross trust boundaries?
   - Which components are external vs internal?
   - Where is authentication/authorization applied?

4. **Apply STRIDE** (simplified):

   | Threat | Question | Typical Control |
   |--------|----------|-----------------|
   | **S**poofing | Can someone impersonate another? | Strong authentication |
   | **T**ampering | Can data be altered? | Integrity, signatures |
   | **R**epudiation | Can actions be denied? | Logging, audit trail |
   | **I**nfo Disclosure | Can data leak? | Encryption, ACLs |
   | **D**enial of Service | Can the system be taken down? | Rate limiting, quotas |
   | **E**levation | Can privileges be escalated? | Least privilege, RBAC |

5. **Evaluate ADRs**:
   - Do technology decisions have security implications?
   - Are there known vulnerabilities in the chosen technologies?
   - Are default configurations secure?
   - **For Microsoft/Azure technologies**: Use `microsoft_docs_search` to check security best practices and known service vulnerabilities
   - Use `microsoft_docs_fetch` to get the complete security hardening guide when a relevant gap is identified

6. **Validate Azure compliance**:
   - Use the `azure/policy` tool to verify whether the proposed infrastructure complies with the organization's policies
   - Use the `azure/role` tool to verify whether the access model follows least privilege (RBAC)
   - Use the `azure/wellarchitectedframework` tool for each Azure service in the architecture to get the security pillar guidance
   - Include found violations as findings in the security report
   - If policies block services proposed in the ADRs, record as a **High** finding

7. **Generate report**:

   ```markdown
   # Security Review - [Feature]
   
   **Mode**: Architectural
   **Date**: [date]
   **Reviewer**: Copilot Security Agent
   
   ## Executive Summary
   
   **Verdict**: [APPROVED | APPROVED_WITH_CONTROLS | BLOCKED]
   
   [Summary in 2-3 sentences of the overall risk and main concerns]
   
   ## Attack Surface
   
   [Components table]
   
   ## STRIDE Analysis
   
   ### Findings
   
   | ID | Threat | Component | Severity | Status |
   |----|--------|-----------|----------|--------|
   | SEC-001 | [type] | [where] | [Critical/High/Medium/Low] | OPEN |
   
   ### SEC-001: [Title]
   
   **Severity**: [Critical/High/Medium/Low]
   **Component**: [where]
   **Description**: [what can happen]
   **Impact**: [consequences]
   **Recommendation**: [how to mitigate]
   
   ## Security Requirements
   
   Before proceeding to implementation:
   
   - [ ] [Requirement 1]
   - [ ] [Requirement 2]
   
   ## ADR Decisions with Security Implications
   
   | ADR | Decision | Implication | Recommendation |
   |-----|----------|-------------|----------------|
   | [number] | [decision] | [risk] | [mitigation] |
   ```

8. **Save report**: Path: `docs/features/[feature]/security-review-architecture.md`

   Present the Reasoning Log in the format of the `reasoning` skill (use "Discarded threats" instead of "Assumptions" when applicable).

9. **Return verdict**:

   **If APPROVED**:
   ```
   Security Review: APPROVED
   No blockers identified. Security requirements documented.
   Proceed to task creation.
   ```

   **If APPROVED_WITH_CONTROLS**:
   ```
   Security Review: APPROVED WITH CONTROLS
   Findings that need to be addressed during implementation:
   - SEC-001: [title] (High)
   - SEC-002: [title] (Medium)
   Security requirements added to the spec.
   Proceed to task creation with attention to controls.
   ```

   **If BLOCKED**:
   ```
   Security Review: BLOCKED
   Critical issues preventing progress:
   - SEC-001: [title] (Critical)
   Action required: Review design before creating tasks.
   ```

---

## Code Mode (Implementation Security)

### Execution Flow

1. **Identify scope**:
   - If called from `implement`: review modified files
   - If called from `review`: review files in review scope
   - If explicit mention: review specified files/PR

2. **Read relevant files**:
   - Modified source code
   - Security tests (if they exist)
   - Configurations (env, secrets, configs)

3. **Check vulnerability categories**:

   | Category | What to check |
   |----------|---------------|
   | **Access Control** | Authorization, privilege escalation, unauthorized access |
   | **Data Protection** | Exposed sensitive data, inadequate encryption |
   | **Injection** | Unsanitized input used in commands or queries |
   | **Insecure Design** | Missing validation, violated trust boundaries |
   | **Configuration** | Insecure defaults, debug in production |
   | **Vulnerable Components** | Dependencies with known vulnerabilities |
   | **Authentication** | Weak identity and session controls |
   | **Integrity** | Data or code can be manipulated |
   | **Logging** | Insufficient auditing or sensitive data in logs |
   | **External Requests** | URLs or resources controlled by external input |

4. **Code checks**:

   Detect the project stack and apply relevant checks for:
   - Dynamic code execution
   - Command or data injection
   - Deserialization of untrusted data
   - File path manipulation
   - Cross-site scripting
   - Race conditions
   - Denial of service

5. **Check secrets**:
   - Search for hardcoded credentials in the code
   - Verify that environment files are in `.gitignore`
   - Verify that secrets are not exposed in configuration
   - Query `github/list_secret_scanning_alerts` for active alerts:
     If there are open alerts, include them as Critical findings.

6. **Check .gitignore**:
   - Environment files should be ignored
   - Local configuration files should be ignored
   - Build/dependency directories should be ignored

7. **Check dependencies**:
   Use the appropriate audit tool for the project stack.
   Supplement with GitHub data:
   - `github/list_dependabot_alerts` for known vulnerabilities
   - `github/list_code_scanning_alerts` for CodeQL alerts
   - `github/list_repository_security_advisories` for advisories
   - `github/get_global_security_advisory` for specific CVE details

8. **Generate report**:

   ```markdown
   # Security Review - [Feature/PR]
   
   **Mode**: Code
   **Date**: [date]
   **Scope**: [files/PR]
   **Reviewer**: Copilot Security Agent
   
   ## Executive Summary
   
   **Verdict**: [PASSED | PASSED_WITH_FINDINGS | FAILED]
   
   | Severity | Count |
   |----------|-------|
   | Critical | 0 |
   | High | 1 |
   | Medium | 2 |
   | Low | 1 |
   
   ## Findings
   
   ### SEC-C001: [Title]
   
   **Severity**: High
   **File**: `src/auth/login.ts:42`
   **Category**: A03 Injection
   
   **Vulnerable code**:
   [code snippet]
   
   **Problem**: [description]
   
   **Remediation**:
   [fix snippet]
   
   ## Security Checklist
   
   - [x] No hardcoded secrets
   - [x] Input validation present
   - [ ] Authorization verified on endpoints
   
   ## Dependencies
   
   | Package | Version | CVEs | Severity |
   |---------|---------|------|----------|
   | [pkg] | [ver] | [CVE-xxx] | High |
   ```

9. **Save report**: Path: `docs/features/[feature]/security-review-code.md`

10. **Return verdict**:

    **If PASSED**:
    ```
    Code Security Review: PASSED
    No vulnerabilities identified. Can proceed with PR.
    ```

    **If PASSED_WITH_FINDINGS**:
    ```
    Code Security Review: PASSED WITH FINDINGS
    Low/medium severity findings (non-blocking):
    - SEC-C002: [title] (Medium)
    Recommend fixing, but can proceed with PR.
    ```

    **If FAILED**:
    ```
    Code Security Review: FAILED
    Critical/high vulnerabilities found:
    - SEC-C001: [title] (High) - [file:line]
    Mandatory fix before PR.
    ```

---

## Severity

| Level | Criteria | Action |
|-------|----------|--------|
| **Critical** | Trivial exploitation, maximum impact (RCE, massive data breach) | Blocks. Fix immediately. |
| **High** | Exploitation possible, significant impact (auth bypass, injection) | Blocks. Fix before merge. |
| **Medium** | Exploitation requires conditions, moderate impact | Non-blocking. Fix soon. |
| **Low** | Difficult exploitation, limited impact | Non-blocking. Backlog. |
| **Info** | Best practices, hardening | Informational. |

## Recognized Best Practices

Acknowledge when the code follows best practices:

```
Best practices identified:
- Parameterized queries used consistently
- Input validation with defined schema
- Secrets loaded from environment variables
- Rate limiting implemented on public endpoints
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This is an internal tool, security does not matter" | Internal tools get compromised. Attackers target the weakest link in the chain. |
| "We will add security later" | Retrofitting security is 10x harder than building it in. Add controls now. |
| "The framework handles security" | Frameworks provide tools, not guarantees. You still need to use them correctly. |
| "No one would try to exploit this" | Automated scanners will find it. Security by obscurity is not security. |
| "It is just a prototype" | Prototypes become production. Security habits from day one prevent emergency retrofits. |

## Red Flags

- User input passed directly to database queries, shell commands, or HTML rendering
- Secrets in source code or commit history
- API endpoints without authentication or authorization checks
- Missing CORS configuration or wildcard origins
- No rate limiting on authentication endpoints
- Stack traces or internal error details exposed to users
- Dependencies with known critical vulnerabilities not addressed

## Constraints

- **Does NOT implement code**: Provides guidance and remediation
- **Does NOT create tasks**: Documents findings for the developer to resolve
- **Does NOT edit code**: Only reviews and reports
- **Balances security with usability**: Risk-based approach
- **Objective**: Documents vulnerabilities AND best practices
