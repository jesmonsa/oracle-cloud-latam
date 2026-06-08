<#
.SYNOPSIS
  SSH a una instancia OCI usando Git's OpenSSH (evita problemas del SSH de Windows)
.DESCRIPTION
  Wrapper que usa Git's ssh.exe que funciona correctamente con claves PEM/RSA.
  Windows OpenSSH tiene bugs con ciertas claves que causan exit 255 sin output.
.PARAMETER IP
  IP pública de la instancia
.PARAMETER Command
  Comando remoto a ejecutar (opcional, si no se da abre shell interactivo)
.PARAMETER User
  Usuario SSH (default: opc)
.PARAMETER KeyPath
  Ruta a la clave privada (default: ~/.ssh/oci_webserver)
.EXAMPLE
  .\ssh-instance.ps1 -IP 150.136.230.199
  .\ssh-instance.ps1 -IP 150.136.230.199 -Command "sudo systemctl status httpd"
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$IP,

    [string]$Command = "",
    [string]$User = "opc",
    [string]$KeyPath = "$env:USERPROFILE\.ssh\oci_webserver"
)

# Usar Git's SSH (más confiable que Windows OpenSSH)
$GitSSH = "C:\Program Files\Git\usr\bin\ssh.exe"
if (-not (Test-Path $GitSSH)) {
    Write-Error "Git SSH no encontrado en $GitSSH. Instala Git for Windows."
    exit 1
}

if (-not (Test-Path $KeyPath)) {
    Write-Error "Clave SSH no encontrada en $KeyPath"
    exit 1
}

$sshArgs = @(
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
    "-o", "ConnectTimeout=10",
    "-o", "LogLevel=ERROR",
    "-i", $KeyPath,
    "$User@$IP"
)

if ($Command) {
    $sshArgs += $Command
}

Write-Host "Conectando a $User@$IP..." -ForegroundColor Cyan
& $GitSSH @sshArgs
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Host "SSH exit code: $exitCode" -ForegroundColor Red
}
exit $exitCode
