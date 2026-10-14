import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const hook = fileURLToPath(new URL('../detect-lsp-servers.sh', import.meta.url));

for (const [name, project, user] of [
  ['no configuration', false, false],
  ['project configuration only', true, false],
  ['user configuration only', false, true],
  ['both configuration files', true, true],
]) {
  test(`discovers ${name} without claiming server health`, () => {
    const root = mkdtempSync(join(tmpdir(), 'devsquad-lsp-'));
    try {
      const home = join(root, 'home');
      mkdirSync(join(root, '.github'), { recursive: true });
      mkdirSync(join(home, '.copilot'), { recursive: true });
      if (project) writeFileSync(join(root, '.github/lsp.json'), '{}');
      if (user) writeFileSync(join(home, '.copilot/lsp-config.json'), '{}');
      const results = [];
      for (let run = 0; run < 2; run++) {
        const warnings = join(root, 'warnings');
        const output = execFileSync('bash', ['-c', 'bash "$1" 2>"$2"', 'test', hook, warnings], {
          cwd: root,
          env: { ...process.env, HOME: home },
          encoding: 'utf8',
        });
        const status = readFileSync(join(root, '.memory/lsp-status.md'), 'utf8');
        assert.equal(output, '');
        assert.ok(status.includes(`Project Config (.github/lsp.json): ${project ? 'yes' : 'no'}`));
        assert.ok(status.includes(`User Config (~/.copilot/lsp-config.json): ${user ? 'yes' : 'no'}`));
        assert.match(status, /runtime health.*not checked/i);
        assert.match(status, /VS Code.*not checked/i);
        const warning = readFileSync(warnings, 'utf8');
        if (project || user) {
          assert.equal(warning, '');
        } else {
          assert.equal(warning.trim().split('\n').length, 1);
          const message = JSON.parse(warning);
          assert.equal(message.decision, 'warn');
          assert.match(message.reason, /lsp-setup/);
          assert.match(message.reason, /plugin-provided/i);
          assert.match(message.reason, /VS Code/);
          assert.doesNotMatch(message.reason, /No LSP servers configured/);
        }
        results.push({ status, warning });
      }
      assert.deepEqual(results[0], results[1]);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });
}
