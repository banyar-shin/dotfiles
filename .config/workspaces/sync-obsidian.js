#!/usr/bin/env node

// sync-obsidian.js — Sync workspace projects to Obsidian vault notes
// Reads all [[projects]] from workspace TOMLs and creates/updates
// corresponding notes in second-brain/projects/

const fs = require("fs");
const path = require("path");
const os = require("os");
const { loadAllWorkspaces } = require("./parse-projects.js");

const VAULT = path.join(
  os.homedir(),
  "Library/Mobile Documents/iCloud~md~obsidian/Documents/chrono-brain"
);
const PROJECTS_DIR = path.join(VAULT, "second-brain", "projects");

function sanitizeFilename(name) {
  return name.replace(/[/\\:*?"<>|]/g, "-");
}

function generateProjectNote(project) {
  const tags = ["topic-note", "project", ...(project.tags || [])];
  const tagStr = tags.map((t) => `"${t}"`).join(", ");

  let details = `- **Type**: ${project.type || "unknown"}\n`;
  details += `- **Status**: ${project.status || "unknown"}\n`;
  if (project.started) {
    details += `- **Started**: [[chrono/daily-logs/${project.started}|${project.started}]]\n`;
  }
  if (project.path) {
    details += `- **Path**: \`${project.path}\`\n`;
  }
  if (project.workspace) {
    details += `- **Workspace**: ${project.workspace}\n`;
  }

  return `---
type: project
created: ${project.started || new Date().toISOString().slice(0, 10)}
status: ${project.status || "active"}
project-type: ${project.type || "unknown"}
tags: [${tagStr}]
source: workspace-toml
---
# ${project.name}

#project

${project.description || ""}

---

## Details

${details}
---

## Notes

_Add notes, context, and decisions here._

---

## Related Sessions
<!-- Auto-updated when Claude Code sessions reference this project -->

---

## See Also
- [[second-brain/projects/projects|Projects]]
`;
}

function updateFrontmatter(existingContent, project) {
  // Only update frontmatter fields, preserve everything else
  const fmMatch = existingContent.match(/^---\n([\s\S]*?)\n---/);
  if (!fmMatch) return null; // no frontmatter, skip

  let frontmatter = fmMatch[1];
  const body = existingContent.slice(fmMatch[0].length);

  // Update specific fields
  const updates = {
    status: project.status,
    "project-type": project.type,
  };

  for (const [key, value] of Object.entries(updates)) {
    if (!value) continue;
    const regex = new RegExp(`^${key}:.*$`, "m");
    if (regex.test(frontmatter)) {
      frontmatter = frontmatter.replace(regex, `${key}: ${value}`);
    } else {
      frontmatter += `\n${key}: ${value}`;
    }
  }

  // Update tags
  if (project.tags) {
    const tags = ["topic-note", "project", ...project.tags];
    const tagStr = tags.map((t) => `"${t}"`).join(", ");
    const tagRegex = /^tags:.*$/m;
    if (tagRegex.test(frontmatter)) {
      frontmatter = frontmatter.replace(tagRegex, `tags: [${tagStr}]`);
    }
  }

  return `---\n${frontmatter}\n---${body}`;
}

function generateFolderNote(projects) {
  const active = projects.filter((p) => p.status === "active");
  const paused = projects.filter((p) => p.status === "paused");
  const ideas = projects.filter((p) => p.status === "idea");
  const completed = projects.filter((p) => p.status === "completed");
  const other = projects.filter(
    (p) => !["active", "paused", "idea", "completed"].includes(p.status)
  );

  function renderGroup(items) {
    if (items.length === 0) return "_(None)_\n";
    return items
      .map((p) => {
        const fname = sanitizeFilename(p.name);
        let entry = `### [[second-brain/projects/${fname}|${p.name}]]\n`;
        entry += `${p.description || ""}\n`;
        entry += `- **Type**: ${p.type || "unknown"}`;
        if (p.started) entry += ` | **Started**: [[chrono/daily-logs/${p.started}|${p.started}]]`;
        return entry + "\n";
      })
      .join("\n");
  }

  let content = `# Projects

Active work and initiatives. Auto-synced from workspace TOML files.

---

## Active

${renderGroup(active)}`;

  if (ideas.length > 0) {
    content += `\n---\n\n## Ideas\n\n${renderGroup(ideas)}`;
  }

  if (paused.length > 0) {
    content += `\n---\n\n## Paused\n\n${renderGroup(paused)}`;
  }

  content += `\n---\n\n## Archive\n\n${renderGroup(completed.concat(other))}`;

  content += `\n---\n\n## See Also
- [[second-brain/entities/entities|Entities]]
- [[second-brain/lessons/lessons|Lessons]]
- [[second-brain/concepts/concepts|Concepts]]
`;

  return content;
}

function sync() {
  const projects = loadAllWorkspaces();
  let created = 0;
  let updated = 0;
  let skipped = 0;

  // Ensure projects dir exists
  if (!fs.existsSync(PROJECTS_DIR)) {
    fs.mkdirSync(PROJECTS_DIR, { recursive: true });
  }

  for (const project of projects) {
    const fname = sanitizeFilename(project.name);
    const filePath = path.join(PROJECTS_DIR, `${fname}.md`);

    if (fs.existsSync(filePath)) {
      const existing = fs.readFileSync(filePath, "utf-8");

      // Only update if we created it (has source: workspace-toml)
      if (!existing.includes("source: workspace-toml")) {
        console.log(`  skip: ${fname}.md (hand-written, no source marker)`);
        skipped++;
        continue;
      }

      const updatedContent = updateFrontmatter(existing, project);
      if (updatedContent && updatedContent !== existing) {
        fs.writeFileSync(filePath, updatedContent);
        console.log(`  update: ${fname}.md`);
        updated++;
      } else {
        console.log(`  ok: ${fname}.md (no changes)`);
      }
    } else {
      const content = generateProjectNote(project);
      fs.writeFileSync(filePath, content);
      console.log(`  create: ${fname}.md`);
      created++;
    }
  }

  // Update folder note
  const folderNotePath = path.join(PROJECTS_DIR, "projects.md");
  const folderContent = generateFolderNote(projects);
  fs.writeFileSync(folderNotePath, folderContent);
  console.log(`  update: projects.md (folder note)`);

  console.log(
    `\nSync complete: ${created} created, ${updated} updated, ${skipped} skipped`
  );
}

sync();
