<#
.SYNOPSIS
  Instala (ou remove) as skills do MyAiToolKit para o Codex.

.DESCRIPTION
  As skills vao para <raiz>\.agents\skills\<nome>\ e o restante do toolkit para
  <raiz>\.agents\myaitoolkit-shared\. Toda ocorrencia de ${CLAUDE_PLUGIN_ROOT}
  nos .md copiados vira o caminho absoluto da pasta compartilhada.

.EXAMPLE
  ./install.ps1 -Scope user
  ./install.ps1 -Scope repo -Target ..\meu-projeto
  ./install.ps1 -Scope user -Uninstall
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('user', 'repo')]
  [string]$Scope,

  [string]$Target,

  [switch]$Uninstall,

  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$toolkitRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

if ($Scope -eq 'user') {
  $root = $HOME
} else {
  $root = if ($Target) { $Target } else { (Get-Location).Path }
}
if (-not (Test-Path -LiteralPath $root -PathType Container)) {
  throw "Pasta de destino nao existe: $root"
}
$root = (Resolve-Path -LiteralPath $root).Path

$skillsDir = Join-Path $root '.agents\skills'
$sharedDir = Join-Path $root '.agents\myaitoolkit-shared'
$manifest = Join-Path $sharedDir '.installed'

function Invoke-Step([string]$Description, [scriptblock]$Action) {
  if ($DryRun) {
    Write-Host "+ $Description"
  } else {
    & $Action
  }
}

function Get-PreviousSkills {
  if (Test-Path -LiteralPath $manifest) {
    Get-Content -LiteralPath $manifest |
      Where-Object { $_ -like 'skill:*' } |
      ForEach-Object { $_.Substring(6) }
  }
}

function Remove-Previous {
  foreach ($name in Get-PreviousSkills) {
    $path = Join-Path $skillsDir $name
    Invoke-Step "remover $path" { if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Recurse -Force } }
  }
  Invoke-Step "remover $sharedDir" { if (Test-Path -LiteralPath $sharedDir) { Remove-Item -LiteralPath $sharedDir -Recurse -Force } }
}

if ($Uninstall) {
  if (-not (Test-Path -LiteralPath $manifest)) {
    Write-Host "Nenhuma instalacao do MyAiToolKit encontrada em $root\.agents."
    return
  }
  Remove-Previous
  Write-Host "MyAiToolKit removido de $root\.agents."
  return
}

$version = (Get-Content -Raw -LiteralPath (Join-Path $toolkitRoot '.claude-plugin\plugin.json') | ConvertFrom-Json).version
# Barras normais funcionam no Codex em qualquer sistema e evitam escapes no markdown.
$sharedRef = $sharedDir -replace '\\', '/'

$installedPreviously = @(Get-PreviousSkills)
Remove-Previous

# 1. Pasta compartilhada: espelho do toolkit.
Invoke-Step "criar $sharedDir" { New-Item -ItemType Directory -Force -Path $sharedDir | Out-Null }
foreach ($item in 'skills', 'templates', 'stacks', 'adapters', 'REFERENCES.md', 'LICENSE') {
  $source = Join-Path $toolkitRoot $item
  if (Test-Path -LiteralPath $source) {
    Invoke-Step "copiar $item" { Copy-Item -LiteralPath $source -Destination $sharedDir -Recurse -Force }
  }
}

# 2. Skills no local que o Codex le.
Invoke-Step "criar $skillsDir" { New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null }
$installed = @()
foreach ($skill in Get-ChildItem -LiteralPath (Join-Path $toolkitRoot 'skills') -Directory) {
  $destination = Join-Path $skillsDir $skill.Name
  if ((Test-Path -LiteralPath $destination) -and ($installedPreviously -notcontains $skill.Name)) {
    Write-Warning "Ja existe uma skill '$($skill.Name)' que nao e do MyAiToolKit em $skillsDir - mantida, nao sobrescrita."
    continue
  }
  Invoke-Step "copiar skill $($skill.Name)" { Copy-Item -LiteralPath $skill.FullName -Destination $destination -Recurse -Force }
  $installed += $skill.Name
}

# 3. Resolve ${CLAUDE_PLUGIN_ROOT} nos .md copiados.
if (-not $DryRun) {
  $folders = @($sharedDir) + ($installed | ForEach-Object { Join-Path $skillsDir $_ })
  foreach ($folder in $folders) {
    foreach ($file in Get-ChildItem -LiteralPath $folder -Recurse -File -Filter '*.md') {
      $content = [System.IO.File]::ReadAllText($file.FullName)
      $updated = $content.Replace('${CLAUDE_PLUGIN_ROOT}', $sharedRef)
      if ($updated -ne $content) {
        [System.IO.File]::WriteAllText($file.FullName, $updated, (New-Object System.Text.UTF8Encoding($false)))
      }
    }
  }

  # 4. Manifesto da instalacao.
  $lines = @("version:$version", "scope:$Scope", "installed_at:$((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))")
  $lines += $installed | ForEach-Object { "skill:$_" }
  [System.IO.File]::WriteAllLines($manifest, $lines, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host "MyAiToolKit $version instalado para o Codex em $root\.agents ($($installed.Count) skills)."
Write-Host 'Chame no Codex com $sdd-start, $sdd-setup, $spike, $code-review...'
