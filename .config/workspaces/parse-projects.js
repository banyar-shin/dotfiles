#!/usr/bin/env node

// parse-projects.js — Parse [[projects]] blocks from workspace TOML files
// Usage:
//   node parse-projects.js [workspace-name]        → JSON output
//   node parse-projects.js --info [project-name]   → formatted table

const fs = require("fs");
const path = require("path");
const os = require("os");

const WS_DIR = path.join(os.homedir(), ".config", "workspaces");

function parseToml(content) {
  const projects = [];
  const blocks = content.split(/^\[\[projects\]\]/gm);
  blocks.shift(); // discard everything before first [[projects]]

  for (const block of blocks) {
    const project = {};
    // Stop at next section header
    const lines = block.split("\n");
    for (const line of lines) {
      const trimmed = line.trim();
      if (/^\[/.test(trimmed) && !/^\[\[projects\]\]/.test(trimmed)) break;
      if (trimmed.startsWith("#") || trimmed === "") continue;

      const match = trimmed.match(/^(\w[\w-]*)\s*=\s*(.+)$/);
      if (!match) continue;

      const [, key, rawVal] = match;
      // Array value
      if (rawVal.startsWith("[")) {
        const items = rawVal
          .replace(/^\[|\]$/g, "")
          .split(",")
          .map((s) => s.trim().replace(/^["']|["']$/g, ""))
          .filter(Boolean);
        project[key] = items;
      }
      // String value
      else {
        project[key] = rawVal.replace(/^["']|["']$/g, "");
      }
    }
    if (project.name) projects.push(project);
  }
  return projects;
}

function parsePaths(content) {
  const paths = [];
  const blocks = content.split(/^\[\[paths\]\]/gm);
  blocks.shift();

  for (const block of blocks) {
    const entry = {};
    const lines = block.split("\n");
    for (const line of lines) {
      const trimmed = line.trim();
      if (/^\[/.test(trimmed) && !/^\[\[paths\]\]/.test(trimmed)) break;
      if (trimmed.startsWith("#") || trimmed === "") continue;

      const match = trimmed.match(/^(\w[\w-]*)\s*=\s*(.+)$/);
      if (!match) continue;
      const [, key, rawVal] = match;
      entry[key] = rawVal.replace(/^["']|["']$/g, "");
    }
    if (entry.path) paths.push(entry);
  }
  return paths;
}

function loadWorkspace(name) {
  const filePath = path.join(WS_DIR, `${name}.toml`);
  if (!fs.existsSync(filePath)) {
    console.error(`Workspace '${name}' not found at ${filePath}`);
    process.exit(1);
  }
  const content = fs.readFileSync(filePath, "utf-8");
  return {
    projects: parseToml(content),
    paths: parsePaths(content),
  };
}

function loadAllWorkspaces() {
  const files = fs
    .readdirSync(WS_DIR)
    .filter((f) => f.endsWith(".toml"));
  const allProjects = [];
  for (const file of files) {
    const name = path.basename(file, ".toml");
    const content = fs.readFileSync(path.join(WS_DIR, file), "utf-8");
    const projects = parseToml(content);
    for (const p of projects) {
      allProjects.push({ ...p, workspace: name });
    }
  }
  return allProjects;
}

function expandPath(p) {
  return p.replace(/^~/, os.homedir());
}

function printInfo(filterName) {
  const projects = loadAllWorkspaces();
  const filtered = filterName
    ? projects.filter(
        (p) => p.name.toLowerCase() === filterName.toLowerCase()
      )
    : projects;

  if (filtered.length === 0) {
    console.log(filterName ? `No project named '${filterName}'` : "No projects found.");
    return;
  }

  // Group by status
  const grouped = {};
  for (const p of filtered) {
    const status = p.status || "unknown";
    if (!grouped[status]) grouped[status] = [];
    grouped[status].push(p);
  }

  const order = ["active", "paused", "idea", "completed", "unknown"];
  for (const status of order) {
    if (!grouped[status]) continue;
    console.log(`\n  ${status.toUpperCase()}`);
    console.log("  " + "-".repeat(50));
    for (const p of grouped[status]) {
      console.log(`  ${p.name}`);
      if (p.description) console.log(`    ${p.description}`);
      const meta = [];
      if (p.type) meta.push(`type: ${p.type}`);
      if (p.started) meta.push(`started: ${p.started}`);
      if (p.tags) meta.push(`tags: ${p.tags.join(", ")}`);
      if (meta.length) console.log(`    ${meta.join(" | ")}`);
      if (p.path) console.log(`    path: ${p.path}`);
    }
  }
  console.log();
}

// Export for use by other scripts
module.exports = { parseToml, parsePaths, loadWorkspace, loadAllWorkspaces, expandPath };

// CLI — only run when executed directly
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args[0] === "--info") {
    printInfo(args[1]);
  } else if (args[0] === "--all") {
    console.log(JSON.stringify(loadAllWorkspaces(), null, 2));
  } else if (args[0] === "--paths") {
    const name = args[1] || "default";
    const { paths } = loadWorkspace(name);
    console.log(JSON.stringify(paths, null, 2));
  } else {
    const name = args[0] || "default";
    const { projects } = loadWorkspace(name);
    console.log(JSON.stringify(projects, null, 2));
  }
}
