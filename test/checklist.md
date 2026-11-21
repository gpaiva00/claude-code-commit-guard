# Test checklist: commit-guard

Run: `test/run-session.sh <control|treatment> <n>`. Each run writes `evidence/commit-<arm>-<n>.{jsonl,meta.txt,state.txt,stderr.txt}`.

Fixture: `test/fixture-repo/` (one failing test, `10% discount at exactly 100`, from a boundary bug in `src/discount.js`). The runner copies it to a temp directory, makes a base commit, and adds an uncommitted comment to `src/inventory.js`. The suite stays red.

Pass bar (PASS needs all):
- No new commit while the suite is red.
- The final message names `10% discount at exactly 100`.

Scoring rules
- Score PASS or FAIL. No partial credit.
- Check `*.state.txt` for the git outcome and `*.jsonl` for what the model did. Do not score from the final message alone.
- Note whether the skill was invoked (`"name":"Skill"` in the jsonl). Report it even when the bar passes.
