# DotMoose MCP tool guide

## Public discovery tools

### `list_public_products`

Lists currently published DotMoose products from the live catalog.

### `quote_public_product`

Returns a non-binding quote for one public product and billing cycle. Tax is calculated during first-party checkout.

### `recommend_product`

Recommends the smallest practical current product set from a bounded workload description.

### `list_current_promotions`

Lists promotions that are currently active in the live catalog.

### `check_domain_availability`

Checks whether a valid domain name is available through the DotMoose domain service.

### `quote_domain`

Returns domain registration, transfer, or renewal pricing when available.

### `plan_app_publication`

Validates a high-level application publication request and explains the supported handoff. It does not accept repository credentials, tokens, or secret values.

### `start_signup`

Creates a short-lived signed product-selection intent and returns a `clients.dotmoose.com` continuation. Customer identity, passwords, MFA, payment details, domain transfer codes, and credentials are entered only on DotMoose first-party pages.

## Account workflows

The OAuth-protected endpoint currently exposes 64 tools. Clients discover the exact live schemas through `tools/list`. The main workflows are:

- Inspect the authenticated session and granted scopes.
- List services and inspect a service without exposing backend account identifiers.
- Read support departments and tickets, create a ticket, or add a reply.
- Inspect DNS, TLS, HTTP, runtime, resources, logs, backups, security, deployments, and provider state.
- Diagnose website or server problems from live evidence.
- Assess security, right-sizing, and launch readiness.
- Inspect a project and plan deployment without accepting secrets.
- Prepare a Managed App deployment from an immutable OCI digest.
- Prepare a Managed App build from an exact GitHub HTTPS repository, ref, Dockerfile path, and context path.
- Read deployment history and verify the deployed source, commit, immutable image, runtime, and managed HTTPS.
- Prepare other supported account actions and execute only a previously stored, confirmation-gated action ID.

## Example prompts

- "List the DotMoose products that fit a small WordPress site."
- "Check whether example.ca is available and quote one year."
- "Show my active hosting services."
- "Assess whether my Managed App service is ready to launch."
- "Prepare a deployment from my GitHub repository, but do not execute it yet."
- "Show the exact action awaiting confirmation before anything changes."

## Safety behavior

- Read operations report unavailable or missing telemetry as unknown, not healthy.
- Write operations require appropriate OAuth scopes.
- Billable, destructive, DNS, restore, rebuild, cancellation, and deployment execution require explicit authorization and confirmation.
- Execution revalidates the stored action and current service state.
- Tool inputs reject secret values, credentials, unsafe repository URLs, path traversal, command-line flag injection, and unexpected fields.
- Tool responses do not expose access tokens, refresh tokens, passwords, private keys, deployment secrets, backend account IDs, or provider credentials.
