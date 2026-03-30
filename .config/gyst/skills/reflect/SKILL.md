---
name: reflect
description: Extract knowledge from the current session into the Obsidian vault. Run this before wrap-up when the user is done, says goodbye, or a major chunk of work is complete.
---

Review the current conversation and extract knowledge into the Obsidian vault at `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/chrono-brain/`.

## Step 1: Check the queue

Read all JSON files in `~/.gyst/queue/`. These are pre-identified extraction candidates captured during the session. Incorporate them into your extraction below, then delete each processed queue file.

## Step 2: Scan the conversation for four categories

- **Decisions** — architectural choices, tool selections, trade-offs, "we went with X because Y"
- **Lessons** — things that failed, workarounds, surprises, "I wish I knew this earlier"
- **Entities** — people, tools, organizations, or projects mentioned that don't yet have vault notes
- **Concepts** — technical patterns, ideas, or mental models worth preserving

Skip trivial items. Only extract what would be useful to recall in a future session.

## Step 3: Write to the vault

For each extracted item:

1. **Search** the vault to check if a note already exists for this topic.
2. **If it exists**: append the new information to the appropriate section. Add wikilinks to related notes.
3. **If it doesn't exist**: create a new note in the correct location:

| Type | Location |
|------|----------|
| Person/Org/Tool | `second-brain/entities/{Name}.md` |
| Project | `second-brain/projects/{Name}.md` |
| Concept/Pattern | `second-brain/concepts/{Name}.md` |
| Lesson | `second-brain/lessons/{Name}.md` |

Every new `second-brain/` note MUST have YAML frontmatter:
```yaml
---
type: person|ai|organization|tool|project|concept|lesson
created: YYYY-MM-DD
tags: [topic-note, <type>]
---
```

Always use full-path wikilinks with display names: `[[second-brain/entities/Banyar|Banyar]]`

4. **Update the folder index** (`{folder}/{folder}.md`) when adding a new file.

## Step 4: Update today's daily log

Add a "Things Learned" entry to `chrono/daily-logs/YYYY-MM-DD.md` summarizing what was extracted. If the file doesn't exist, create it from `templates/daily-log.md`.

## Step 5: Write manifest

Write a JSON summary of what was extracted to `~/.gyst/last-reflect-output.json`:
```json
{
  "date": "YYYY-MM-DD",
  "created": ["second-brain/lessons/Foo.md"],
  "updated": ["second-brain/entities/Bar.md"],
  "daily_log_entry": true
}
```

## Guidelines

- Be selective. 0-5 extractions per session is normal. Not every session produces knowledge.
- If nothing worth extracting, write an empty manifest and skip the daily log entry.
- Don't duplicate information that already exists in the vault.
- Decisions and lessons are the highest-value extractions — prioritize these.
