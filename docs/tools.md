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

## Public diagnostic tools

The Tools endpoint at `https://mcp.dotmoose.com/tools/mcp` needs no account. It runs the same public checks as the free tools at dotmoose.com/tools. Every diagnostic result includes a `webTool` link to the matching page on dotmoose.com, where the same check can be repeated in a browser.

DNS and domains:

- `check_dns_propagation`: A, AAAA, MX, NS, and TXT answers from the Cloudflare, Google, and Quad9 resolvers.
- `check_domain_delegation`: Delegation nameservers and their A and AAAA glue addresses.
- `check_dnssec`: DS and DNSKEY records and the validating resolver AD flag.
- `trace_cname_chain`: The CNAME chain for a hostname, with loop detection.
- `lookup_domain_rdap`: The public RDAP registration summary. Registrant contact fields are not returned.
- `lookup_ip_info`: RDAP network data and ASN for a hostname or IP address.
- `check_forward_confirmed_rdns`: PTR record for an IP address and whether the returned name resolves back to it.

TLS and web:

- `check_tls_certificate`: TLS version, cipher, and certificate details for a host on port 443.
- `check_tls_configuration`: Which TLS protocol versions a host accepts.
- `check_http_chain`: Each redirect hop with status codes and response headers.
- `check_http_status`: The final status after redirects.
- `measure_web_performance`: DNS, connect, TLS, and time to first byte from the DotMoose diagnostic node. A network timing sample, not a browser rendering benchmark.
- `check_website_security`: Security headers, cookie attributes, and CORS policy from public responses.
- `check_security_txt`: The parsed security.txt file for a site.
- `check_compression`: Whether a URL is served with gzip or Brotli compression.
- `check_ipv6_website`: Whether a site answers over IPv6, compared with IPv4.
- `check_favicon`: The favicon a site declares, with its URL, type, and size.
- `audit_page_links`: Status of up to 20 same-origin links found on one page.
- `check_page_metadata`: Title, meta description, canonical, headings, hreflang, and JSON-LD types for a page.
- `test_robots_txt`: Whether a user agent may fetch a path under the site robots.txt rules.
- `validate_sitemap`: Sitemap structure, URL count, and fetch errors.

Mail:

- `check_spf`: The SPF record for a domain, with the full include chain counted against the limit of 10 DNS lookup terms.
- `check_dmarc`: The DMARC record at _dmarc for a domain.
- `check_dkim`: The DKIM public key record for a domain and selector.
- `check_mx_records`: MX records with the A and AAAA addresses of each mail server.
- `check_smtp_starttls`: Banner, EHLO, and STARTTLS support on port 25. No mail is sent.
- `check_mta_sts`: The MTA-STS DNS record and published policy file.
- `check_tls_rpt`: The TLS-RPT record at _smtp._tls for a domain.
- `check_bimi`: The BIMI record for a domain and selector.
- `check_ip_blacklists`: An IP address, or the addresses a hostname resolves to, against the reviewed DNS blacklist providers.

Looking Glass, from the DotMoose network in Canada:

- `looking_glass_ping`: Four ICMP echo probes to a public host or IP address.
- `looking_glass_traceroute`: Route trace, up to 20 hops, one probe per hop.
- `looking_glass_path`: Route sample, up to 20 hops, three probes per hop.

Calculators and builders, computed locally on the server:

- `calculate_subnet`: Network, broadcast or last address, and counts for an IPv4 or IPv6 CIDR block.
- `ip_range_to_cidr`: The smallest set of CIDR blocks covering an address range exactly.
- `calculate_bandwidth`: Link speed to monthly transfer, monthly transfer to average rate, and file transfer times.
- `estimate_storage_growth`: Storage size projected over up to 120 months at a constant monthly growth rate.
- `estimate_backup_retention`: Backup storage for a grandfather-father-son retention plan.
- `build_spf_record`: An SPF record assembled from IP ranges and includes, with its DNS lookup terms counted.
- `build_dmarc_record`: A DMARC record assembled from a policy and report addresses.

Targets must resolve only to public addresses; private, loopback, link-local, CGNAT, metadata, documentation, reserved, and multicast destinations are rejected before any connection. Internal monitoring endpoints and account data are not part of this surface.

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
- "Check the SPF, DKIM, and DMARC records for my domain."
- "Run a traceroute from DotMoose in Canada to my server."
- "Is this IP address on any email blacklists?"
- "What subnet is 203.0.113.0/24, and how many usable hosts does it have?"
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
