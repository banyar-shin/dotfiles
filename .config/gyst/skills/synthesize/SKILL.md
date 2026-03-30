---
name: synthesize
description: Weekly cross-session synthesis — find patterns, recurring themes, and connections across recent vault activity. Run weekly or manually with /gyst:synthesize.
---

Perform a deep review of recent vault activity at `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/chrono-brain/`.

## Step 1: Gather recent activity

Read all `second-brain/` notes modified in the last 7 days. Also read the last 7 daily logs (`chrono/daily-logs/`) and session logs (`Sessions/`).

## Step 2: Identify patterns

Look for:

- **Recurring topics** — themes that appeared in 3+ sessions or daily logs
- **Evolving decisions** — a choice that was revisited or reversed
- **Contradictions** — lessons or decisions that conflict with each other
- **Knowledge gaps** — entities or concepts referenced but without vault notes
- **Stale notes** — `second-brain/` notes that reference things no longer true

## Step 3: Create or update concept notes

For each meaningful pattern, create or update a note in `second-brain/concepts/` that ties the related items together. Link to the source notes.

## Step 4: Write weekly synthesis

Add a "Weekly Synthesis" entry to `chrono/background-activities/YYYY-MM-DD.md` summarizing:

- Key patterns observed
- New connections made
- Stale notes flagged for review
- Knowledge gaps identified

## Step 5: Write state

Write to `~/.gyst/last-synthesis.json`:
```json
{
  "date": "YYYY-MM-DD",
  "weekRange": "YYYY-MM-DD to YYYY-MM-DD",
  "patternsFound": 0,
  "notesCreated": 0,
  "notesUpdated": 0,
  "staleNotesFlagged": []
}
```

## Guidelines

- This is a thinking skill, not a mechanical one. Take time to find non-obvious connections.
- Quality over quantity — 1-2 genuine insights beat 10 trivial observations.
- Flag stale notes but don't delete them — let the user decide.
