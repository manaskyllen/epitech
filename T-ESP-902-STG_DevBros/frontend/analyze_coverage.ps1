$content = Get-Content "coverage\lcov.info" -Raw
$files = @{}
$current_file = $null
$lines = $content -split "`n"

foreach ($line in $lines) {
    if ($line -match '^SF:(.+)$') {
        $current_file = $matches[1]
        if (-not $files.ContainsKey($current_file)) {
            $files[$current_file] = @{'LH'=0; 'LF'=0}
        }
    }
    elseif ($line -match '^LH:(\d+)$' -and $current_file) {
        $files[$current_file]['LH'] = [int]$matches[1]
    }
    elseif ($line -match '^LF:(\d+)$' -and $current_file) {
        $files[$current_file]['LF'] = [int]$matches[1]
    }
}

# Global statistics
$totalLH = 0
$totalLF = 0
foreach ($file in $files.Keys) {
    $totalLH += $files[$file]['LH']
    $totalLF += $files[$file]['LF']
}

$globalCoverage = if ($totalLF -gt 0) { [Math]::Round(($totalLH / $totalLF) * 100, 2) } else { 0 }

Write-Host "=== 1. COUVERTURE GLOBALE ===" -ForegroundColor Cyan
Write-Host "Lignes testées (LH): $totalLH"
Write-Host "Total lignes (LF): $totalLF"  
Write-Host "Coverage global: $globalCoverage%"
Write-Host ""

# Filter lib/ files and calculate coverage
$libFiles = @()
foreach ($file in $files.Keys) {
    if ($file -like 'lib\*' -or $file -like 'lib/*') {
        $coverage = if ($files[$file]['LF'] -gt 0) { [Math]::Round(($files[$file]['LH'] / $files[$file]['LF']) * 100, 2) } else { 0 }
        $libFiles += [PSCustomObject]@{
            File = $file
            LH = $files[$file]['LH']
            LF = $files[$file]['LF']
            Coverage = $coverage
        }
    }
}

Write-Host "=== 2. TOP 15 FICHIERS AVEC PLUS BASSE COUVERTURE ===" -ForegroundColor Cyan
$lowCoverageFiles = $libFiles | Sort-Object Coverage | Select-Object -First 15
$lowCoverageFiles | ForEach-Object {
    Write-Host ("{0,-60} {1}% ({2}/{3})" -f $_.File, $_.Coverage, $_.LH, $_.LF)
}
Write-Host ""

Write-Host "=== 3. FICHIERS AVEC 0% DE COUVERTURE ===" -ForegroundColor Yellow
$zeroCoverageFiles = $libFiles | Where-Object { $_.Coverage -eq 0 }
Write-Host "Nombre total: $($zeroCoverageFiles.Count) fichiers"
Write-Host ""
$zeroCoverageFiles | ForEach-Object {
    Write-Host $_.File
}
Write-Host ""

Write-Host "=== 4. ANALYSE POUR ATTEINDRE 90% DE COUVERTURE ===" -ForegroundColor Green
# Estimate what would be needed to reach 90%
$needed = [Math]::Ceiling($totalLF * 0.9) - $totalLH
Write-Host "Lignes supplémentaires à tester pour 90%: $needed"
Write-Host ""
Write-Host "Fichiers à cible en priorité (impact potentiel le plus élevé):"

# Sort by potential impact (files with low coverage but many untested lines)
$priorityFiles = $libFiles | ForEach-Object {
    $untested = $_.LF - $_.LH
    $_ | Add-Member -NotePropertyName 'Untested' -NotePropertyValue $untested -PassThru
} | Where-Object { $_.Untested -gt 0 } | Sort-Object Untested -Descending | Select-Object -First 10

$priorityFiles | ForEach-Object {
    Write-Host ("{0,-60} {1}% - {2} lignes à tester" -f $_.File, $_.Coverage, $_.Untested)
}
