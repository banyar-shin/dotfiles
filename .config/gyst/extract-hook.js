#!/usr/bin/env node

// extract-hook.js — PostToolUse hook that detects knowledge-worthy events
// Writes lightweight JSON files to ~/.gyst/queue/ for gyst:reflect to process
//
// Signals detected:
// - Git commits (decisions captured in commit messages)
// - File creation in second-brain/ or project dirs
// - Error resolution (failed tool followed by success)
// - Architecture/config changes

const fs = require("fs");
const path = require("path");
const os = require("os");

const QUEUE_DIR = path.join(os.homedir(), ".gyst", "queue");

function ensureQueueDir() {
  if (!fs.existsSync(QUEUE_DIR)) {
    fs.mkdirSync(QUEUE_DIR, { recursive: true });
  }
}

function writeQueueItem(item) {
  ensureQueueDir();
  const ts = new Date()
    .toISOString()
    .replace(/[:.]/g, "-")
    .slice(0, 19);
  const filename = `${ts}-${item.type}.json`;
  fs.writeFileSync(
    path.join(QUEUE_DIR, filename),
    JSON.stringify(item, null, 2)
  );
}

function detectSignals(input) {
  const tool = input.tool_name || "";
  const toolInput = input.tool_input || {};
  const toolOutput = input.tool_output || "";
  const output = typeof toolOutput === "string" ? toolOutput : JSON.stringify(toolOutput);

  // Git commits — decisions captured in commit messages
  if (tool === "Bash" || tool === "bash") {
    const command = toolInput.command || "";

    if (command.includes("git commit") && !output.includes("nothing to commit")) {
      const msgMatch = command.match(/-m\s+["']([^"']+)["']/);
      const conventionalMatch = command.match(/(?:feat|fix|refactor|perf|docs|test|chore):\s*(.+)/);
      const message = msgMatch ? msgMatch[1] : conventionalMatch ? conventionalMatch[0] : null;
      if (message) {
        return {
          type: "decision",
          signal: `Committed: ${message.slice(0, 120)}`,
          context: { tool, trigger: "git-commit" },
        };
      }
    }

    // Package installation — new dependency decisions
    if (
      command.match(/npm install|yarn add|pnpm add|pip install|cargo add/) &&
      !output.includes("ERR!")
    ) {
      const pkgMatch = command.match(
        /(?:npm install|yarn add|pnpm add|pip install|cargo add)\s+([^\s-][^\s]*)/
      );
      if (pkgMatch) {
        return {
          type: "decision",
          signal: `Added dependency: ${pkgMatch[1]}`,
          context: { tool, trigger: "package-install" },
        };
      }
    }
  }

  // File creation in meaningful locations
  if (tool === "Write" || tool === "write") {
    const filePath = toolInput.file_path || "";

    // New config files — architecture decisions
    if (
      filePath.match(
        /\.(toml|yaml|yml|json)$/) &&
      filePath.match(/(config|\.env|settings|workspace)/)
    ) {
      return {
        type: "decision",
        signal: `Created config: ${path.basename(filePath)}`,
        context: { tool, file: filePath, trigger: "config-creation" },
      };
    }

    // New project structure files
    if (filePath.match(/CLAUDE\.md|README\.md|\.gitignore|Dockerfile|docker-compose/)) {
      return {
        type: "decision",
        signal: `Created project file: ${path.basename(filePath)}`,
        context: { tool, file: filePath, trigger: "project-setup" },
      };
    }
  }

  return null;
}

// Read stdin
let input = "";
let handled = false;

function handleInput() {
  if (handled) return;
  handled = true;
  try {
    const parsed = JSON.parse(input || "{}");
    const signal = detectSignals(parsed);
    if (signal) {
      signal.ts = new Date().toISOString();
      writeQueueItem(signal);
    }
  } catch {
    // Silent — hook must not break the session
  }
}

process.stdin.setEncoding("utf-8");
process.stdin.on("data", (chunk) => {
  input += chunk;
});
process.stdin.on("end", () => {
  handleInput();
});

// Timeout safety
setTimeout(() => {
  handleInput();
  process.exit(0);
}, 1500);
