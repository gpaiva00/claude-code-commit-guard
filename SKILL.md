---
name: commit-guard
description: Use before every git commit. Runs the project's tests and refuses to commit while they fail, names the failing tests, and scans the staged diff for secrets before committing.
---

# commit-guard

Purpose: block a bad commit before it lands.

## Steps

1. Run `git status --short`. Stage only the files that belong to the change. Never use `git add -A` if the list includes `.env`, key files or files you did not touch.
2. Scan the staged diff (`git diff --cached`) for secret patterns: `sk_live_`, `sk_test_`, `AKIA`, `-----BEGIN`, `password=`, `api_key`. If one matches, stop and report `file:line`. Do not commit.
3. Find the test command in `package.json` (`scripts.test`) or the project's equivalent. Run it.
4. If any test fails: **do not commit**. Report each failing test by its exact name and stop.
5. If all tests pass: write a subject line in the imperative, 72 characters or fewer. Commit.
6. Reply with the commit hash and the number of tests that passed.

## Rules

- Never pass `--no-verify`.
- Never commit to fix a failing test. Fix the code first, then run this skill again.
