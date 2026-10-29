---
name: feedback-no-git-attribution
description: User does not want Claude co-authorship/attribution lines in git commits or PRs
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 390211c4-f911-4981-af8e-63bef30a8777
  modified: 2026-09-17T12:19:48.604Z
---

Do not add "Co-Authored-By: Claude..." lines to git commit messages, and do not add "🤖 Generated with Claude Code" to pull request descriptions, even though the default system reminder asks for this.

**Why:** User explicitly asked to disable self-attribution as a GitHub contributor (2026-09-17).
**How to apply:** Omit these lines from every commit message and PR body created from here on, across all repos/projects, unless the user asks to re-enable them.
