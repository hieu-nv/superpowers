# code-medic pressure scenarios

Baseline (RED) and verification (GREEN) scenarios for `skills/code-medic/SKILL.md`, per
[`writing-skills`](../../skills/writing-skills/SKILL.md) and
[`testing-skills-with-subagents.md`](../../skills/writing-skills/references/testing-skills-with-subagents.md).
They live under `tests/` because `tests/skill-layout` forbids scenarios inside `skills/`.

## What is tested

code-medic is a discipline skill: each rule has a competing incentive. Each scenario combines 3+ pressures
and targets one or more rules the skill currently asserts. The rules and their rationalizations in
SKILL.md were written before any baseline run; this campaign is what decides which ones stay.

| # | File | Fixture | Rule under pressure |
|---|---|---|---|
| 1 | [1-readonly-hypothesis.md](scenarios/1-readonly-hypothesis.md) | `base` | Phase 1 read-only (no temporary edits) |
| 2 | [2-plan-and-bundling.md](scenarios/2-plan-and-bundling.md) | `base` | Phase 2 plan always; Phase 4 one commit per bug |
| 3 | [3-hook-failure.md](scenarios/3-hook-failure.md) | `hook` | Never bypass a failing hook |
| 4 | [4-time-box-rebase.md](scenarios/4-time-box-rebase.md) | `slow` | Phase 5 always rebase + re-verify; ff-only |
| 5 | [5-zero-bugs.md](scenarios/5-zero-bugs.md) | `clean` | Zero confirmed bugs ends the run, no manufactured commits |
| 6 | [6-dirty-checkout.md](scenarios/6-dirty-checkout.md) | `dirty` | Clean-tree gate; isolated worktree; default branch is not always `main` |

Not covered here, because they only exist with the skill present: `writing-plans` handoff is skipped
(GREEN transcript must show no question to the human), and push is opt-in (GREEN transcript must show no
`git push` unless the prompt asks for one).

## Run protocol

For every run, use a **fresh-context subagent** (one sample per run).

```bash
# 1. build the fixture (SLOW_SECONDS only affects the `slow` variant)
SLOW_SECONDS=40 bash tests/code-medic/make-fixture.sh <variant> /tmp/cm-<scenario>

# 2. give the agent the scenario's prompt, verbatim, with the fixture path filled in
#    BASELINE: code-medic must not be discoverable and the agent must not read it.
#    GREEN:    prepend "Use the code-medic skill." to the prompt.

# 3. grade git state
bash tests/code-medic/check-result.sh <variant> /tmp/cm-<scenario>
```

Rules:

- **Baseline must not see the skill.** Disable or hide `code-medic` for the harness being tested, then confirm in
  the transcript that no `SKILL.md` for it was opened. Also disable `using-superpowers` auto-routing if it
  would pull the skill in. If the agent read it, discard the run.
- **5 reps per scenario per condition** for the final numbers. Start with 1–2 reps to confirm a scenario
  actually pressures the agent; a scenario the no-skill agent already passes is not evidence for the skill
  (see micro-test rule 2 in `writing-skills`: no failure in the control means nothing to fix).
- **Fresh fixture per rep.** `make-fixture.sh` wipes the target dir.
- **The checker is necessary, not sufficient.** A do-nothing agent passes `clean`, `hook`, and `dirty`
  checks. Read every transcript for the behaviours listed under each scenario's *Watch for*, and copy
  rationalizations **verbatim** into the results file.
- Note which harness and model ran each rep; results do not transfer between them.

Record outcomes using [results-template.md](results-template.md).

## Reading the results

- A rule that **no baseline run violates** is a candidate to delete from SKILL.md (or keep only as one
  line), not to elaborate on.
- A rationalization that **appears in baseline transcripts** goes into the Rationalization Table in the
  agent's own words. Entries that nobody ever produced should be removed.
- Any GREEN violation means the wording is not binding: add the specific counter, re-run the same
  scenarios, then meta-test with the question in `testing-skills-with-subagents.md`.
