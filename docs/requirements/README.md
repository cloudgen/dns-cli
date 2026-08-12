# Requirements

Authoritative specialized product law for **folder-backup** lives here.

**Current state (2026-08-03):** Specialized **software-development** product. Left genesis. Bootstrap parent is external **selfmanaged** with **online install trimmed**. Registry is populated — see `index.md`.

## Product identity (summary)

| Field | Value |
|-------|--------|
| Product / `APP_NAME` | `folder-backup` |
| Version SSOT | `1.0.0` (ship unit hard-assign) |
| Ship unit | `src/folder-backup` |
| Default install | `~/.local/bin/folder-backup` |
| Install mode | **Local-only** |
| Backup ops | `requirement-folder-archive-backup` — create / name / deposit / verify / restore |
| Retention total | `requirement-folder-archive-backup-retention-total` — max **30** per basename |
| Retention daily | `requirement-folder-archive-backup-retention-daily` — max **5** per basename per day |
| Domain surface | `requirement-domain-folder-backup` — four pillars; ops deferred |

## Class requirement gate

| Class | Required class file |
|-------|---------------------|
| software-development | `requirement-class-software-dev.md` (**Active**) |
| genesis-template | N/A — this workspace is no longer genesis |

## Purpose

- **Plan** designs work by reading and updating these docs.  
- **Implement** delivers code that **traces** to these requirements.  
- **Review** verifies delivery against requirements and CIAO checklists.

## Layout

| Path | Role |
|------|------|
| `docs/requirements/index.md` | Registry of all requirements — keep in sync |
| `docs/requirements/requirement-*.md` | CIAO-style project requirements |

## Status values

Typical: `draft` · `Active` · `approved` · `in-progress` · `done` · `deprecated` · `superseded`

## Rules

1. Never invent paths — verify on disk.  
2. Class files only via class process; non-class via create-specific process.  
3. Never dump harness inventories into this versioned surface.  
4. Online install requirements stay **absent** unless product mode is explicitly changed.  
5. Sole domain SSOT: `requirement-domain-folder-backup.md`.
