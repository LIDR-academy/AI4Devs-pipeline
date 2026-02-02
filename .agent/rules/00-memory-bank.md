---
description: "Mandatory Memory Bank Workflow"
globs: ["**/*"]
alwaysApply: true
priority: critical
---

# AGENT MANDATE: Shared Memory Access

You are working in a multi-agent environment (Antigravity). You must rely on the Memory Bank for the single source of truth.

## 1. Context Loading (READ FIRST)
Before planning or executing ANY task, you MUST read:
- memory-bank/activeContext.md -> To understand current focus.
- memory-bank/systemPatterns.md -> To respect architecture.
- memory-bank/techContext.md -> To use correct tools/commands.

## 2. Atomic Updates (WRITE BACK)
After completing a task:
1. Update memory-bank/activeContext.md: Remove your finished task, add the result.
2. Update memory-bank/progress.md: Mark features as completed.
3. Self-Correction: If you find projectbrief.md or systemPatterns.md outdated, update them immediately.

## 3. Forbidden Actions
- Do not invent commands not listed in techContext.md.
- Do not modify core architecture without updating systemPatterns.md first.
