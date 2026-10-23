# DotMoose MCP

Official Model Context Protocol endpoints for DotMoose hosting, domains, support, diagnostics, and managed application deployment.

This repository contains public connection metadata and documentation. The production implementation remains operated by DotMoose so customers do not need to install or run a local server.

## Endpoints

| Endpoint | Authentication | Intended use |
| --- | --- | --- |
| `https://mcp.dotmoose.com/public/mcp` | None | Product and domain discovery, quotes, publication planning, and a secure first-party signup handoff |
| `https://mcp.dotmoose.com/mcp` | OAuth 2.1 | Existing-customer account, service, support, diagnostics, and confirmation-gated operations |

Health checks:

- `https://mcp.dotmoose.com/public/healthz`
- `https://mcp.dotmoose.com/healthz`

The service uses Streamable HTTP and the MCP `2026-07-28` protocol revision.

## Quick connection

For product and domain discovery, add this remote server to an MCP client:

```json
{
  "mcpServers": {
    "dotmoose-public": {
      "url": "https://mcp.dotmoose.com/public/mcp"
    }
  }
}
```

Existing DotMoose customers can use the authenticated endpoint. Compatible clients open DotMoose authorization in the browser and request the scopes needed for the selected tool:

```json
{
  "mcpServers": {
    "dotmoose": {
      "url": "https://mcp.dotmoose.com/mcp"
    }
  }
}
```

Do not put a DotMoose password, API token, payment detail, MFA code, domain transfer code, or deployment secret in an MCP configuration file or chat prompt.

## Client setup

### ChatGPT and Codex

The repository includes a portable Agent Plugin manifest. In supported local Codex clients, add this repository as a plugin marketplace source:

```text
codex plugin marketplace add dotmoosehosting/dotmoose-mcp
```

Restart the desktop app, open the Plugins Directory, select the DotMoose source, and install DotMoose. Authentication opens only when an account-scoped tool needs it.

For direct testing in ChatGPT Developer Mode, add `https://mcp.dotmoose.com/mcp` as a custom MCP server.

### Cursor

Add either endpoint to your user or project `mcp.json`. Cursor can also install portable Agent Plugins from a public Git repository, so this repository can be submitted directly to the Cursor Marketplace.

### Claude, VS Code, and other MCP clients

Use the remote Streamable HTTP URL in the client's MCP server settings. Choose the public endpoint for anonymous discovery or the account endpoint for OAuth-protected customer operations.

## What the tools do

The anonymous endpoint exposes eight intentionally narrow tools:

- `list_public_products`
- `quote_public_product`
- `recommend_product`
- `list_current_promotions`
- `check_domain_availability`
- `quote_domain`
- `plan_app_publication`
- `start_signup`

The account endpoint exposes tools for session and service discovery, support, diagnostics, security assessment, deployment planning, source and image deployment preparation, launch-readiness verification, and other account operations. See [docs/tools.md](docs/tools.md) for the supported workflows and safeguards.

## Safe action model

DotMoose separates planning from execution:

1. Read tools inspect the authenticated account and service state.
2. Prepare tools validate the requested change and store a short-lived action intent.
3. The client shows the action, consequences, and required confirmation.
4. Execute tools accept only the prepared action ID. They cannot replace its target or payload.
5. The service rechecks OAuth scopes, service version, capacity, billing state, and provider preconditions before mutation.

Managed App deployment accepts either an immutable OCI image digest or an exact GitHub HTTPS repository and safe build settings. Secrets remain saved references in DotMoose and are never accepted as tool input.

## Commercial boundary

The public MCP can create a short-lived selection intent and send the user to `clients.dotmoose.com` for first-party signup and checkout. It does not collect personal, password, MFA, payment, or credential data.

Managed App purchasing and general availability are controlled separately from the MCP software release. A working MCP deployment path does not by itself promise that a product is available for new purchase.

## Support and policies

- Website: https://dotmoose.com/
- Support: https://dotmoose.com/support/
- Privacy: https://dotmoose.com/privacy/
- Terms: https://dotmoose.com/terms/
- Security reporting: [SECURITY.md](SECURITY.md)

## License

The distribution metadata and documentation in this repository are licensed under the MIT License. DotMoose service use remains governed by the linked service terms.
