# OpenAI public plugin submissions

The repository's root plugin remains the all-in-one package for local installation. OpenAI's public review flow connects one MCP server per plugin, so the source manifests in `submissions/openai/` produce three separate review bundles:

| Bundle | MCP endpoint | Authentication |
| --- | --- | --- |
| `dotmoose-account-openai.zip` | `https://mcp.dotmoose.com/mcp` | OAuth 2.1 |
| `dotmoose-public-openai.zip` | `https://mcp.dotmoose.com/public/mcp` | None |
| `dotmoose-tools-openai.zip` | `https://mcp.dotmoose.com/tools/mcp` | None |

Build and validate all bundles from the repository root:

```powershell
pwsh -NoProfile -File scripts/build-openai-submissions.ps1
```

The script parses each manifest, validates it against the official Agent Plugins schemas, copies the public brand asset, and creates uploadable archives under `dist/openai/`. The generated archives are intentionally ignored by Git.

Before requesting review, DotMoose must add a current demo-recording URL for each submission. The authenticated account submission also requires a dedicated reviewer account with representative sample data and no MFA. Enter reviewer credentials only in the private submission portal; never commit them to this repository or place them in an MCP prompt.
