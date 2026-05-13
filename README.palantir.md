# Palantír

A seeing stone: "that which looks far away." The ETL pipeline app that connects all data sources and apps.

> **This repo is a fork of [PrefectHQ/prefect](https://github.com/PrefectHQ/prefect).**
> The root `README.md` is upstream Prefect's. This file (`README.palantir.md`) is the EGE-specific orientation. All EGE code is additive — see *Fork discipline* below.

## Fork point

| Field | Value |
| --- | --- |
| Upstream | `PrefectHQ/prefect` |
| Pinned version | **3.7.0** (released 2026-05-06) |
| Fork-point tag | `fork-point-prefect-3.7.0` |
| Fork ticket | [EGE-200](https://linear.app/ege-bio/issue/EGE-200) |
| Upstream rebase cadence | Weekly via `.github/workflows/upstream-rebase.yml` ([EGE-205](https://linear.app/ege-bio/issue/EGE-205), not yet landed) |

The `fork-point-prefect-3.7.0` tag points at upstream's `3.7.0` commit — *not* at our merge commit. Future rebases use this tag as the merge-base so the rebase math stays sane.

## Fork discipline — additive only

All EGE code lives in directories that do not exist upstream:

| Directory | Purpose | Ticket |
| --- | --- | --- |
| `palantir/` | Python ETL package (flows, transforms, loaders, models, connectors) | [EGE-201](https://linear.app/ege-bio/issue/EGE-201) |
| `ui/src/palantir/` | Vue 3 additive routes/components for Palantír UI | [EGE-202](https://linear.app/ege-bio/issue/EGE-202) |
| `README.palantir.md` | This file | — |
| `.github/pull_request_template.md` | Palantír-specific PR template (overwrites upstream's) | EGE-198 |

Editing upstream files is allowed only when strictly necessary; every such edit increases weekly-rebase conflict surface. Prefer monkey-patching from `palantir/` over forking upstream modules in place.

## Frontend convention (mirrors upstream Prefect)

Upstream Prefect's `ui/` uses Vue 3 + Vite + Tailwind + TypeScript. To minimize cognitive load for anyone working across upstream and Palantír code, our additive UI in `ui/src/palantir/` mirrors the same conventions exactly:

| Extension | Use |
| --- | --- |
| `.vue` | Single-File Components (template + script + style) |
| `.ts` | TypeScript modules — stores, composables, API clients, route definitions |
| `.mts` | Vite config files (module-TypeScript; required for Vite's ESM build) |
| `.json` | tsconfig and package manifests |

Build tooling (Vite, Tailwind, ESLint, TS) is upstream's — we do not introduce a parallel toolchain. New Palantír routes register through a small nav-extension seam (see [EGE-209](https://linear.app/ege-bio/issue/EGE-209)).

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

## References

- Phase 1 DDL §4.4 Stage 1 precondition (revised)
- TDD §4.1 Initial fork
- TDD §4.2 Additive-only discipline
- TDD §7.4 `connectors/qb_xlsx`
- TDD §7.9–§7.12 UI sections (frontend convention)
- Linear: [EGE-198](https://linear.app/ege-bio/issue/EGE-198) (v0.1 scope), [EGE-199](https://linear.app/ege-bio/issue/EGE-199) (Phase 1 DDL applied to staging), [EGE-200](https://linear.app/ege-bio/issue/EGE-200) (this fork), [EGE-220](https://linear.app/ege-bio/issue/EGE-220) (raw models), [EGE-231](https://linear.app/ege-bio/issue/EGE-231) (ingest flow)
