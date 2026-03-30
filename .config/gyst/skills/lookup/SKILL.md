---
name: lookup
description: Search the Obsidian vault (chrono-brain) for notes, knowledge, tasks, logs, or any information. Use when the user asks to find, recall, or look up something from their second brain. Supports semantic search via ruflo memory and keyword fallback via grep.
---

Search the Obsidian vault at `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/chrono-brain/`.

## Arguments

`$ARGUMENTS` contains the search query (e.g., `/gyst:lookup auth middleware decision`).

If `$ARGUMENTS` is `index`, skip to the **Index** section below.

## Search strategy

### 1. Semantic search (primary)

Ensure ruflo embeddings are initialized — if `mcp__ruflo__embeddings_status` returns `initialized: false`, run `mcp__ruflo__embeddings_init` with model `all-MiniLM-L6-v2` and `hyperbolic: true`.

Search all four vault namespaces **in parallel** using `mcp__ruflo__memory_search`:
- query: `$ARGUMENTS`
- namespace: each of `vault-lessons`, `vault-concepts`, `vault-entities`, `vault-projects`
- limit: 3 per namespace
- threshold: 0.4

Merge results, sort by similarity, take the top 5-8 hits.

### 2. Keyword fallback (supplement)

If semantic search returns fewer than 3 results above 0.5 similarity, also grep the vault for keywords from the query. Check high-value locations based on what's being searched:

| Query type | Location |
|-----------|----------|
| People, orgs, tools | `second-brain/entities/` |
| Projects | `second-brain/projects/` |
| Concepts, ideas | `second-brain/concepts/` |
| Lessons learned | `second-brain/lessons/` |
| Tasks | `banyar/tasks.md` |
| Recent activity | `chrono/daily-logs/` (newest first) |
| Session history | `Sessions/` (newest first) |
| Background work | `chrono/background-activities/` |

### 3. Present results

- Read matching files to extract relevant context
- Follow wikilinks to find connected notes
- Cite file paths so the user can navigate in Obsidian
- If nothing found, say so — don't fabricate results

## Index

Re-index all `second-brain/` notes into ruflo memory for semantic search.

### Steps

1. Ensure ruflo embeddings are initialized (same as search).

2. Discover all `.md` files in:
   - `second-brain/lessons/`
   - `second-brain/concepts/`
   - `second-brain/entities/`
   - `second-brain/projects/`

3. Skip folder index notes (where filename matches directory name, e.g. `concepts/concepts.md`).

4. For each note, read it and store via `mcp__ruflo__memory_store`:
   - **key**: relative path (e.g. `lessons/Global rules beat project CLAUDE md.md`)
   - **namespace**: `vault-{dir}` (e.g. `vault-lessons`)
   - **value**: note title + description frontmatter + first 1500 chars of body
   - **tags**: `[dir-name]` plus any tags from frontmatter
   - **upsert**: true

5. Report results: how many indexed, skipped, total.

## Tips

- For time-based queries ("last week", "yesterday"), skip semantic and check daily logs by date.
- For project context, check both `second-brain/projects/` and `Sessions/` for recent work.
- Follow wikilinks between notes to build a fuller picture.
