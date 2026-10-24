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

    $pluginValid = Get-Content -LiteralPath (Join-Path $source 'plugin.json') -Raw |
        Test-Json -SchemaFile (Join-Path $schemaRoot 'plugin.schema.json')
    $mcpValid = Get-Content -LiteralPath (Join-Path $source 'mcp.json') -Raw |
        Test-Json -SchemaFile (Join-Path $schemaRoot 'mcp.schema.json')
    if (-not $pluginValid -or -not $mcpValid) {
        throw "Schema validation failed for $package"
    }

    Copy-Item -LiteralPath (Join-Path $repoRoot 'assets/icon.svg') -Destination (Join-Path $assetDir 'icon.svg')
    $archivePath = Join-Path $distRoot "dotmoose-$package-openai.zip"
    Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $archivePath -CompressionLevel Optimal
}

Remove-Item -LiteralPath $schemaRoot -Recurse -Force
Get-ChildItem -LiteralPath $distRoot -Filter '*.zip' | Select-Object Name, Length
