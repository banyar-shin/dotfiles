---
name: wrap-up
description: Summarize the current session before ending. Use this when the user says goodbye, is done, or when a logical chunk of work is complete.
---

Write a concise session summary (2-4 bullet points) of what was accomplished in this conversation. Focus on actions taken and decisions made, not discussion.

Write the summary to `~/.gyst/last-session-summary.txt`. Use plain markdown, no frontmatter. The agent's session hook will pick it up and append it to the session log.

Example format:
```
- Restructured ~/git-repos/ into org-based layout (ego, personal, oss, immvrse, local-sandboxing)
- Archived 8 inactive ego projects, moved sjsu under personal/_school
- Fixed broken remember plugin — removed it entirely
```

Do NOT include timestamps, project names, or working directory — the session hook adds those automatically.
