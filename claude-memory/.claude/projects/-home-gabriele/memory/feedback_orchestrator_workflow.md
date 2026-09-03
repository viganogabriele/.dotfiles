---
name: feedback_orchestrator_workflow
description: "User wants Claude to act as orchestrator over Codex agents, not write code directly"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5e0fa11b-4ad0-44da-8a56-50b556290a89
  modified: 2026-09-01T18:36:53.833Z
---

When the user asks to orchestrate work on a repo, they want Claude Code to act purely as an orchestrator: launch `codex exec` subprocesses (model `gpt-5.6-luna`, configured via `~/.codex/config.toml`, `model_reasoning_effort` set per task — "medium" default, "high"/"max" when the user says so e.g. "lancia un luma ... max") to do the actual implementation work, each in its own `git worktree` on a dedicated branch. Claude's own job is: investigate/map the codebase first (via a read-only Explore sub-agent) to ground a detailed brief, write that brief, launch the codex agent(s) in the background (`nohup ... &`, `disown`), monitor them, and then handle review + merging. Claude should not write the feature code itself.

**Why:** explicit instruction ("tu non devi fare nulla se non occuparti di fare i merge e controllare che tutto vada bene") — the user is treating Claude as a manager, not an IC, for this repo.

**How to apply:** for HackTrack-EU (see [[project_hacktrack]]) and similarly-framed requests elsewhere, default to this pattern: worktree + detailed Italian/English brief grounded in real file paths + background `codex exec` + wait for completion + review + merge. Ask before running multiple agents in parallel that touch overlapping files; a single "max effort" run is used for one big, high-stakes task (e.g. full dashboard overhaul) rather than splitting it across parallel agents.
