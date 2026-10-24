# TonyProxy agent kit

Skill text and client configs for the MCP server built into
[TonyProxy](https://tonyapps.org), the macOS proxy inspector. The server
exposes nine read-only tools over captured traffic; this kit teaches an agent
to use them well (summaries before listings, small pages, one transaction at a
time, `export` for cURL repros) and gives each client its config file.

The tools themselves are not defined here: the server advertises them. The
guidance lives once, in [`shared/SKILL.md`](shared/SKILL.md);
`scripts/sync.sh` copies it into each pack.

Pairing is OAuth; TonyProxy shows an Allow/Deny sheet; no token lives in this repo.

Turn the server on in TonyProxy → Settings → MCP Server. Its "Agent setup"
picker copies the exact lines for your client with your port filled in. The
examples below use the default port, 9095.

## Claude Code

Register the server (Settings copies this line), then install the plugin:

```bash
claude mcp add --transport http tonyproxy http://127.0.0.1:9095/mcp
claude plugin marketplace add nguyenhunga5/tonyproxy-agent-kit
claude plugin install tonyproxy@tonyproxy-agent-kit
```

The plugin adds the `tonyproxy` skill and three commands: `/tp-why-failed
[host]`, `/tp-curl <id>` and `/tp-slow [n]`. It has no server entry of its
own, so the port is never hard-coded and the server is registered once.

## Codex

Paste [`codex/config.toml.snippet`](codex/config.toml.snippet) into
`~/.codex/config.toml`, then run `codex mcp login tonyproxy`. Add
[`codex/AGENTS.md`](codex/AGENTS.md) to your project's `AGENTS.md` for the
skill text.

## Cursor

Merge [`cursor/mcp.json`](cursor/mcp.json) into `.cursor/mcp.json` and copy
[`cursor/rules/tonyproxy.mdc`](cursor/rules/tonyproxy.mdc) into
`.cursor/rules/`.

## Other clients

```
MCP endpoint (streamable HTTP): http://127.0.0.1:9095/mcp
Auth: OAuth 2.1 with PKCE and dynamic client registration; metadata at http://127.0.0.1:9095/.well-known/oauth-protected-resource
Run your client's authorize step; TonyProxy shows an Allow/Deny sheet once.
```

Give the agent the text of [`shared/SKILL.md`](shared/SKILL.md) as its
instructions.

## Editing the guidance

Edit `shared/SKILL.md` only, then run `sh scripts/sync.sh` and commit the
generated files with it.

Tested with TonyProxy <version> — see the app's release notes.

## License

MIT — see [LICENSE](LICENSE).
