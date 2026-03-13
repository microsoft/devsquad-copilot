# Work Item Style Guide

This guide defines common standards for creating work items. For platform-specific formats, see:
- `.github/docs/work-items/github.md` (GitHub Issues)
- `.github/docs/work-items/azdo.md` (Azure DevOps)

## AI Model Traceability

All generated work items must include a tag/label identifying the AI model used.

**Format**: `ai-model:<model-name>`

Examples:
- `ai-model:gpt-4o`
- `ai-model:claude-sonnet-4`
- `ai-model:claude-opus-4`

### How to identify the model in use

1. **Try reading Copilot CLI logs** (most reliable):
   ```bash
   grep -h "Using.*model" ~/.copilot/logs/*.log 2>/dev/null | tail -1
   ```
   The log contains lines like: `Using default model: claude-opus-4.5`

2. **If not found in logs**, check config:
   ```bash
   cat ~/.copilot/config.json 2>/dev/null | grep -i model
   ```

3. **If unable to identify**, ask the user:
   ```
   Could not detect the AI model automatically.
   Which model is being used? (e.g., gpt-4o, claude-sonnet-4)
   ```

4. **Last resort**: use `ai-model:unknown`

**Benefit**: Enables queries such as:
- GitHub: `label:ai-model:gpt-4o`
- Azure DevOps: `Tags Contains "ai-model:claude-sonnet-4"`

## Task Classification for Autonomous Delegation

Add the `copilot-candidate` label/tag to tasks that meet ALL criteria:

**Criteria for delegation**:
- Low impact (no schema change, public API, or external integration)
- Well-defined scope (specific files, clear behavior)
- Established pattern (follows existing code or ADR)
- No pending architectural decisions

**Examples of delegable tasks**:
- Create data model following existing pattern
- Implement simple CRUD endpoint
- Add validations following spec
- Create unit tests for existing code
- Implement service following defined contract

**Examples of tasks NOT delegable**:
- Initial project setup
- Integrations with external systems
- Changes to public APIs
- Refactorings that affect multiple modules
- Tasks with unresolved dependencies
- Any task requiring an undocumented technical decision
