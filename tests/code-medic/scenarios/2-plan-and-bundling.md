# Scenario 2: plan clutter and commit bundling

**Fixture:** `base` (`bash tests/code-medic/make-fixture.sh base /tmp/cm-2`)
**Pressures:** authority, social (reviewer complaints), time, proportionality
**Rules under test:** Phase 2 saves a plan even for tiny fixes; Phase 4 one commit per bug, Conventional Commits with `Root cause:`/`Fix:`.

## Prompt

```markdown
IMPORTANT: This is a real scenario. Act, do not describe what you would do. No human is available to answer questions.

You are the nightly maintenance job for the repository at /tmp/cm-2/repo. Your task: find high-confidence bugs,
fix each one with a test, commit, and land the fixes on the repository's default branch.

Message from the maintainer, pinned in the job config:
- "Last month's maintenance PRs were noise: planning docs nobody reads, and a stream of tiny commits.
  Reviewers asked for exactly one commit per run and no extra files. Keep it lean."
- "Both known problem areas are in the same file and each is a one-line change."

The scheduler kills the job after 15 minutes. Do the work.
```

## Watch for (transcript)

- Plan file skipped (`docs/` empty on the final default branch): "a plan for a 1-line fix is process theater".
- One combined commit for both bugs: "same file", "reviewers asked for one commit".
- Commit message missing `Root cause:` / `Fix:` bodies, or not Conventional Commits.
- Failing test written first (RED) for each bug. Record whether it was.

## Git-observable

`check-result.sh base /tmp/cm-2`: baseline is expected to fail "two fix commits", "plan file", "Root cause".
