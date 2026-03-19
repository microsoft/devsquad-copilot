# Remote MCP Servers

**Location**: `.vscode/mcp.json`

## GitHub

[github/github-mcp-server](https://github.com/github/github-mcp-server) — Issue, PR, project, label, security, and CI/CD management.

**Enabled toolsets**: `repos`, `issues`, `pull_requests`, `projects`, `labels`, `users`, `copilot`, `actions`, `code_security`, `secret_protection`, `security_advisories`, `dependabot`

| Category | Tools | Agents |
|----------|-------|--------|
| Issues | `issue_read`, `issue_write`, `list_issues`, `search_issues`, `sub_issue_write`, `add_issue_comment`, `list_issue_types` | `envision`, `kickoff`, `specify`, `decompose`, `implement`, `sprint`, `refine` |
| Pull Requests | `create_pull_request`, `list_pull_requests`, `pull_request_read`, `update_pull_request` | `implement`, `refine` |
| PR Reviews | `pull_request_review_write`, `add_comment_to_pending_review` | `review` |
| Projects | `projects_get`, `projects_list`, `projects_write` | `sprint`, `refine` |
| Labels | `list_label`, `label_write` | `decompose` |
| Copilot | `assign_copilot_to_issue` | `decompose` |
| Actions | `get_job_logs` | `implement` |
| Code Security | `list_code_scanning_alerts`, `get_code_scanning_alert` | `security`, `refine` |
| Secret Protection | `list_secret_scanning_alerts`, `get_secret_scanning_alert` | `security` |
| Dependabot | `list_dependabot_alerts`, `get_dependabot_alert` | `security`, `refine` |
| Security Advisories | `list_global_security_advisories`, `list_repository_security_advisories`, `get_global_security_advisory` | `security` |
| Repos | `search_code` | `refine` |

## Azure DevOps

[microsoft/azure-devops-mcp](https://github.com/microsoft/azure-devops-mcp) — Work item, hierarchy, traceability, and board management.

| Category | Tools | Agents |
|----------|-------|--------|
| Work Items | `wit_create_work_item`, `wit_get_work_item`, `wit_update_work_item`, `wit_get_work_items_batch_by_ids` | `envision`, `kickoff`, `specify`, `decompose`, `implement`, `sprint`, `refine` |
| Hierarchy | `wit_add_child_work_items`, `wit_work_items_link` | `kickoff`, `decompose` |
| Search | `search_workitem` | `refine`, `sprint` |

## Azure

[microsoft/mcp](https://github.com/microsoft/mcp/tree/main/servers/Azure.Mcp.Server) — Architecture, deploy, pricing, best practices, and compliance.

| Category | Tools | Agents |
|----------|-------|--------|
| Architecture | `cloudarchitect`, `deploy` | `plan`, `decompose` |
| Pricing | `pricing` | `plan` |
| Well-Architected | `wellarchitectedframework` | `plan`, `security` |
| Best Practices | `get_bestpractices`, `bicepschema`, `azureterraformbestpractices` | `implement` |
| Compliance | `policy`, `role` | `security` |

## Microsoft Learn

[MicrosoftDocs/mcp](https://github.com/MicrosoftDocs/mcp) — Official documentation, APIs, code samples, and security guidance.

| Category | Tools | Agents |
|----------|-------|--------|
| Documentation | `microsoft_docs_search`, `microsoft_docs_fetch` | `plan`, `implement`, `review`, `security` |
| Code Samples | `microsoft_code_sample_search` | `implement` |

## Draw.io

[drawio-mcp](https://www.drawio.com/blog/mcp-server) — Architecture diagrams and threat models.

| Category | Tools | Agents |
|----------|-------|--------|
| Diagrams | `create_diagram` | `plan`, `security` |
