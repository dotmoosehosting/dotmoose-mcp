# OpenAI public plugin submissions

The repository's root plugin remains the all-in-one package for local installation. OpenAI's public review flow connects one MCP server per plugin, so the source manifests in `submissions/openai/` produce three separate review bundles. Upload each ZIP through **With MCP**, then connect and scan the declared production endpoint in the developer portal.

| Bundle | MCP endpoint | Authentication |
| --- | --- | --- |
| `dotmoose-account-openai.zip` | `https://mcp.dotmoose.com/mcp` | OAuth 2.1 |
| `dotmoose-public-openai.zip` | `https://mcp.dotmoose.com/public/mcp` | None |
| `dotmoose-tools-openai.zip` | `https://mcp.dotmoose.com/tools/mcp` | None |

Build and validate all bundles from the repository root:

```powershell
pwsh -NoProfile -File scripts/build-openai-submissions.ps1
```

The script parses each manifest, validates the portable MCP fields against the official Agent Plugins schema, separately validates the current OpenAI authentication extension, copies the public brand asset, and creates uploadable archives under `dist/openai/`. The generated archives are intentionally ignored by Git.

`submissions/openai/tool-annotation-justifications.json` records the exact three safety-hint values and a short portal-ready justification for all 112 tools across the three endpoints. Regenerate it from the private production source whenever tool metadata changes; never edit it to disagree with the live tool scan.

The account bundle uses OAuth with CIMD preference, discovery fallback, PKCE, the exact MCP resource identifier, and OIDC `openid email` support. The public and tools bundles explicitly declare no authentication. No client secret, access token, account password, or reviewer credential belongs in these files.

Before requesting review, DotMoose must add a current accessible demo-recording URL to each `plugin.json`. The authenticated account submission also requires a dedicated reviewer account with representative sample data and no MFA, email code, SMS code, or magic-link dependency. Enter reviewer credentials only in the private submission portal; never commit them to this repository or place them in an MCP prompt.

During MCP setup, copy the portal's exact domain-verification token into the production secret store for `DOTMOOSE_OPENAI_APPS_CHALLENGE_TOKEN`, restart the authenticated MCP service, and verify `https://mcp.dotmoose.com/.well-known/openai-apps-challenge`. Serve one challenge at a time; use a distinct eligible host or OpenAI support if simultaneous plugin challenges would collide.
