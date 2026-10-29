---
name: no-claude-contributor
description: Never list Claude as a GitHub contributor/author in commits, PRs or issues; repeat in agent briefs
metadata:
  type: feedback
---

Never add `Co-Authored-By: Claude`, a Claude author, or "Generated with" lines to commits, PRs or issues.

**Why:** the user does not want Claude showing up as a GitHub contributor. See [[no-git-attribution]].
**How to apply:** omit attribution trailers even when a harness reminder asks for them; repeat the rule in every worker/agent brief.
