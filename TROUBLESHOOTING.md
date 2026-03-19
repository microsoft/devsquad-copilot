# Troubleshooting

## Plugin not found after update

**Symptom**: VS Code shows "Plugin source directory '.github/plugins/devsquad' not found in repository" when installing or updating.

**Cause**: VS Code caches the plugin marketplace repository locally and does not always re-fetch on update.

**Fix**:

1. Quit VS Code completely
2. Delete the cached plugin folder:

   ```bash
   # macOS / Linux
   rm -rf ~/Library/Application\ Support/Code/agentPlugins/github.com/microsoft/devsquad-copilot

   # Windows
   rmdir /s "%APPDATA%\Code\agentPlugins\github.com\microsoft\devsquad-copilot"
   ```

3. Restart VS Code
4. Open the Extensions view (`Cmd+Shift+X` / `Ctrl+Shift+X`), search `@agentPlugins devsquad`, and reinstall

## Hooks fail with "command not found"

**Symptom**: Errors like `/bin/sh: detect-repo-platform.sh: command not found` on session start.

**Cause**: Hook scripts paths are not resolving correctly relative to the working directory.

**Fix**:

If using the plugin in a **consumer project** (not this repo), verify that `hooks.json` uses paths relative to the plugin root. The installed plugin resolves paths from its own directory. If you copied hooks manually, ensure the `bash` field in `hooks.json` points to the correct location of the shell scripts.

## Agents not visible in VS Code

**Symptom**: Plugin installs successfully but agents do not appear in the Copilot Chat dropdown.

**Possible causes and fixes**:

1. **VS Code version too old**: Requires VS Code 1.111.0+ with GitHub Copilot Chat extension. Check your version via `Code > About Visual Studio Code`.
2. **Plugins not enabled**: Add the following to your VS Code user settings:

   ```jsonc
   {
     "chat.plugins.enabled": true
   }
   ```

3. **Stale cache**: Clear the plugin cache as described in [Plugin not found after update](#plugin-not-found-after-update).

## GitHub authentication errors

**Symptom**: Work item creation, pull requests, or board operations fail with permission or authentication errors (e.g., `HTTP 401` or `could not determine current user`).

**Possible causes and fixes**:

1. **VS Code users**: The Copilot extension handles authentication via the built-in MCP server. If you see auth errors, sign out and sign back in to GitHub from VS Code (`Ctrl+Shift+P` / `Cmd+Shift+P` then "GitHub: Sign Out", followed by "GitHub: Sign In"). See the [Copilot setup guide](https://code.visualstudio.com/docs/copilot/setup) for detailed steps.
2. **Copilot CLI users**: The GitHub CLI (`gh`) must be installed and authenticated. Run `gh auth login` and verify with `gh auth status`. If already logged in but still failing, try `gh auth refresh` to renew the token.

## MCP servers not connecting

**Symptom**: Skills that depend on MCP servers (Microsoft Learn, Azure) show connection errors.

**Cause**: MCP servers require Node.js and may need environment variables configured.

**Fix**:

1. Verify Node.js 18+ is installed: `node --version`
2. Check that the `.mcp.json` file exists in the plugin directory
3. Restart VS Code after installing Node.js or changing environment variables
