---
name: project_hacktrack
description: "HackTrack-EU repo context — fork status, orchestration workflow, model config"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5e0fa11b-4ad0-44da-8a56-50b556290a89
  modified: 2026-09-01T18:36:45.108Z
---

`~/dev/HackTrack-EU` is a fork (origin: viganogabriele/HackTrack-EU, upstream: lorenzopalaia/HackTrack-EU, MIT license). The user has done nearly all real development in their own fork (100+ merged PRs) while upstream stayed mostly static (~200 stars, no real competitor in its niche). As of 2026-09-01 the user is leaning toward detaching/rebranding it as fully their own project rather than staying labeled as a fork, since the fork label costs them visibility/SEO without giving anything back. Local dev DB is separate from upstream.

**Why:** avoid re-litigating the fork-vs-detach discussion from scratch; if asked again, recall this was already discussed and the recommendation given (detach is legally fine under MIT, main tradeoff is losing upstream's accumulated stars/discoverability and restarting visibility from zero).

**How to apply:** treat this repo's `origin` as the canonical repo going forward for PRs/merges; don't assume upstream review is needed. If the user later confirms they detached/renamed it, update this memory with the new name/URL.

Related: [[feedback_orchestrator_workflow]]
