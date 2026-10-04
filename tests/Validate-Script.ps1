$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$scriptPath = Join-Path $repoRoot 'Uninstall ALL ESET PRODUCT In Safe Mode.ps1'

if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
    Write-Error "Missing production script: $scriptPath"
    exit 1
}

$tokens = $null
$parseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile(
    $scriptPath,
    [ref]$tokens,
    [ref]$parseErrors
)

if ($parseErrors.Count -gt 0) {
    Write-Host 'PowerShell parse errors:'
    $parseErrors | ForEach-Object { Write-Host "- $($_.Message)" }
    exit 1
}

$content = Get-Content -LiteralPath $scriptPath -Raw

$requiredFragments = @(
    "https://download.eset.com/com/eset/tools/installers/eset_apps_remover/latest/esetuninstaller.exe",
    "bcdedit /set '{default}' safeboot minimal",
    'bcdedit /deletevalue {current} safeboot',
    'sc delete ""ESET Removal""',
    'shutdown -r -f -t 0'
)

foreach ($fragment in $requiredFragments) {
    if (-not $content.Contains($fragment)) {
        Write-Error "Required safety/workflow invariant is missing: $fragment"
        exit 1
    }
}

if ($content -match "DownloadFile\('http://") {
    Write-Error 'The ESET uninstaller download must use HTTPS.'
    exit 1
}

Write-Host 'PowerShell syntax and repository safety invariants passed.'
