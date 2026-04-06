#!/usr/bin/env node

// session-log-hook.js — Claude Code Stop hook that logs sessions to Obsidian
// Appends session entries to Sessions/YYYY-MM-DD.md in the chrono-brain vault

const fs = require("fs");
const path = require("path");
const os = require("os");

const VAULT = path.join(
  os.homedir(),
  "Library/Mobile Documents/iCloud~md~obsidian/Documents/chrono-brain"
);
const SESSIONS_DIR = path.join(VAULT, "Sessions");
const KNOWLEDGE_DIR = path.join(VAULT, "second-brain", "lessons");
const SUMMARY_FILE = path.join(os.homedir(), ".gyst", "last-session-summary.txt");
const QUEUE_DIR = path.join(os.homedir(), ".gyst", "queue");
const QUEUE_THRESHOLD = 25;

function loadProjects() {
  try {
    const { loadAllWorkspaces, expandPath } = require("./parse-projects.js");
    return loadAllWorkspaces().map((p) => ({
      ...p,
      expandedPath: p.path ? expandPath(p.path) : null,
    }));
  } catch {
    return [];
  }
}

function matchProject(cwd, projects) {
  if (!cwd) return null;
  const resolved = path.resolve(cwd);

  // Find the most specific match (longest path prefix)
  let best = null;
  let bestLen = 0;
  for (const p of projects) {
    if (!p.expandedPath) continue;
    const expanded = path.resolve(p.expandedPath);
    if (resolved.startsWith(expanded) && expanded.length > bestLen) {
      best = p;
      bestLen = expanded.length;
    }
  }
  return best;
}

function getDate() {
  const now = new Date();
  const yyyy = now.getFullYear();
  const mm = String(now.getMonth() + 1).padStart(2, "0");
  const dd = String(now.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

function getTime() {
  const now = new Date();
  const hh = String(now.getHours()).padStart(2, "0");
  const mm = String(now.getMinutes()).padStart(2, "0");
  return `${hh}:${mm}`;
}

function readSummary() {
  try {
    if (fs.existsSync(SUMMARY_FILE)) {
      const content = fs.readFileSync(SUMMARY_FILE, "utf-8").trim();
      // Clear the file after reading
      fs.writeFileSync(SUMMARY_FILE, "");
      return content || null;
    }
  } catch {
    // ignore
  }
  return null;
}

function createDayFile(filePath, date) {
  return `---
type: session-log
date: ${date}
tags: [session-log]
---
# Sessions — ${date}

Claude Code session logs for this day.

---
`;
}

// --- Reflect: drain queue when > 25 items ---

function drainQueueIfReady() {
  try {
    if (!fs.existsSync(QUEUE_DIR)) return;
    const files = fs.readdirSync(QUEUE_DIR).filter((f) => f.endsWith(".json"));
    if (files.length < QUEUE_THRESHOLD) return;

    // Ensure knowledge dir exists
    if (!fs.existsSync(KNOWLEDGE_DIR)) {
      fs.mkdirSync(KNOWLEDGE_DIR, { recursive: true });
    }

    // Read all queue items
    const items = [];
    for (const f of files) {
      try {
        const raw = fs.readFileSync(path.join(QUEUE_DIR, f), "utf-8");
        items.push({ file: f, ...JSON.parse(raw) });
      } catch {
        // skip malformed
      }
    }

    if (items.length === 0) return;

    // Group by type
    const grouped = {};
    for (const item of items) {
      const key = item.type || "misc";
      if (!grouped[key]) grouped[key] = [];
      grouped[key].push(item);
    }

    // Write a batch knowledge note
    const date = getDate();
    const time = getTime();
    const slug = date + "-" + time.replace(":", "");
    const notePath = path.join(KNOWLEDGE_DIR, `batch-${slug}.md`);

    let content = `---\ntype: lesson\ndate: ${date}\ntags: [auto-extracted, batch-reflect]\nsource: queue-drain\n---\n`;
    content += `# Extracted Knowledge — ${date} ${time}\n\n`;
    content += `Auto-extracted from ${items.length} queued events.\n\n`;

    for (const [type, typeItems] of Object.entries(grouped)) {
      content += `## ${type.charAt(0).toUpperCase() + type.slice(1)}s (${typeItems.length})\n\n`;
      for (const item of typeItems) {
        const ts = item.ts ? item.ts.slice(0, 16).replace("T", " ") : "";
        const trigger = item.context?.trigger || "";
        content += `- ${ts ? `\`${ts}\` ` : ""}${item.signal || "unknown"}`;
        if (trigger) content += ` _(${trigger})_`;
        content += "\n";
      }
      content += "\n";
    }

    fs.writeFileSync(notePath, content);

    // Clear processed queue files
    for (const f of files) {
      try {
        fs.unlinkSync(path.join(QUEUE_DIR, f));
      } catch {
        // ignore cleanup errors
      }
    }
  } catch {
    // Silent — must not break the session hook
  }
}

function appendSession(input) {
  const date = getDate();
  const time = getTime();
  const cwd = input.cwd || process.cwd();
  const sessionId = input.session_id || "unknown";

  const projects = loadProjects();
  const project = matchProject(cwd, projects);
  const projectName = project ? project.name : path.basename(cwd);
  const summary = readSummary() || "_No summary recorded._";

  // Ensure Sessions dir exists
  if (!fs.existsSync(SESSIONS_DIR)) {
    fs.mkdirSync(SESSIONS_DIR, { recursive: true });
  }

  const filePath = path.join(SESSIONS_DIR, `${date}.md`);

  // Create file if it doesn't exist
  if (!fs.existsSync(filePath)) {
    fs.writeFileSync(filePath, createDayFile(filePath, date));
  }

  // Build session entry
  let entry = `\n## ${time} — ${projectName}\n\n`;
  entry += `**Working directory**: \`${cwd}\`\n`;
  if (project) {
    entry += `**Project**: [[second-brain/projects/${project.name}|${project.name}]]\n`;
  }
  entry += `\n${summary}\n\n---\n`;

  // Append to file
  fs.appendFileSync(filePath, entry);
}

// Read stdin (hook input) with dedup guard
let input = "";
let handled = false;

function handleInput() {
  if (handled) return;
  handled = true;
  try {
    const parsed = JSON.parse(input || "{}");
    appendSession(parsed);
  } catch {
    appendSession({});
  }
  drainQueueIfReady();
}

process.stdin.setEncoding("utf-8");
process.stdin.on("data", (chunk) => {
  input += chunk;
});
process.stdin.on("end", () => {
  handleInput();
});

// Timeout safety — if stdin doesn't close in 1.5s, run with what we have
setTimeout(() => {
  handleInput();
  process.exit(0);
}, 1500);
