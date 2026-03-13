# MCP Error Handling

Rules for MCP server calls (GitHub, Azure DevOps) that may fail intermittently.

## Retry

1. If a call fails, wait 2-3 seconds and try again
2. Maximum of 3 attempts per operation
3. If it fails after 3 attempts:
   - Inform the user which operation failed
   - Ask if they want to continue with the next operations or pause
   - Record the items that were not created/updated for manual retry

```
Error executing: [operation]
Attempts: 3/3

[C] Continue with the next items
[P] Pause and show summary of what was done
[R] Try this item again
```

4. At the end, always show a summary of what was created/updated vs what failed
