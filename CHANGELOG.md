# Changelog

## 1.2.0 — 2026-10-24

- Added separately validated OpenAI submission manifests for the account, public discovery, and public diagnostic MCP servers while retaining the all-in-one local plugin.
- Added a repeatable build script that produces secret-free, uploadable ZIP archives after validating both official Agent Plugin schemas.

## 1.1.0 — 2026-10-23

- Added the anonymous DotMoose Tools MCP endpoint at `https://mcp.dotmoose.com/tools/mcp`: 33 public diagnostic tools (DNS, domains, mail authentication, TLS, HTTP, website checks, blacklists, and Looking Glass probes from Canada) plus 7 local calculators and SPF/DMARC record builders.
- Added registry and Agent Plugin manifests for the Tools server (`server-tools.json`, `mcp-tools.json`).
- Verified the live tool inventory and live SPF, TLS, DMARC, bandwidth, and Looking Glass results against production.

## 1.0.0 — 2026-10-23

- Published the public discovery and signed-signup-handoff MCP endpoint.
- Published the OAuth-protected existing-customer account MCP endpoint.
- Added portable MCP, Agent Plugin, official registry, and Cursor marketplace metadata.
- Added browser-readable setup guides at both endpoint URLs.
- Verified the live product catalogue, WordPress recommendations, promotion privacy, domain quotes, authoritative domain availability, and OAuth boundary.
