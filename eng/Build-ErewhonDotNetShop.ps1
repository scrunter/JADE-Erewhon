#Requires -Version 7.4
[CmdletBinding()]
param(
    [string]$RepositoryRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')),
    [Parameter(Mandatory)][string]$OutputDirectory,
    [switch]$LockedRestore
)

$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath($RepositoryRoot)
$output = [IO.Path]::GetFullPath($OutputDirectory)
$profilePath = Join-Path $root '.jadesre/source-profile.json'
$profile = Get-Content -LiteralPath $profilePath -Raw | ConvertFrom-Json -Depth 8

$sourceCommit = (& git -C $root rev-parse HEAD).Trim()
$sourceStatus = @(& git -C $root status --porcelain=v1 --untracked-files=all)
if ($LASTEXITCODE -ne 0 -or $sourceCommit -cnotmatch '^[a-f0-9]{40}$') {
    throw 'Cannot identify the source commit.'
}
if ($sourceStatus.Count -ne 0) {
    throw 'The Erewhon source checkout is not clean.'
}

if ($profile.schemaVersion -cne '1.0' -or $profile.profileId -cne 'lab-erewhon' -or
    $profile.repository -cne 'https://github.com/scrunter/JADE-Erewhon' -or
    $profile.build.targetFramework -cne 'net8.0-windows' -or
    $profile.build.runtimeIdentifier -cne 'win-x64' -or
    $profile.build.joobVersion -cne '25.0.2.3') {
    throw 'The JadeSRE build profile differs from the reviewed contract.'
}

foreach ($candidate in @($root, $output)) {
    for ($cursor = $candidate; $cursor; $cursor = [IO.Path]::GetDirectoryName($cursor)) {
        if (Test-Path -LiteralPath $cursor) {
            if ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
                throw 'A build path is redirected.'
            }
        }
    }
}
if ($output.StartsWith($root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Build output must not be written into the source checkout.'
}
if (Test-Path -LiteralPath $output) {
    throw 'Build output already exists.'
}

$solution = Join-Path $root $profile.build.solution
$project = Join-Path $root $profile.build.entryProject
$restoreArguments = @('restore', $solution, '--runtime', $profile.build.runtimeIdentifier)
if ($LockedRestore) { $restoreArguments += '--locked-mode' }
& dotnet @restoreArguments
if ($LASTEXITCODE -ne 0) { throw 'Erewhon .NET Shop restore failed.' }

[void][IO.Directory]::CreateDirectory($output)
& dotnet publish $project `
    --configuration $profile.build.configuration `
    --framework $profile.build.targetFramework `
    --runtime $profile.build.runtimeIdentifier `
    --self-contained false `
    --no-restore `
    --output $output `
    -p:Platform=x64 `
    -p:ContinuousIntegrationBuild=true
if ($LASTEXITCODE -ne 0) { throw 'Erewhon .NET Shop publish failed.' }

$files = @(Get-ChildItem -LiteralPath $output -File -Recurse | Sort-Object FullName | ForEach-Object {
    [ordered]@{
        path = [IO.Path]::GetRelativePath($output, $_.FullName).Replace('\', '/')
        bytes = $_.Length
        sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
})
if (-not ($files.path -contains 'ShopUI.exe') -or -not ($files.path -contains 'ShopUI.dll') -or
    -not ($files.path -contains 'ErewhonExposures.dll')) {
    throw 'The expected .NET Shop outputs were not produced.'
}
$joobAssemblies = @($profile.build.joobAssemblies)
if ($joobAssemblies.Count -ne 6) { throw 'The reviewed JADE .NET runtime inventory changed.' }
foreach ($assembly in $joobAssemblies) {
    if ($assembly.path -cnotmatch '^JadeSoftware\.[A-Za-z.]+\.dll$' -or
        $assembly.sha256 -cnotmatch '^[a-f0-9]{64}$' -or $assembly.bytes -lt 1) {
        throw 'Invalid JADE .NET runtime lock member.'
    }
    $published = Join-Path $output $assembly.path
    if (-not (Test-Path -LiteralPath $published -PathType Leaf) -or
        (Get-Item -LiteralPath $published).Length -ne $assembly.bytes -or
        (Get-FileHash -LiteralPath $published -Algorithm SHA256).Hash -ine $assembly.sha256) {
        throw ('The published JADE .NET runtime does not match JADE 25.0.02.011: ' + $assembly.path)
    }
}

$manifest = [ordered]@{
    schemaVersion = '1.0'
    result = 'ErewhonDotNetShopBuilt'
    repository = $profile.repository
    sourceCommit = $sourceCommit
    configuration = $profile.build.configuration
    platform = $profile.build.platform
    targetFramework = $profile.build.targetFramework
    runtimeIdentifier = $profile.build.runtimeIdentifier
    selfContained = $false
    joobPackage = $profile.build.joobPackage
    joobVersion = $profile.build.joobVersion
    joobAssemblies = $joobAssemblies
    sourceProfileSha256 = (Get-FileHash -LiteralPath $profilePath -Algorithm SHA256).Hash.ToLowerInvariant()
    files = $files
}
$manifestPath = Join-Path $output 'artifact.sha256.json'
[IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 8), [Text.UTF8Encoding]::new($false))

[pscustomobject]@{
    Result = $manifest.result
    SourceCommit = $sourceCommit
    OutputDirectory = $output
    ManifestSha256 = (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
    Files = $files.Count
}
