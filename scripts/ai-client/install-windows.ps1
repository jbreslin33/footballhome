# scripts/ai-client/install-windows.ps1
#
# Installs ollama on Windows and pulls a coding model.  Run this on your
# WINDOWS machine (the client you SSH into fishtown from), not on the
# server.
#
# See scripts/ai-client/README.md for the full topology + SSH tunnel
# instructions.
#
# Requirements:
#   - Windows 10 (build 1809+) or Windows 11
#   - PowerShell 5.1 or PowerShell 7+
#   - winget (bundled with Windows 11; on Windows 10 install from the
#     Microsoft Store: "App Installer")
#   - OpenSSH client (bundled with Windows 10 1803+; enable via
#     Settings → Apps → Optional Features if missing)
#
# Usage (open PowerShell in this directory):
#   powershell -ExecutionPolicy Bypass -File install-windows.ps1
#   powershell -ExecutionPolicy Bypass -File install-windows.ps1 -Model qwen2.5-coder:14b
#   powershell -ExecutionPolicy Bypass -File install-windows.ps1 -NoPull

param(
    [string]$Model = "",
    [switch]$NoPull
)

$ErrorActionPreference = "Stop"

function Info($msg)    { Write-Host "-> $msg" -ForegroundColor Blue }
function Ok($msg)      { Write-Host "OK  $msg" -ForegroundColor Green }
function Warn($msg)    { Write-Host "WRN $msg" -ForegroundColor Yellow }
function Err($msg)     { Write-Host "ERR $msg" -ForegroundColor Red }

# ── Guard: Windows only ───────────────────────────────────────────────
if (-not $IsWindows -and $PSVersionTable.PSVersion.Major -ge 6) {
    Err "This script is for Windows.  On macOS use install-mac.sh; on Linux use install-linux.sh."
    exit 1
}

# ── winget check ──────────────────────────────────────────────────────
$hasWinget = $null -ne (Get-Command winget -ErrorAction SilentlyContinue)

# ── ollama install ────────────────────────────────────────────────────
$hasOllama = $null -ne (Get-Command ollama -ErrorAction SilentlyContinue)
if (-not $hasOllama) {
    if ($hasWinget) {
        Info "Installing ollama via winget..."
        winget install --id Ollama.Ollama --accept-source-agreements --accept-package-agreements
    } else {
        Warn "winget not found — falling back to direct installer download."
        $installer = "$env:TEMP\OllamaSetup.exe"
        Info "Downloading https://ollama.com/download/OllamaSetup.exe ..."
        Invoke-WebRequest -Uri "https://ollama.com/download/OllamaSetup.exe" -OutFile $installer
        Info "Running installer (will prompt for UAC)..."
        Start-Process -FilePath $installer -Wait
        Remove-Item $installer -Force -ErrorAction SilentlyContinue
    }

    # winget installs into %LOCALAPPDATA%\Programs\Ollama which may not be
    # on PATH in the current shell.  Refresh so subsequent commands see it.
    $ollamaDir = "$env:LOCALAPPDATA\Programs\Ollama"
    if (Test-Path $ollamaDir) {
        $env:PATH = "$ollamaDir;$env:PATH"
    }

    if ($null -eq (Get-Command ollama -ErrorAction SilentlyContinue)) {
        Err "ollama not on PATH after install.  Open a NEW PowerShell window and re-run this script."
        exit 1
    }
    Ok "ollama installed: $(ollama --version 2>&1 | Select-Object -First 1)"
} else {
    Info "ollama already installed: $(ollama --version 2>&1 | Select-Object -First 1)"
    Info "To upgrade later: winget upgrade Ollama.Ollama"
}

# ── Wait for service to be reachable ──────────────────────────────────
# The Windows installer registers ollama as a background service that
# auto-starts on install and on login.  Give it up to 15s to bind.
Info "Waiting for ollama to bind 127.0.0.1:11434 ..."
$ready = $false
for ($i = 1; $i -le 15; $i++) {
    try {
        $resp = Invoke-WebRequest -Uri "http://127.0.0.1:11434/api/tags" -UseBasicParsing -TimeoutSec 1 -ErrorAction Stop
        if ($resp.StatusCode -eq 200) { $ready = $true; break }
    } catch {
        Start-Sleep -Seconds 1
    }
}
if ($ready) {
    Ok "ollama serving on 127.0.0.1:11434"
} else {
    Err "ollama did not respond on 127.0.0.1:11434 after 15s."
    Err "Check the system tray for the ollama icon, or run 'ollama serve' in a separate window."
    exit 1
}

# ── Auto-pick model from RAM if not specified ─────────────────────────
if ([string]::IsNullOrWhiteSpace($Model)) {
    $totalRamBytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
    $ramGB = [math]::Round($totalRamBytes / 1GB)
    if     ($ramGB -ge 48) { $Model = "qwen2.5-coder:32b" }
    elseif ($ramGB -ge 24) { $Model = "qwen2.5-coder:14b" }
    elseif ($ramGB -ge 12) { $Model = "qwen2.5-coder:7b"  }
    else                   { $Model = "qwen2.5-coder:3b"  }
    Info "Auto-picked model for ${ramGB} GB machine: $Model"
}

# ── Pull model ────────────────────────────────────────────────────────
if (-not $NoPull) {
    $installed = ollama list 2>$null | Select-Object -Skip 1 | ForEach-Object {
        ($_ -split '\s+')[0]
    }
    if ($installed -contains $Model) {
        Ok "Model already present: $Model"
    } else {
        Info "Pulling $Model (this can take several minutes)..."
        ollama pull $Model
        Ok "Model ready: $Model"
    }
} else {
    Warn "Skipping model pull (-NoPull)"
}

# ── SSH client check ──────────────────────────────────────────────────
$hasSsh = $null -ne (Get-Command ssh -ErrorAction SilentlyContinue)
if (-not $hasSsh) {
    Warn "OpenSSH client not found."
    Warn "Enable it: Settings → Apps → Optional Features → Add Feature → 'OpenSSH Client'"
    Warn "Or run in an elevated PowerShell:"
    Warn "  Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0"
}

# ── Guidance ──────────────────────────────────────────────────────────
$sshConfigPath = Join-Path $env:USERPROFILE ".ssh\config"
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "OK Windows client ready" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host ""
Write-Host "  1. Add this to $sshConfigPath (create the file if it doesn't exist):"
Write-Host ""
Write-Host "     Host fishtown"                          -ForegroundColor Yellow
Write-Host "         HostName fishtown.example.com"      -ForegroundColor Yellow
Write-Host "         User your-user"                     -ForegroundColor Yellow
Write-Host "         RemoteForward 11434 127.0.0.1:11434" -ForegroundColor Yellow
Write-Host "         ServerAliveInterval 60"             -ForegroundColor Yellow
Write-Host ""
Write-Host "     Edit HostName + User to match your setup."
Write-Host ""
Write-Host "  2. SSH into fishtown from any PowerShell / cmd / Windows Terminal window:"
Write-Host "     ssh fishtown"                            -ForegroundColor Yellow
Write-Host ""
Write-Host "  3. On fishtown, cd into the repo and run aider:"
Write-Host "     cd /srv/footballhome && aider"           -ForegroundColor Yellow
Write-Host ""
Write-Host "If aider picks a different model, edit .aider.conf.yml (or use --model)."
Write-Host ""
