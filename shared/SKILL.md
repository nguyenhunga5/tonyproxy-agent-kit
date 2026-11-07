## When to call what

TonyProxy is a macOS proxy inspector. Nine MCP tools read the traffic it
captured. When the user allows it, more tools start and stop capture and add
rules and breakpoints (see "Making changes"). For reading: cheap summaries
first, then narrow lists, then one transaction at a time.

- `tonyproxy_status` — once per conversation. Tells you the version, whether
  capture is running, the active session and its transaction count. Its
  `control` block says what you may change, and `sensitiveData` lists the
  hosts and apps whose credentials you may see.
- `session_stats` or `session_digest` — before any listing. Stats gives the
  total, status classes, the no-response count and latency (`p50Ms`, `p95Ms`,
  `maxMs`). The digest is a short text with top errors and any error burst.
- `group_by` — counts by `host`, `status`, `method`, `contentType` or
  `process` when the question is "which host / app / status dominates".
- `list_transactions` — always with a `filter`, and `limit` ≤ 50. Rows come
  newest first. Page with `cursor` set to the previous reply's `nextCursor`;
  stop when `nextCursor` is absent or you have enough.
- `search_transactions` — like `list_transactions` plus `text`, matched in the
  host, path and query.
- `get_transaction` — one `id` at a time, from a list or search reply. Pass
  `includeBodies: false` when headers are enough.
- `export` — `format: "curl"` to hand the user a repro. Other formats: `har`,
  `ndjson`, `csv`, `postman`, `openapi`. Pass `ids` from a list reply (up to
  200) or a `filter`.
- `list_sessions` — only when the user talks about an earlier capture.

`filter` fields: `hosts` (subdomains match too), `apps`, `method`, `status`
(`success`, `redirect`, `clientError`, `serverError`, `anyError`),
`contentType` (`JSON`, `HTML`, `Image`, `Other`), `pathPrefix`, `searchText`,
`minResponseBytes`, `minDurationMs`, `isGraphQL`, `isGRPC`, `isWebSocket`,
`lastMinutes`. Use exactly these names and values; an unknown value is
ignored, which silently widens the result.

Do not page through a whole session to answer a counting question. Ask
`session_stats` or `group_by` instead.

## Worked flows

Why did the last call to `<host>` fail?

1. `session_digest` with `filter: { hosts: ["<host>"] }`.
2. `list_transactions` with `filter: { hosts: ["<host>"], status: "anyError" }`,
   `limit: 20`. Rows with no `status` and an `error` are failures too.
3. `get_transaction` on the newest failing `id`.
4. Explain from the status, the response headers and the response body. Quote
   only the lines that matter.

What changed between these two requests?

1. `get_transaction` on the first `id`.
2. `get_transaction` on the second `id`.
3. Compare method, URL, request headers, request body, status and response
   body. Report the differences only.

Give me a cURL for the failing one.

1. Find the `id` (flow one, step 2).
2. `export` with `format: "curl"` and `ids: ["<id>"]`.
3. Show the command from the reply's `text`. If the reply has a `path`
   instead, the export was over 1 MiB; give the user the path.

Which endpoint is slow?

1. `session_stats`; read `stats.latency.p95Ms`.
2. `list_transactions` with `filter: { minDurationMs: <p95Ms> }`, `limit: 20`.
3. Group the rows by host and path; name the worst few with their
   `durationMs`. For a wider view, `group_by` with `groupBy: "host"` and the
   same filter.

## Making changes

Write tools are listed only while the user has turned on Settings → MCP →
"Allow agents to make changes", and each needs a tick for your client in
Paired Clients:

- "Can control capture": `start_capture` (new session, named after you unless
  you pass `name`), `stop_capture`, `rename_session`.
- "Can change rules": `list_rules`, `add_map_local_rule`,
  `add_map_remote_rule`, `add_rewrite_rule`, `update_rule`, `toggle_rule`,
  `remove_rule`, `pin_domain`, `unpin_domain`, `add_breakpoint_rule`,
  `wait_for_breakpoint`, `resolve_breakpoint`.

If a write tool is missing or refused, read `control.howToEnable` from
`tonyproxy_status` and tell the user exactly that. Do not retry until they
say it is done.

Rules you add follow these limits:

- You can change, toggle or remove only rules you created (`yours: true` in
  `list_rules`). User rules are read-only.
- If your rule overlaps an enabled user rule, the call fails with that rule's
  id. Ask the user, or call again with `disableConflicting: true`. The user's
  rule is turned off while yours exists and back on when yours goes.
- Your rules expire after `expiresAfterMinutes` (default 60, max 1440). You
  have 20 slots for rules and pins together.
- A pattern that matches everything (`*`) is refused; name a host or path.
- Map Remote destinations and rewritten `Host` headers must be loopback or a
  host in `sensitiveData.hosts`.
- Remove what you added once the user's question is answered.

`start_capture` may come back with `needsUser` when TonyProxy had to ask the
user something first; tell them what it says.

### Breakpoints

`add_breakpoint_rule` holds requests (or responses, with `phase`) matching
`host` and `path`. A held message goes on unchanged after `holdSeconds`
(120-300, default 120), but most clients give up after about 60 s, so be
quick:

- If you already know the answer, pass `prepared`. It is applied by itself
  after `decideWithinSeconds` (default 20) unless you answer first.
- Otherwise call `wait_for_breakpoint` (up to 60 s) right after the user sends
  the request. It returns each pause once.
- Then call `resolve_breakpoint` with `action`: `forward` (optionally with
  `patch`), `force_fail` with `status`, or `abort` (502). `already_resolved`
  means the user, your prepared answer or the timeout got there first.

`patch` ops are applied to the real bytes, in order: `setHeader`,
`removeHeader` (`name`, `value`), `replaceBody` (`body` or `bodyBase64`),
`setJSONField` (`path` like `items[0].price`, `json`), and `setStatus`
(response only). Masked credential headers cannot be patched. A full edited
`message` is accepted only for hosts in `sensitiveData.hosts`.

## Worked flows (changes)

Mock an endpoint to see how the app handles it.

1. `add_map_local_rule` with `urlPattern: "<host>/<path>"`, the `body`, and
   `contentType`.
2. Ask the user to reproduce. Confirm with `search_transactions` and
   `get_transaction`.
3. `remove_rule` with the rule's `id`.

Make one call fail with 503 once.

1. `add_breakpoint_rule` with `host`, `path`, and
   `prepared: { action: "force_fail", status: 503 }`.
2. Ask the user to reproduce; the request gets 503 without you answering.
3. `remove_rule` when done.

Change a response field live.

1. `add_breakpoint_rule` with `host`, `path` and `phase: "response"`.
2. Ask the user to reproduce, then `wait_for_breakpoint`.
3. `resolve_breakpoint` with `action: "forward"` and
   `patch: [{ op: "setJSONField", path: "<field>", json: <value> }]`.
4. `remove_rule` when done.

## What you will not get

- Bodies are capped. Each body has `size` (bytes on the wire),
  `capturedBytes` (what TonyProxy stored) and `truncated` (true when the text
  you got is shorter than `size`). Say so when `truncated` is true; do not
  guess the missing part.
- Credentials and sensitive query values come back as `«redacted»` unless the
  user turned redaction off in TonyProxy or listed the host or app under
  Settings → MCP → Sensitive data (`sensitiveData` in `tonyproxy_status`).
  Do not ask the user to paste them.
- Binary bodies are described, not returned: `kind: "binary"` with a
  `sha256`. Pass `encoding: "base64"` to `get_transaction` only when the user
  needs the bytes.
- A body TonyProxy did not save comes back as `kind: "notSaved"`.
- You cannot replay or delete traffic, delete sessions, or change TonyProxy
  settings (including redaction and the sensitive-data list). Rules and
  breakpoints are the only way to change traffic, and only when the user has
  allowed it. Point the user at the app for everything else.

## Session scope

Every tool defaults to the active session. Pass `sessionId` (from
`list_sessions`) only when the user points at an older capture. Keep using
the same `sessionId` for the rest of that question, so that ids and cursors
stay valid.
