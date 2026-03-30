---
name: heartbeat
description: Periodic vault maintenance — process inbox, review daily logs, extract knowledge, create connections. Run on a schedule or manually with /gyst:heartbeat.
---

Run maintenance on the Obsidian vault at `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/chrono-brain/`.

## Step 0: Check cooldown

Read `~/.gyst/heartbeat-state.json`. If `lastRun` is less than 30 minutes ago, skip this run entirely (another agent may have just completed maintenance). Log "Skipped — last run was recent" and exit.

## Step 1: Process inbox

Read `banyar/inbox.md`. For each item:

- `#task` → append to `banyar/tasks.md` (under "Add Tasks Here") using Obsidian Tasks emoji format
- `#work` → add to today's daily log, Work section
- `#life` → add to today's daily log, Life section
- `#idea` → add to today's daily log, Thoughts & Ideas section
- `#decision` → add to today's daily log, Decisions Made section
- `#learn` → add to today's daily log, Things Learned section
- No tag → infer from context

Move each processed item to the "## Processed" section in inbox with a timestamp:
```
2026-03-30 14:30 — #task Fix X → added to banyar/tasks.md
```

## Step 2: Review recent daily logs

Read the last 2 days of `chrono/daily-logs/`. For each bullet in "Things Learned" and "Decisions Made" that does NOT already contain a wikilink to `second-brain/`:

1. Determine if it's worth promoting to a `second-brain/` note.
2. If yes, create or update the appropriate note (entity, concept, lesson, project).
3. Add a wikilink back in the daily log entry.

Follow all vault rules: frontmatter, full-path wikilinks with display names, update folder index.

## Step 3: Densify connections

For each `second-brain/` note modified today:

1. Search the vault for mentions of its name in other notes.
2. Add bidirectional wikilinks where missing.
3. Update `## Related Notes` sections.

## Step 4: Prepare tomorrow

If tomorrow's daily log doesn't exist, create it from `templates/daily-log.md`.

## Step 5: Log activity

Append an entry to `chrono/background-activities/YYYY-MM-DD.md`. If the file doesn't exist, create it from `templates/background-activity.md`. Summarize: items processed, notes created/updated, connections added.

## Step 6: Update state

Write to `~/.gyst/heartbeat-state.json`:
```json
{
  "lastRun": "ISO-8601 timestamp",
  "source": "claude-code or openclaw",
  "inboxProcessed": 0,
  "notesCreated": 0,
  "notesUpdated": 0,
  "connectionsAdded": 0
}
```
