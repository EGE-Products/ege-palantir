<!--
Palantír PR description template.

Keep sections that apply, delete the ones that don't. Don't leave empty
section headers in the final description — a missing section says "this
PR doesn't need that callout"; an empty one says "I forgot to think about it".
-->

## Linear

<!-- Required. One ticket per PR is the norm; add extras if this PR genuinely
     closes more than one. The "Closes" verb auto-links and auto-closes the
     ticket when the PR merges. -->

- Closes EGE-XXX

## Summary

<!-- 1–3 bullets on *what changed* and *why*. Reviewers read this first; if
     they need to read the diff to understand the intent, the summary failed. -->

-
-

## Changes

<!-- Plain-English list of the visible changes. Map back to the ticket's
     acceptance criteria where possible — checking them off here doubles as
     a reviewer's checklist. Delete the bullets that don't apply. -->

- [ ] Models / schemas:
- [ ] Transforms / business logic:
- [ ] Loaders / DB writes:
- [ ] Flow orchestration:
- [ ] Connectors / external IO:
- [ ] Tests:
- [ ] Docs:

## Migrations & DDL

<!-- The Red Book DDL is shared infrastructure. Any change here is high
     blast-radius — call it out explicitly even if the answer is "none". -->

- DDL change: **No** <!-- or "Yes — see migration <id>" -->
- New columns / indexes / constraints:
- Backfill required: **No** <!-- or describe -->
- Rollback plan:

## Scope & forward-compat

<!-- Palantír v0.1 is single-tenant by design (company_id='ege' in code,
     multi-company shape in DDL — see README). If this PR touches that line,
     justify it. -->

- Single-tenant invariant (`company_id = 'ege'` in code, no callers passing
  other values) preserved? **Yes**
- DDL forward-compat (`company_id text NOT NULL` on every transactional
  table) preserved? **Yes**
- If either answer is "No": link the ticket that reauthorized the change.

## Test plan

<!-- Bulleted, runnable steps. "I ran the tests" is not a test plan;
     "`uv run pytest palantir/tests/transforms/test_reps.py -x` — all green"
     is. Include sample inputs / fixture paths where relevant. -->

- [ ] Unit tests pass: `uv run pytest …`
- [ ] Manual flow run against sample QB export (`data/samples/…`)
- [ ] Validation flags inspected on a known-bad row
- [ ] Parquet output round-trips (read back, row count matches)

## Risk & blast radius

<!-- One paragraph. What breaks if this is wrong? Who is affected? Is the
     change behind a feature flag, a new flow, or does it modify the live
     ingest path? -->

-

## Screenshots / sample output

<!-- For UI changes, Prefect run timelines, validation reports, or anything
     visual. Otherwise delete this section. -->

## Reviewer notes

<!-- Anything you want a reviewer to look at *first*, known-flaky tests,
     deferred follow-ups, or open questions. Otherwise delete this section. -->

-

---

<sub>Template lives at `.github/pull_request_template.md`. Edit it when our PR
norms drift — the template is the norm.</sub>
