---
description: Turn one TonyProxy transaction into a cURL command
argument-hint: "<id>"
---

Call the TonyProxy `export` tool with `format: "curl"` and `ids: ["$ARGUMENTS"]`.
Show the command from the reply's `text` in a shell code block. If the reply has a `path` instead of `text`, give the user that path.
Mention any `«redacted»` value the user must fill in before running it.
