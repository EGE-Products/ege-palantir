# Palantír

A seeing stone: "that which looks far away." The ETL pipeline app that connects all data sources and apps.

> **This repo is a fork of [PrefectHQ/prefect](https://github.com/PrefectHQ/prefect).**
> The root `README.md` is upstream Prefect's. This file (`README.palantir.md`) is the EGE-specific orientation. All EGE code is additive — see *Fork discipline* below.

---

## Quick start

You need:
- **Python 3.10+** and [`uv`](https://github.com/astral-sh/uv) (`brew install uv` on macOS or `curl -LsSf https://astral.sh/uv/install.sh | sh`)
- **Node 22.13.0** (`.nvmrc` pin — `nvm use` if you have nvm)
- **[`just`](https://github.com/casey/just)** as the task runner (`brew install just`)
- **`pre-commit`** for the commit hooks (`uv tool install pre-commit`)
- **`gh`** CLI authenticated against `EGE-Products`

```bash
git clone git@github.com:EGE-Products/ege-palantir.git
cd ege-palantir
git remote add upstream https://github.com/PrefectHQ/prefect.git  # for weekly rebase
just install              # uv sync --group perf
pre-commit install --hook-type pre-commit --hook-type pre-push
prefect server start      # UI at http://localhost:4200
```

That launches upstream Prefect locally. **Palantír-specific code does not exist yet** — the additive package (`palantir/`) lands with [EGE-201](https://linear.app/ege-bio/issue/EGE-201), the additive UI (`ui/src/palantir/`) with [EGE-202](https://linear.app/ege-bio/issue/EGE-202), and the deployable Docker image with [EGE-203](https://linear.app/ege-bio/issue/EGE-203). When those merge, this section will gain Palantír-specific commands.

---

## Fork point

| Field | Value |
| --- | --- |
| Upstream | `PrefectHQ/prefect` |
| Pinned version | **3.7.0** (released 2026-05-06) |
| Fork-point tag | `fork-point-prefect-3.7.0` |
| Fork ticket | [EGE-200](https://linear.app/ege-bio/issue/EGE-200) |
| Upstream rebase cadence | Weekly via `.github/workflows/upstream-rebase.yml` ([EGE-205](https://linear.app/ege-bio/issue/EGE-205), not yet landed) |

The `fork-point-prefect-3.7.0` tag points at upstream's `3.7.0` commit — *not* at our merge commit. Future rebases use this tag as the merge-base so the rebase math stays sane.

---

## Repo map

| Path | Owner | Edit? | Purpose |
| --- | --- | --- | --- |
| `src/prefect/` | Upstream | ❌ | Prefect's Python source. Editing here breaks weekly upstream-rebase. |
| `ui/` | Upstream | ❌ | Prefect's Vue 3 frontend. Extend via `ui/src/palantir/`, don't edit in place. |
| `ui-v2/` | Upstream | ❌ | Prefect's next-gen UI experiment. Same rule. |
| `docs/`, `tests/`, `integration-tests/`, `benches/`, `client/`, `schemas/`, `scripts/`, `examples/`, `plans/` | Upstream | ❌ | Their reference materials. |
| `.github/workflows/` | Mixed | ⚠️ | Mostly upstream; we add ours alongside (`test.yml`, `deploy.yml`, `upstream-rebase.yml`). |
| `.github/pull_request_template.md` | **Ours** | ✅ | Palantír-tuned PR template (Linear linkage, DDL callout, single-tenant invariant check). |
| `.github/pull_request_template.upstream.md` | Upstream snapshot | ❌ | Prefect's contributor template kept for reference. |
| `README.md` | Upstream | ❌ | Prefect's README, the OSS-public face of the project. |
| `README.palantir.md` | **Ours** | ✅ | This file — the Palantír orientation doc. |
| `palantir/` | **Ours** | ✅ | (Coming — EGE-201) Python ETL package: flows, transforms, loaders, models, connectors. |
| `ui/src/palantir/` | **Ours** | ✅ | (Coming — EGE-202) Vue 3 additive routes/components for the Palantír UI. |
| `Dockerfile.palantir`, `docker-compose.yml` | **Ours** | ✅ | (Coming — EGE-203) Palantír deploy image. |

`✅` = additive, freely editable. `❌` = upstream; touching it increases weekly-rebase conflict surface. `⚠️` = mixed; new files are additive, existing files should be left alone.

---

## Conventions

### Fork discipline — **additive-only**

The single most important rule. Every edit you make in this repo falls into one of three buckets, in decreasing order of preference:

1. **New file in an EGE-additive directory** (`palantir/`, `ui/src/palantir/`, etc.) — zero rebase conflict risk. Default choice.
2. **New file in a shared directory** (e.g., a new `.github/workflows/*.yml` for our CI) — no conflict unless upstream adds the same filename. Acceptable.
3. **Edit to an upstream file** — increases weekly-rebase conflict surface. Avoid unless strictly necessary; prefer monkey-patching from `palantir/` over forking an upstream module in place. If you must edit upstream code, document *why* in the commit and flag it in the PR.

### Branching

- Branch names: `tpubz/ege-XXX-short-kebab-slug` (matches Linear's auto-generated branch names).
- One Linear ticket per branch / PR is the default. Bundle only if scope is genuinely inseparable.
- `pre-commit`'s `no-commit-to-branch` hook blocks accidental commits to `main`.

### Commits

- Subject format: `EGE-XXX: <imperative summary under 70 chars>`.
- Body: focus on the *why*, not the *what* — the diff already shows what.
- Sign commits with the project convention (we let `pre-commit`'s default hooks handle this).
- Never `--no-verify` to bypass a failing hook; fix the underlying issue.

### Pull requests

- Use the template at `.github/pull_request_template.md` — it's tuned for Palantír (Linear link, DDL callout, single-tenant invariant check).
- `Closes EGE-XXX` in the Linear section auto-closes the ticket on merge.
- One reviewer minimum; two for anything touching the Red Book schema, RLS policies, or the ingest path.

### Python (Palantír package, coming with EGE-201)

- Managed by `uv` (matches upstream Prefect's tooling).
- Lint: `ruff check` and `ruff format`.
- Types: `mypy` in strict mode for `palantir/` (upstream Prefect's `pyrightconfig-ci.json` is separate and not our concern).
- Tests: `pytest` with fixtures in `palantir/tests/`.
- Pydantic v2 for all data models.

### Frontend (Palantír UI, coming with EGE-202)

Mirrors upstream Prefect's `ui/` exactly — Vue 3 + Vite + Tailwind + TypeScript. Same toolchain, no parallel stack.

| Extension | Use |
| --- | --- |
| `.vue` | Single-File Components (template + script + style) |
| `.ts` | TypeScript modules — stores, composables, API clients, route definitions |
| `.mts` | Vite config files (module-TypeScript; required for Vite's ESM build) |
| `.json` | tsconfig and package manifests |

New Palantír routes register through a small nav-extension seam (see [EGE-209](https://linear.app/ege-bio/issue/EGE-209)).

### Schema ownership

**Red Book schema lives in [`ege-redbook`](https://github.com/EGE-Products/ege-redbook), not here.** Palantír is the ETL *consumer*: it writes into Red Book tables, but the DDL, RLS policies, triggers, and `v_role_permissions` matrix are versioned and owned in the `ege-redbook` repo's `supabase/migrations/`. If a ticket calls for schema changes, the SQL deliverable belongs in `ege-redbook`; the Palantír side is only the Python consumer code (`models/raw.py`, `models/normalized.py`, `loaders/*`).

| Supabase project | ID | Use |
| --- | --- | --- |
| The Red Book (staging) | `onbbgzonubgzvuxlgsew` | All development and ingest testing |
| The Red Book - Prod | `soiaskylkwucjhmsmcey` | Read-only for Palantír until Phase 3+ |

---

## Fork discipline — additive-only (deep dive)

All EGE code lives in directories that do not exist upstream:

| Directory | Purpose | Ticket |
| --- | --- | --- |
| `palantir/` | Python ETL package (flows, transforms, loaders, models, connectors) | [EGE-201](https://linear.app/ege-bio/issue/EGE-201) |
| `ui/src/palantir/` | Vue 3 additive routes/components for Palantír UI | [EGE-202](https://linear.app/ege-bio/issue/EGE-202) |
| `README.palantir.md` | This file | — |
| `.github/pull_request_template.md` | Palantír-specific PR template (overwrites upstream's) | EGE-198 |

Editing upstream files is allowed only when strictly necessary; every such edit increases weekly-rebase conflict surface.

---

## v0.1 scope — EGE Products only

**v0.1 ingests EGE Products sales data only.** Every row written by `ingest_qb_sales` carries `company_id = 'ege'`.

HCH Trucking and Runnin6 Farms are **out of scope for v0.1** and are not sales operations in the same shape as EGE Products:

- **HCH Trucking** ships goods for hire (loads / shipments / rates), not ag-chem product sales.
- **Runnin6 Farms** grows crops (fields / inputs / harvests), not ag-chem product sales.

Neither has a "customers buying ag-chem products" entity matching the QuickBooks *Sales by Item Detail* report shape that drives v0.1, so they don't fit the same connector or domain model. Their ingest pipelines are **Phase 3+** work with different connector shapes, different domain entities, and likely different Red Book tables.

### Multi-company architecture without multi-company code

The Red Book DDL keeps `company_id text NOT NULL` on every transactional table — structural forward-compatibility that costs nothing today and avoids an `ALTER TABLE` migration when HCH/Runnin6 ingest arrives. The **code**, by contrast, is explicitly single-company at v0.1.

| Layer            | v0.1 shape                                                            | Why                                                              |
| ---------------- | --------------------------------------------------------------------- | ---------------------------------------------------------------- |
| DDL              | `company_id text NOT NULL` on every transactional table               | Forward-compat; no migration when Phase 3+ tenants land          |
| Raw models       | **No** `company_id` field — raw QB rows carry no tenant identity       | Tenant identity is a property of the *load*, not of the source row |
| Normalized models| `company_id: str` field, set during transform                         | First place tenant identity is materialized                       |
| Flow             | `ingest_qb_sales(xlsx_path: str)` — `company_id = 'ege'` hardcoded     | Explicit single-tenant; parameterize when a second caller exists |

### Slug convention

The canonical `company_id` slug for EGE Products is `'ege'` (lowercase, no spaces, no punctuation). Future tenants will follow the same kebab-case pattern (e.g. `'hch'`, `'runnin6'`).

### Flow signature decision

The v0.1 flow signature is **Option A**:

```python
@flow
def ingest_qb_sales(xlsx_path: str) -> dict:
    company_id = "ege"  # TODO: parameterize when HCH/Runnin6 flows land
    ...
```

This is preferred over the forward-compatible-but-unused `company_id: str = 'ege'` default parameter (Option B) because:

- The function genuinely handles **only** EGE-shaped input at v0.1 — passing `'hch'` would not produce a working HCH ingest, it would just mislabel EGE data.
- A signature parameter promises polymorphism the function does not deliver.
- The TODO is a clear, greppable signal for the future migration point.

When the second caller actually exists (Phase 3+), the signature changes alongside the actual generalization work — not as a speculative gesture today.

### Roadmap pointer

Designing HCH Trucking and Runnin6 Farms ingest is its own track — each will need domain modeling, not just a parameter swap. Expect separate v0.2+/Phase-3 tickets: *Design HCH Trucking ingest pipeline* and *Design Runnin6 Farms ingest pipeline*.

---

## Inherited from Prefect — be aware

Forking a large active project means inheriting things we didn't author. Worth knowing:

- **`.claude/`** — Prefect ships a project-scoped Claude Code config (hooks, skills, settings). Your `~/.claude/` user config layers on top; Prefect's project-scoped config affects any Claude session in this repo.
- **`.github/workflows/`** — Prefect has ~30 workflows. Some may fire on PRs (CodeQL, CodSpeed benchmarks, `claude.yml`, etc.). Auditing which workflows we want active on this fork is part of EGE-204 (CI setup); until then, expect some failing checks on Palantír PRs that are not our concern.
- **`.pre-commit-config.yaml`** — includes the `no-commit-to-branch` hook (blocks accidental commits to `main`). Useful default; keep it.
- **`AGENTS.md`, `CLAUDE.md` (via symlink)** — upstream's agent guidance. Read it; it's the orientation Prefect's maintainers use.
- **`justfile`** — the canonical task runner. `just --list` shows what's available.

---

## References

- Phase 1 DDL §4.4 Stage 1 precondition (revised)
- TDD §4.1 Initial fork
- TDD §4.2 Additive-only discipline
- TDD §7.4 `connectors/qb_xlsx`
- TDD §7.9–§7.12 UI sections (frontend convention)
- Linear: [EGE-198](https://linear.app/ege-bio/issue/EGE-198) (v0.1 scope), [EGE-199](https://linear.app/ege-bio/issue/EGE-199) (Phase 1 DDL applied to staging), [EGE-200](https://linear.app/ege-bio/issue/EGE-200) (this fork), [EGE-201](https://linear.app/ege-bio/issue/EGE-201) (Python skeleton), [EGE-202](https://linear.app/ege-bio/issue/EGE-202) (UI skeleton), [EGE-203](https://linear.app/ege-bio/issue/EGE-203) (Docker), [EGE-204](https://linear.app/ege-bio/issue/EGE-204) (CI), [EGE-205](https://linear.app/ege-bio/issue/EGE-205) (upstream rebase), [EGE-220](https://linear.app/ege-bio/issue/EGE-220) (raw models), [EGE-231](https://linear.app/ege-bio/issue/EGE-231) (ingest flow)
