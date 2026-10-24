---
description: Find the slowest endpoints TonyProxy captured
argument-hint: "[n]"
---

1. Call the TonyProxy `session_stats` tool and read `stats.latency.p95Ms`.
2. Call `list_transactions` with `filter: { minDurationMs: <p95Ms> }` and `limit` set to $ARGUMENTS (use 10 when no number was given).
3. Group the rows by host. For each host, list its slowest paths with their `durationMs`, slowest first.
