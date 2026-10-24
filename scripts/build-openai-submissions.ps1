[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $repoRoot 'submissions/openai'
$distRoot = Join-Path $repoRoot 'dist/openai'
$schemaRoot = Join-Path $distRoot '.schemas'

$resolvedRepo = [System.IO.Path]::GetFullPath($repoRoot)
$resolvedDist = [System.IO.Path]::GetFullPath($distRoot)
if (-not $resolvedDist.StartsWith($resolvedRepo + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to write outside the repository: $resolvedDist"
}

if (Test-Path -LiteralPath $distRoot) {
    Remove-Item -LiteralPath $distRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $schemaRoot -Force | Out-Null

$schemas = @{
    plugin = 'https://agent-plugins.org/schemas/1.0.0/plugin.schema.json'
    mcp = 'https://agent-plugins.org/schemas/1.0.0/mcp.schema.json'
}
foreach ($schemaName in $schemas.Keys) {
    $schemaPath = Join-Path $schemaRoot "$schemaName.schema.json"
    Invoke-WebRequest -Uri $schemas[$schemaName] -OutFile $schemaPath -UseBasicParsing
}

$packages = @('account', 'public', 'tools')
$reviewMetadata = Get-Content -LiteralPath (Join-Path $sourceRoot 'tool-annotation-justifications.json') -Raw | ConvertFrom-Json -Depth 100
$expectedToolCounts = @{ account = 64; public = 8; tools = 40 }
foreach ($package in $packages) {
    $source = Join-Path $sourceRoot $package
    $staging = Join-Path $distRoot $package
    $assetDir = Join-Path $staging 'assets'
    New-Item -ItemType Directory -Path $assetDir -Force | Out-Null

    foreach ($manifestName in @('plugin.json', 'mcp.json')) {
        $manifest = Join-Path $source $manifestName
        if (-not (Test-Path -LiteralPath $manifest)) {
            throw "Missing $manifest"
        }
        Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json -Depth 100 | Out-Null
        Copy-Item -LiteralPath $manifest -Destination (Join-Path $staging $manifestName)
    }

    $pluginManifest = Get-Content -LiteralPath (Join-Path $source 'plugin.json') -Raw | ConvertFrom-Json -Depth 100
    $mcpManifest = Get-Content -LiteralPath (Join-Path $source 'mcp.json') -Raw | ConvertFrom-Json -Depth 100
    if (@($mcpManifest.mcpServers.PSObject.Properties).Count -ne 1) {
        throw "OpenAI submission $package must declare exactly one MCP server"
    }
    $testCases = $pluginManifest.extensions.'com.openai'.review.test_cases
    if (@($testCases.positive).Count -ne 5 -or @($testCases.negative).Count -ne 3) {
        throw "OpenAI submission $package must declare exactly five positive and three negative test cases"
    }
    $reviewSurface = $reviewMetadata.surfaces.$package
    if ($reviewSurface.endpoint -ne @($mcpManifest.mcpServers.PSObject.Properties)[0].Value.url) {
        throw "OpenAI tool review endpoint does not match the $package MCP manifest"
    }
    if (@($reviewSurface.tools.PSObject.Properties).Count -ne $expectedToolCounts[$package]) {
        throw "OpenAI tool review metadata has the wrong $package tool count"
    }
    foreach ($tool in @($reviewSurface.tools.PSObject.Properties)) {
        foreach ($hint in @('readOnlyHint', 'openWorldHint', 'destructiveHint')) {
            if ($tool.Value.annotations.$hint -isnot [bool]) { throw "$package/$($tool.Name) is missing boolean $hint" }
        }
        foreach ($field in @('read_only_justification', 'open_world_justification', 'destructive_justification')) {
            $value = [string]$tool.Value.justifications.$field
            if ([string]::IsNullOrWhiteSpace($value) -or $value.Length -gt 200) {
                throw "$package/$($tool.Name) has an invalid $field"
            }
        }
    }

    $server = @($mcpManifest.mcpServers.PSObject.Properties)[0].Value
    $auth = $server.extensions.'com.openai'.auth
    $expectedAuthType = if ($package -eq 'account') { 'oauth' } else { 'none' }
    if ($auth.type -ne $expectedAuthType) {
        throw "OpenAI submission $package must declare auth.type=$expectedAuthType"
    }
    if ($package -eq 'account') {
        if ($auth.client.mode -ne 'cimd' -or $auth.resource -ne 'https://mcp.dotmoose.com/mcp') {
            throw 'Account submission must use CIMD preference and the exact MCP OAuth resource'
        }
        foreach ($scope in @('openid', 'email', 'mcp:connect')) {
            if ($scope -notin @($auth.baseScopes)) { throw "Account submission is missing base scope $scope" }
        }
        if ($auth.oidcEnabled -ne $true -or $auth.oidcUserinfoEndpoint -ne 'https://auth.dotmoose.com/oauth/userinfo') {
            throw 'Account submission must declare the production OIDC UserInfo endpoint'
        }
    }

    $pluginValid = Get-Content -LiteralPath (Join-Path $source 'plugin.json') -Raw |
        Test-Json -SchemaFile (Join-Path $schemaRoot 'plugin.schema.json')
    # The portable 1.0 schema currently rejects vendor extensions even though
    # OpenAI's current plugin documentation requires extensions.com.openai.auth
    # on each MCP server. Validate a clone with that extension removed against
    # the portable schema, and validate the OpenAI extension explicitly above.
    $portableMcp = Get-Content -LiteralPath (Join-Path $source 'mcp.json') -Raw | ConvertFrom-Json -Depth 100
    foreach ($property in @($portableMcp.mcpServers.PSObject.Properties)) {
        $property.Value.PSObject.Properties.Remove('extensions')
    }
    $mcpValid = $portableMcp | ConvertTo-Json -Depth 100 |
        Test-Json -SchemaFile (Join-Path $schemaRoot 'mcp.schema.json')
    if (-not $pluginValid -or -not $mcpValid) {
        throw "Schema validation failed for $package"
    }

    Copy-Item -LiteralPath (Join-Path $repoRoot 'assets/icon.svg') -Destination (Join-Path $assetDir 'icon.svg')
    Copy-Item -LiteralPath (Join-Path $sourceRoot 'tool-annotation-justifications.json') -Destination (Join-Path $staging 'tool-annotation-justifications.json')
    $archivePath = Join-Path $distRoot "dotmoose-$package-openai.zip"
    Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $archivePath -CompressionLevel Optimal
}

Remove-Item -LiteralPath $schemaRoot -Recurse -Force
Get-ChildItem -LiteralPath $distRoot -Filter '*.zip' | Select-Object Name, Length
