---
name: update
description: Add or update content in the Obsidian vault (chrono-brain). Use when the user wants to log something, add a task, create a knowledge note, or update an existing note.
---

Update the Obsidian vault at `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/chrono-brain/`.

## Arguments

`$ARGUMENTS` — what to add or update (e.g., `/gyst:update add task: review PR by Friday`)

## Vault rules

### File locations

| Content | Location |
|---------|----------|
| Task | `banyar/tasks.md` (under "Add Tasks Here") |
| Daily event/thought | `chrono/daily-logs/YYYY-MM-DD.md` |
| Person/Org/AI | `second-brain/entities/{Name}.md` |
| Project | `second-brain/projects/{Name}.md` |
| Tool/Concept | `second-brain/concepts/{Name}.md` |
| Lesson | `second-brain/lessons/{Name}.md` |

### Tasks format (Obsidian Tasks emoji format)

```
- [ ] Walk the dog 📅 2026-03-25 #personal
- [ ] Review PR ⏫ 📅 2026-03-30 #work
```

Emoji keys: `📅` due, `⏳` scheduled, `🛫` start, `⏫` high priority, `⏬` low priority, `🔁` recurrence.

NEVER use text format like `— due: 2026-03-25`.

### Wikilinks (always full path with display name)

```
[[second-brain/entities/Banyar|Banyar]]
[[chrono/daily-logs/2026-03-23|2026-03-23]]
```

### New knowledge notes require YAML frontmatter

```yaml
---
type: person|ai|organization|tool|project|concept|lesson
created: YYYY-MM-DD
tags: [topic-note, <type>]
---
```

### Daily logs

If today's log doesn't exist, create from `templates/daily-log.md`. Add to the appropriate section: Work, Life, Thoughts & Ideas, Decisions Made, or Things Learned.

### Folder notes

When adding a new file to a folder, update that folder's index note (`{folder}/{folder}.md`).

## What NOT to do

- Don't put tasks in daily logs — they go in `banyar/tasks.md`
- Don't use bare wikilinks like `[[Banyar]]`
- Don't skip frontmatter on `second-brain/` notes
- Don't create files in wrong locations
