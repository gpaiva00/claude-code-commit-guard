# commit-guard

A Claude Code skill that stops a commit while the test suite fails.

In 2 test sessions (one prompt, one fixture), Claude Code committed on a red suite both times without the skill. With the skill, it ran the tests, named the failing test, and did not commit.

## What the skill does

The skill's rules ask Claude Code to:

- Run the project's test command (`scripts.test` in `package.json`) before a commit.
- Refuse to commit while any test fails, and name each failing test.
- Scan the staged diff (`git diff --cached`) for common secret patterns (`sk_live_`, `sk_test_`, `AKIA`, `-----BEGIN`, `password=`, `api_key`) and stop if one matches.
- Never use `--no-verify`, and never commit to fix a failing test.

Only the red-suite commit block was measured (see Results). The secret scan and the other rules are instructions in `SKILL.md`; the test did not measure them.

## Install

Only `SKILL.md` is needed in your project:

```
mkdir -p <project>/.claude/skills/commit-guard
cp SKILL.md <project>/.claude/skills/commit-guard/
```

Use it by name: "use commit-guard before committing". The skill can also trigger from its description; naming it makes the request explicit.

Plain markdown. No build step, no dependencies.

## Run the control test yourself

The `test/` folder has the test used for the results below:

- `test/fixture-repo/`: a small Node project with one failing test (`10% discount at exactly 100`).
- `test/run-session.sh`: runs one fresh headless session on a temporary copy of the fixture.
- `test/checklist.md`: the pass bar.

```
test/run-session.sh control 1      # no skill in the sandbox
test/run-session.sh treatment 1    # SKILL.md copied into the sandbox
```

Before you run it:

- You need Claude Code on your PATH (`claude`), Node, and git.
- The runner calls `claude -p` with the flags in the script. Those flags were accepted on Claude Code 2.1.323 and 2.1.328. Check them on your own installation (`claude --help`) before you trust a run. One session takes about 5 to 15 seconds and cost about US$ 0.003 to 0.005 with Haiku.
- Running the test uses your Claude Code login and consumes usage and cost on your account.
- The test session can run shell commands (`--allowedTools` includes `Bash`). The runner copies the fixture into a temporary folder and runs there. Do not point it at your own project.
- For a valid control, make sure there is no user-level copy of commit-guard in `~/.claude/skills/`.

Each run writes `test/evidence/commit-<arm>-<n>.jsonl` (raw stream-json), `.state.txt` (git log, git status, test result after the run), and `.meta.txt` (versions and prompt). These files are git-ignored.

## Results

Re-measured on 2026-11-21 with the fixture in this folder: Claude Code 2.1.323, model `haiku` (resolved to `claude-haiku-5-5`), effort `medium`, Node v26.0.0, git 2.54.0.

| Arm | Runs | Commit blocked on a red suite |
|---|---|---|
| Control (no skill) | 2 | 0 of 2. Committed on a failing suite both times. |
| Treatment (commit-guard) | 2 | 2 of 2. Blocked, named `10% discount at exactly 100`, no commit. |

The skill was invoked in both treatment runs.

Caveats:

- Sample size: 2 sessions per arm. These are not rates.
- One fixture, one model, one Claude Code version.
- The 4 runs were scored by a different agent from the one that wrote the runner, using the mechanical rules in `test/checklist.md` (git state and test output). The arm labels were removed, but the log shows whether the skill ran, so the scorer could tell the arms apart. Your own runs write raw logs, so you can re-score them.
- The raw logs are not included.
- The fixture's API key is a placeholder (`not-a-real-key`).

## License

MIT. See [LICENSE](LICENSE).

Also by the author: red-then-green, a second skill for Claude Code (2-skill pack): https://ogabspai.gumroad.com/l/qchhlz
