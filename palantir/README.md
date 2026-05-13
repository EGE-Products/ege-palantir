# palantir/

EGE Palantír — the ETL package. Flows, connectors, transforms, loaders, and models
that move data between source systems (NetSuite, etc.), Supabase, and downstream apps.

This directory is **EGE-additive**. The repo is a fork of
[PrefectHQ/prefect](https://github.com/PrefectHQ/prefect); upstream Prefect lives at
`src/prefect/` and is rebased weekly. Everything in `palantir/` is ours — edit freely.
See the root [`README.palantir.md`](../README.palantir.md) for fork-discipline rules.

## Layout

```
palantir/
├── pyproject.toml          # uv-managed; own venv, separate from upstream Prefect
├── src/palantir/
│   ├── flows/              # Prefect @flow entrypoints
│   ├── connectors/         # source-system clients (NetSuite, etc.)
│   ├── transforms/         # pure functions: clean, coerce, normalize
│   ├── loaders/            # write into Supabase / Postgres
│   ├── webhooks/           # outbound notification handlers
│   ├── models/             # pydantic models (raw + normalized)
│   └── lib/                # shared helpers: db conn, logging, signing
└── tests/                  # pytest; mirrors src/palantir/ layout
```

## Quick start

From this directory:

```bash
uv sync          # create .venv, install runtime + dev deps
uv run ruff check
uv run mypy
uv run pytest
```

`uv sync` from the repo root operates on the upstream Prefect project. The
Palantír project has its own `pyproject.toml` and venv here — they don't share
a lockfile.

## What goes where

| Package          | Owns                                                       |
| ---------------- | ---------------------------------------------------------- |
| `flows/`         | Prefect flow/task definitions — the scheduled entrypoints. |
| `connectors/`    | I/O against external source systems. One module per system. |
| `transforms/`    | Pure, deterministic data shaping. No I/O.                  |
| `loaders/`       | Writes into Supabase / Postgres. Idempotent upserts.       |
| `webhooks/`      | Outbound signed webhooks to downstream consumers.          |
| `models/`        | `raw.py` (source shape), `normalized.py` (canonical shape). |
| `lib/`           | Cross-cutting helpers (db, logging, signing).              |

Schema changes do **not** live here — they're owned by the `ege-redbook` repo.
Palantír is the ETL consumer of the Red Book schema.
