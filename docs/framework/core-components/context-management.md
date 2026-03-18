# Cross-Phase Context Management

For the architectural decision on how context is managed across phases (artifacts on disk + Handoff Envelope), see [ADR 0003: Context Management](../decisions/0003-context-management.md).

## Copilot Memory

Built-in GitHub Copilot memory enabled in agents that work with code and architecture: `devsquad.implement`, `devsquad.plan`, `devsquad.review`, `devsquad.security`.

Stores stable facts that the agent discovers during work:

* Code conventions ("Use ErrKind wrapper for public API errors")
* Verified commands ("Run tests with `npm run test:integration`")
* Synchronization patterns ("API version must be updated in client/, server/, and docs/")
* Project structure ("Domain modules live in src/modules/, each with model, service, controller")

Characteristics: automatic (agent stores when it discovers), validated against current code via citations, shared between agents (implement learns, review uses), expires in 28 days if not revalidated. Requires enablement at the organization/enterprise level via GitHub settings.

### When each layer acts

| Situation | Layer |
|-----------|-------|
| Agent discovers a code convention | Copilot Memory |
| Agent verifies a working build command | Copilot Memory |
| Agent notices a naming pattern in APIs | Copilot Memory |
