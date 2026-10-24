---
description: Explain why recent calls captured by TonyProxy failed
argument-hint: "[host]"
---

Use the TonyProxy MCP tools to explain the most recent failure.

1. Call `session_digest`. If a host was given ("$ARGUMENTS" is not empty), pass `filter: { hosts: ["$ARGUMENTS"] }`.
2. Call `list_transactions` with `filter: { status: "anyError" }` (plus `hosts: ["$ARGUMENTS"]` when a host was given) and `limit: 20`.
3. Call `get_transaction` on the newest error's `id`.
4. Explain the failure from its status, headers and body. Say when a body is `truncated` or a value is `«redacted»`.
