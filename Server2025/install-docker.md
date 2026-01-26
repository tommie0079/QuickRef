# Docker on Windows Server 2025

Copy-paste and run the PowerShell block below **as Administrator**. It installs Containers, (optionally) Hyper-V, Docker Engine, Docker Compose v2 and runs basic checks. The script avoids forcing an immediate reboot — reboot if prompted.

```powershell
# Run as Administrator
# Prereqs: Windows Server 2025, admin. Optional: Hyper-V for Linux containers.

# Track if a reboot will be needed
$needRestart = $false

# 1) Windows features
if (-not (Get-WindowsFeature -Name Containers).Installed) {
  Install-WindowsFeature Containers
}
if (-not (Get-WindowsFeature -Name Hyper-V).Installed) {
  Install-WindowsFeature Hyper-V
  $needRestart = $true
}

# 2) Install Docker Engine (Microsoft install script)
$script = "$env:TEMP\install-docker-ce.ps1"
Invoke-WebRequest -UseBasicParsing `
  "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" `
  -OutFile $script
& $script

# 3) Install Docker Compose v2 (CLI plugin)
$cliPath = "C:\Program Files\Docker\cli-plugins"
if (-not (Test-Path $cliPath)) { New-Item -ItemType Directory -Path $cliPath -Force | Out-Null }
Invoke-WebRequest `
  -Uri "https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-windows-x86_64.exe" `
  -OutFile "$cliPath\docker-compose.exe"

# 4) Restart Docker service to pick up plugin (will fail if service not running yet)
Try { Restart-Service docker -ErrorAction Stop } Catch { Write-Host "Warning: could not restart Docker service (it may not be installed yet)." }

# 5) Verification
Write-Host "`n== Docker version =="
docker version

Write-Host "`n== Docker Compose version =="
docker compose version

Write-Host "`n== OSType (want 'linux' for Linux containers) =="
docker info --format '{{.OSType}}'

Write-Host "`n== Test run hello-world =="
docker run --rm hello-world

# 6) Final note about reboot
if ($needRestart) {
  Write-Host "`n> Hyper-V was installed and a reboot is required for it to take effect."
  Write-Host "Run: Restart-Computer -Force"
} else {
  Write-Host "`n> No reboot required. If something still fails, try rebooting and re-run the verification commands above."
}
