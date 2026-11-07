# TonyProxy agent kit

Skill text and client configs for the MCP server built into
[TonyProxy](https://tonyapps.org), the macOS proxy inspector. The server
exposes nine tools that read captured traffic and, once you allow agents to
make changes, tools that control capture and add Map Local, Map Remote,
Rewrite and breakpoint rules. This kit teaches an agent to use them well
(summaries before listings, small pages, one transaction at a time, `export`
for cURL repros, cleaning up the rules it adds) and gives each client its
config file.

The tools themselves are not defined here: the server advertises them. The
guidance lives once, in [`shared/SKILL.md`](shared/SKILL.md);
`scripts/sync.sh` copies it into each pack.

Pairing is OAuth; TonyProxy shows an Allow/Deny sheet; no token lives in this repo.

Turn the server on in TonyProxy → Settings → MCP Server. Its "Agent setup"
picker copies the exact lines for your client with your port filled in. The
examples below use the default port, 9095.

## Claude Code

Install the plugin (CLI below, or add the marketplace on the plugins page in
the desktop app and click Install):

```bash
claude plugin marketplace add nguyenhunga5/tonyproxy-agent-kit
claude plugin install tonyproxy@tonyproxy-agent-kit
```

The plugin registers the server at the default port, 9095. Click **Connect**
on the plugin (or `/mcp` → `plugin:tonyproxy:tonyproxy` → Authenticate);
TonyProxy shows an Allow/Deny sheet once. The sign-in page is served over
https with a certificate from TonyProxy's CA, so install and trust the CA
first (Settings → Certificate).

Write tools stay hidden until you turn on Settings → MCP → "Allow agents to
make changes" and tick "Can control capture" or "Can change rules" for the
client in Paired Clients. Pairing alone grants read access only.

It also adds the `tonyproxy` skill and three commands: `/tp-why-failed
[host]`, `/tp-curl <id>` and `/tp-slow [n]`.

On a custom port, register the server by hand (Settings copies the line):

```bash
claude mcp add --transport http tonyproxy http://127.0.0.1:<port>/mcp
```

Upgrading from 0.1.0, where the server was registered by hand on 9095? Run
`claude mcp remove tonyproxy` so the tools are not listed twice.

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
