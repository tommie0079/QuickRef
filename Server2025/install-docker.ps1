# Run as Administrator
# Enables Containers + Hyper-V, installs Docker Engine + Compose on Windows,
# installs WSL2 (Ubuntu) and attempts to install Docker inside Ubuntu (for Linux containers).
# NOTE: Reboot if prompted. First-time WSL Ubuntu may ask you to create a user interactively.

# Helper functions
function Write-Info ($m)  { Write-Host "[INFO]  $m" -ForegroundColor Cyan }
function Write-Warn ($m)  { Write-Host "[WARN]  $m" -ForegroundColor Yellow }
function Write-Err  ($m)  { Write-Host "[ERROR] $m" -ForegroundColor Red }

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Err "Script must be run as Administrator. Exiting."
  exit 1
}

$needRestart = $false

# ---------------------------
# 1) Windows features
# ---------------------------
Write-Info "Installing/ensuring Windows features: Containers and Hyper-V..."
Try {
  $c = Get-WindowsFeature -Name Containers -ErrorAction Stop
  if (-not $c.Installed) { Install-WindowsFeature Containers -ErrorAction Stop | Out-Null; Write-Info "Containers installed." } else { Write-Info "Containers already installed." }
} Catch { Write-Warn "Could not ensure Containers feature: $_" }

Try {
  $hv = Get-WindowsFeature -Name Hyper-V -ErrorAction Stop
  if (-not $hv.Installed) {
    Install-WindowsFeature Hyper-V -ErrorAction Stop | Out-Null
    Write-Info "Hyper-V installed."
    $needRestart = $true
  } else { Write-Info "Hyper-V already installed." }
} Catch { Write-Warn "Could not ensure Hyper-V feature: $_" }

# ---------------------------
# 2) Windows Docker Engine (Microsoft script)
# ---------------------------
Write-Info "Installing Docker Engine (Microsoft script)..."
$script = "$env:TEMP\install-docker-ce.ps1"
Try {
  Invoke-WebRequest -UseBasicParsing `
    "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" `
    -OutFile $script -ErrorAction Stop
  & $script
  Write-Info "Docker Engine install script executed."
} Catch {
  Write-Err "Failed to download or run Docker install script: $_"
}

# ---------------------------
# 3) Docker Compose (CLI plugin)
# ---------------------------
$cliPath = "C:\Program Files\Docker\cli-plugins"
if (-not (Test-Path $cliPath)) { New-Item -ItemType Directory -Path $cliPath -Force | Out-Null }
$composeUrl  = "https://github.com/docker/compose/releases/latest/download/docker-compose-windows-x86_64.exe"
$composePath = Join-Path $cliPath "docker-compose.exe"
Try {
  Write-Info "Downloading Docker Compose -> $composePath"
  Invoke-WebRequest -Uri $composeUrl -OutFile $composePath -UseBasicParsing -ErrorAction Stop
} Catch { Write-Warn "Failed to download Compose: $_" }

# ---------------------------
# 4) Install WSL2 + Ubuntu (attempt)
# ---------------------------
# Modern Server supports `wsl --install`. We'll try it; if not present, enable WSL feature and VirtualMachinePlatform.
$wslAvailable = $false
Try {
  $wslVersion = (& wsl --version) 2>$null
  $wslAvailable = $true
} Catch { $wslAvailable = $false }

if ($wslAvailable) {
  Write-Info "WSL is available. Attempting quick 'wsl --install -d Ubuntu' (may require interactive first-run)."
  Try {
    wsl --install -d Ubuntu
    Write-Info "Called 'wsl --install -d Ubuntu'. If this is the first WSL install, a reboot may be required or you may need to complete first-run user setup by opening 'wsl -d Ubuntu' once."
    $needRestart = $true
  } Catch {
    Write-Warn "wsl --install failed or requires manual steps: $_"
  }
} else {
  Write-Info "WSL not present. Enabling WSL and VirtualMachinePlatform features..."
  Try {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction Stop | Out-Null
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop | Out-Null
    Write-Info "WSL features enabled. Run 'wsl --install -d Ubuntu' after reboot to install a distro."
    $needRestart = $true
  } Catch {
    Write-Warn "Could not enable WSL features: $_"
  }
}

# ---------------------------
# 5) Restart/Start Docker Service
# ---------------------------
Try {
  $svc = Get-Service -Name docker -ErrorAction Stop
  Restart-Service docker -Force -ErrorAction Stop
  Write-Info "Docker service restarted."
} Catch {
  Write-Warn "Docker service not found or could not restart now: $_"
  Start-Sleep -Seconds 5
  Try { Start-Service docker -ErrorAction Stop; Write-Info "Started Docker service." } Catch { Write-Warn "Could not start Docker service: $_" }
}

# ---------------------------
# 6) Attempt to install Docker inside WSL (best-effort)
# ---------------------------
# Note: Installing Docker inside WSL may require the WSL distro to have completed its first-run (interactive user creation).
# We'll check if Ubuntu is present and try non-interactively. If not ready, print manual steps.
Try {
  $distros = wsl -l -v 2>$null | Out-String
  if ($distros -match "Ubuntu") {
    Write-Info "Ubuntu distro detected in WSL. Attempting to install docker.io inside WSL (may require that you already ran Ubuntu once to create the user)."
    # Run apt update and install docker.io inside WSL (attempt). Use -- to pass full command.
    Try {
      wsl -d Ubuntu -- sudo apt-get update -y
      wsl -d Ubuntu -- sudo apt-get install -y docker.io
      # Try to start docker inside WSL. systemd may or may not be available; attempt service start as fallback.
      wsl -d Ubuntu -- sudo service docker start 2>$null
      Write-Info "Attempted to install/start Docker inside WSL Ubuntu. If service did not start, open 'wsl -d Ubuntu' and run 'sudo service docker start' or enable systemd in WSL."
      $wslDockerOk = $true
    } Catch {
      Write-Warn "Automatic Docker install inside WSL failed or requires interactive setup: $_"
      $wslDockerOk = $false
    }
  } else {
    Write-Warn "Ubuntu distro not found in WSL. Run 'wsl --install -d Ubuntu' or open the Microsoft Store to install Ubuntu after reboot."
    $wslDockerOk = $false
  }
} Catch {
  Write-Warn "wsl command not available or failed: $_"
  $wslDockerOk = $false
}

# ---------------------------
# 7) Create a simple Windows wrapper to run WSL Docker from Windows
# ---------------------------
$wrapperPath = "C:\Windows\docker-wsl.cmd"
Try {
  $wrapperContent = '@echo off' + "`n" + 'wsl -d Ubuntu -- docker %*'
  Set-Content -Path $wrapperPath -Value $wrapperContent -Encoding ASCII -Force
  Write-Info "Created wrapper: $wrapperPath (use 'docker-wsl' to run Docker in WSL)."
} Catch {
  Write-Warn "Could not create docker wrapper: $_"
}

# ---------------------------
# 8) Verification (Windows Docker + Compose)
# ---------------------------
Write-Info "`n== Docker (Windows) version =="
Try { docker version } Catch { Write-Warn "docker version failed: $_" }

Write-Info "`n== Docker Compose (Windows) version =="
Try { docker compose version } Catch { Write-Warn "docker compose version failed: $_" }

Write-Info "`n== Docker OSType (Windows daemon) =="
Try {
  $osType = docker info --format '{{.OSType}}' 2>$null
  if ($osType) { Write-Info "Windows Docker OSType: $osType" } else { Write-Warn "Could not determine Windows Docker OSType." }
} Catch { Write-Warn "docker info failed: $_" }

# Optional test for WSL Docker
if ($wslDockerOk) {
  Write-Info "`n== Test WSL Docker (alpine uname) =="
  Try { wsl -d Ubuntu -- docker run --rm alpine uname -a } Catch { Write-Warn "WSL Docker test failed: $_" }
} else {
  Write-Warn "`nWSL Docker not fully configured. If you installed Ubuntu via WSL, open 'wsl -d Ubuntu' once to complete first-run (create user), then run:"
  Write-Host "  sudo apt-get update && sudo apt-get install -y docker.io"
  Write-Host "  sudo service docker start"
  Write-Host "Then from Windows you can use: docker-wsl run --rm alpine uname -a"
}

# ---------------------------
# 9) Final note / reboot prompt
# ---------------------------
if ($needRestart) {
  Write-Host "`n> Hyper-V/WSL features were installed or changed. A reboot is strongly recommended."
  Write-Host "Run: Restart-Computer -Force"
} else {
  Write-Host "`n> No forced reboot required by the script. If something fails, reboot and re-run verification steps."
}

Write-Info "Script finished."
