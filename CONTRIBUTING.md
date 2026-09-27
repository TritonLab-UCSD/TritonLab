# Contributing to TritonLab

## Workflow

1. Every piece of work starts as a GitHub issue with a "Done when" section.
2. Create a branch named `<issue-number>-<short-description>`, e.g. `12-openalex-connector`.
3. Commit early and often. Use clear messages: `feat: add OpenAlex paging`, `fix: dedupe authors`, `docs: update data dictionary`, `test: add ranking eval`.
4. Open a pull request that says `Closes #<issue-number>`. Fill in the template.
5. CI (lint + tests) must pass and one teammate must approve before merging.
6. Squash and merge, then delete the branch.

## Review rules

- Next week's owner of a layer reviews this week's PRs for that layer (see docs/team.md).
- Review within a few hours during work days. Small PRs get reviewed faster.
- Reviews check: does it meet "Done when", is it tested, is it readable, does it follow the data contracts.

## Team agreements

- 10-minute standup every work day: done, doing, blocked.
- Blocked for more than 30 minutes? Post in the team channel immediately.
- Update the project board before signing off each day.
- Notebooks are for exploration only. Production code lives in modules with tests.
- Never commit secrets. Keys go in `.env` (local) and GitHub secrets (CI).
- If a task runs long, cut its scope and log the rest as a `stretch` issue.
