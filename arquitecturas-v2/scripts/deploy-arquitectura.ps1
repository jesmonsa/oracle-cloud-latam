<#
.SYNOPSIS
  Deploy completo de una arquitectura: init + plan + apply
.DESCRIPTION
  Ejecuta terraform init, plan y apply para una arquitectura específica.
  Carga credenciales S3 y configura las variables de entorno necesarias.
.PARAMETER Arquitectura
  Nombre del directorio de la arquitectura (ej: "02-alta-disponibilidad-multi-ad")
.EXAMPLE
  .\deploy-arquitectura.ps1 -Arquitectura "02-alta-disponibilidad-multi-ad"
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Arquitectura
)

$ErrorActionPreference = "Stop"
$BaseDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ArqDir = Join-Path $BaseDir $Arquitectura
$BootstrapDir = Join-Path $BaseDir "00-bootstrap-remotestate"
$BackendHCL = Join-Path $BootstrapDir "backend.hcl"

if (-not (Test-Path $ArqDir)) {
    Write-Error "Arquitectura no encontrada: $ArqDir"
    exit 1
}

# Cargar credenciales S3
$env:AWS_REQUEST_CHECKSUM_CALCULATION = "WHEN_REQUIRED"
$env:AWS_RESPONSE_CHECKSUM_VALIDATION = "WHEN_REQUIRED"

$credsFile = Join-Path $BootstrapDir "s3_credentials"
if (Test-Path $credsFile) {
    Get-Content $credsFile | ForEach-Object {
        if ($_ -match "aws_access_key_id\s*=\s*(.+)") { $env:AWS_ACCESS_KEY_ID = $Matches[1].Trim() }
        if ($_ -match "aws_secret_access_key\s*=\s*(.+)") { $env:AWS_SECRET_ACCESS_KEY = $Matches[1].Trim() }
    }
    Write-Host "Credenciales S3 cargadas" -ForegroundColor Green
} else {
    Write-Error "No se encontró $credsFile. Ejecuta primero 00-bootstrap-remotestate."
    exit 1
}

Set-Location $ArqDir
Write-Host "`n=== Deploy: $Arquitectura ===" -ForegroundColor Cyan

# Init
Write-Host "`n[1/3] terraform init..." -ForegroundColor Yellow
terraform init -backend-config="$BackendHCL" -reconfigure
if ($LASTEXITCODE -ne 0) { Write-Error "Init falló"; exit 1 }

# Plan
Write-Host "`n[2/3] terraform plan..." -ForegroundColor Yellow
terraform plan -out=tfplan
if ($LASTEXITCODE -ne 0) { Write-Error "Plan falló"; exit 1 }

# Apply
Write-Host "`n[3/3] terraform apply..." -ForegroundColor Yellow
terraform apply tfplan
$applyExit = $LASTEXITCODE
Remove-Item tfplan -ErrorAction SilentlyContinue

if ($applyExit -ne 0) {
    Write-Error "Apply falló con exit code $applyExit"
    exit 1
}

Write-Host "`n=== Deploy completado exitosamente ===" -ForegroundColor Green
terraform output
