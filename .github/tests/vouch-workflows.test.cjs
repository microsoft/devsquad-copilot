const assert = require("node:assert/strict");
const { execFileSync } = require("node:child_process");
const { join } = require("node:path");
const { test } = require("node:test");

const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;
const trustedSha = "a".repeat(40);
const repo = { owner: "microsoft", repo: "devsquad-copilot" };
const fileResponse = text => ({
  data: { type: "file", encoding: "base64", content: Buffer.from(text).toString("base64") }
});

function fixture({ author = "alice", association = "NONE", vouches = "@alice\n", read, comment, close } = {}) {
  const reads = [];
  const comments = [];
  const updates = [];
  const failures = [];
  const context = {
    repo,
    sha: trustedSha,
    actor: "maintainer",
    payload: { pull_request: {
      number: 17,
      author_association: association,
      user: { login: author },
      head: { sha: "b".repeat(40), repo: { owner: { login: author }, name: "fork" } },
      base: { sha: "c".repeat(40) }
    } }
  };
  const github = { rest: {
    repos: { getContent: async params => {
      reads.push(params);
      return read ? read(params) : fileResponse(vouches);
    } },
    issues: { createComment: async params => {
      comments.push(params);
      if (comment) await comment(params);
    } },
    pulls: { update: async params => {
      updates.push(params);
      if (close) await close(params);
    } }
  } };
  const core = { info() {}, setFailed: message => failures.push(message) };
  return { github, context, core, reads, comments, updates, failures };
}

function assertAllowed(state) {
  assert.deepEqual(state.failures, []);
  assert.deepEqual(state.comments, []);
  assert.deepEqual(state.updates, []);
}

for (const [file, job] of [["block-pr.yml", "check"], ["auto-close-pr.yml", "close"]]) {
  const path = join(__dirname, "../workflows", file);
  const workflow = JSON.parse(execFileSync("ruby", ["-ryaml", "-rjson", "-e",
    "puts JSON.generate(YAML.safe_load(File.read(ARGV[0]), aliases: true))", path], { encoding: "utf8" }));
  const script = workflow.jobs[job].steps.find(step => step.with?.script).with.script;
  const execute = new AsyncFunction("github", "context", "core", script);
  const run = state => execute(state.github, state.context, state.core);

  function assertDenied(state) {
    if (job === "check") {
      assert.deepEqual(state.failures, ["User not vouched"]);
      assert.deepEqual(state.comments, []);
      assert.deepEqual(state.updates, []);
    } else {
      assert.deepEqual(state.failures, []);
      assert.equal(state.comments.length, 1);
      assert.equal(state.comments[0].owner, repo.owner);
      assert.equal(state.comments[0].repo, repo.repo);
      assert.equal(state.comments[0].issue_number, 17);
      assert.match(state.comments[0].body, /Open a Discussion under Vouch Request/);
      assert.ok(state.comments[0].body.startsWith(`Thanks for the contribution, @${state.context.payload.pull_request.user.login}!`));
      assert.deepEqual(state.updates, [{ ...repo, pull_number: 17, state: "closed" }]);
    }
  }

  test(`${file}: permits exact handles, ignoring case and surrounding whitespace`, async () => {
    const state = fixture({ author: "Alice", vouches: "@bob\n  @ALICE \r\n" });
    await run(state);
    assertAllowed(state);
  });

  test(`${file}: rejects partial username matches`, async () => {
    const state = fixture({ vouches: "@alice-admin\n@malice\n@alice2\n" });
    await run(state);
    assertDenied(state);
  });

  test(`${file}: rejects an author missing from the list even when the actor is vouched`, async () => {
    const state = fixture({ vouches: "@maintainer\n" });
    await run(state);
    assertDenied(state);
  });

  test(`${file}: an empty vouch list does not approve an outsider`, async () => {
    const state = fixture({ vouches: "" });
    await run(state);
    assertDenied(state);
  });

  test(`${file}: preserves all association exemptions without reading the list`, async () => {
    for (const association of ["OWNER", "MEMBER", "COLLABORATOR", "CONTRIBUTOR"]) {
      const state = fixture({ association, read: () => { throw new Error("Must not read the vouch list"); } });
      await run(state);
      assertAllowed(state);
      assert.deepEqual(state.reads, []);
    }
  });

  test(`${file}: a fork cannot vouch for its own author`, async () => {
    const state = fixture({ author: "mallory", read: params => fileResponse(
      params.owner === repo.owner && params.repo === repo.repo &&
      params.ref === trustedSha && params.path === ".github/VOUCHED.md" ? "@alice\n" : "@mallory\n"
    ) });
    await run(state);
    assertDenied(state);
    assert.deepEqual(state.reads, [{ ...repo, path: ".github/VOUCHED.md", ref: trustedSha }]);
  });

  test(`${file}: rejects a mutable vouch-list reference without taking moderation actions`, async () => {
    const state = fixture();
    state.context.sha = "main";
    await assert.rejects(run(state), /immutable trusted workflow commit SHA/);
    assertAllowed(state);
    assert.deepEqual(state.reads, []);
  });

  test(`${file}: missing files and API outages fail without taking moderation actions`, async () => {
    for (const status of [404, 503]) {
      const error = Object.assign(new Error(`GitHub API failure: ${status}`), { status });
      const state = fixture({ read: () => { throw error; } });
      await assert.rejects(run(state), error);
      assertAllowed(state);
    }
  });

  test(`${file}: unexpected API content fails without taking moderation actions`, async () => {
    for (const data of [[], { type: "file", encoding: "none", content: "" }, { type: "file", encoding: "base64" }]) {
      const state = fixture({ read: () => ({ data }) });
      await assert.rejects(run(state), /base64-encoded file/);
      assertAllowed(state);
    }
  });

  if (job === "close") {
    test(`${file}: a comment failure is visible and prevents closure`, async () => {
      const error = new Error("Comment denied");
      const state = fixture({ vouches: "@bob\n", comment: () => { throw error; } });
      await assert.rejects(run(state), error);
      assert.equal(state.comments.length, 1);
      assert.deepEqual(state.updates, []);
    });

    test(`${file}: a close failure is visible`, async () => {
      const error = new Error("Close denied");
      const state = fixture({ vouches: "@bob\n", close: () => { throw error; } });
      await assert.rejects(run(state), error);
      assert.equal(state.comments.length, 1);
      assert.equal(state.updates.length, 1);
    });
  }
}
