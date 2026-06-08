# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Script: Destruir una arquitectura completa                                 ║
# ║  Uso: .\scripts\destroy-arquitectura.ps1 -Arquitectura "01-fundamentos"    ║
# ║  Incluye confirmación para evitar eliminaciones accidentales.               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

param(
    [Parameter(Mandatory = $true)]
    [string]$Arquitectura,

    [switch]$AutoApprove
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$ArqDir = Join-Path $RootDir $Arquitectura
$BootstrapDir = Join-Path $RootDir "00-bootstrap-remotestate"
$S3Creds = Join-Path $BootstrapDir "s3_credentials"

if (-not (Test-Path $ArqDir)) {
    Write-Error "Arquitectura no encontrada: $ArqDir"
    exit 1
}

# ─── Cargar credenciales S3 ──────────────────────────────────────────────────
if (Test-Path $S3Creds) {
    $content = Get-Content $S3Creds -Raw
    if ($content -match 'aws_access_key_id\s*=\s*(.+)') {
        $env:AWS_ACCESS_KEY_ID = $Matches[1].Trim()
    }
    if ($content -match 'aws_secret_access_key\s*=\s*(.+)') {
        $env:AWS_SECRET_ACCESS_KEY = $Matches[1].Trim()
    }
    # Requerido para OCI S3 Compatibility con Terraform >= 1.6
    $env:AWS_REQUEST_CHECKSUM_CALCULATION = "WHEN_REQUIRED"
    $env:AWS_RESPONSE_CHECKSUM_VALIDATION = "WHEN_REQUIRED"
}

Set-Location $ArqDir

# ─── Mostrar plan de destrucción ─────────────────────────────────────────────
Write-Host "`n🔴 DESTRUIR ARQUITECTURA: $Arquitectura" -ForegroundColor Red
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

Write-Host "`nRevisando recursos a eliminar..." -ForegroundColor Yellow
& terraform plan -destroy -out=destroy.tfplan 2>&1 | Select-String "Plan:|will be destroyed"

if (-not $AutoApprove) {
    Write-Host "`n⚠️  Esta acción es IRREVERSIBLE." -ForegroundColor Red
    $confirm = Read-Host "Escriba 'DESTRUIR' para confirmar"
    if ($confirm -ne "DESTRUIR") {
        Write-Host "Cancelado." -ForegroundColor Yellow
        Remove-Item destroy.tfplan -ErrorAction SilentlyContinue
        exit 0
    }
}

# ─── Ejecutar destroy ────────────────────────────────────────────────────────
Write-Host "`n🗑️  Destruyendo recursos..." -ForegroundColor Yellow
if ($AutoApprove) {
    & terraform destroy -auto-approve
} else {
    & terraform apply destroy.tfplan
}

Remove-Item destroy.tfplan -ErrorAction SilentlyContinue

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Todos los recursos de $Arquitectura han sido eliminados." -ForegroundColor Green
    Write-Host "   No se generarán más costos por estos recursos." -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Hubo errores en la destrucción. Revisa manualmente en la consola de OCI." -ForegroundColor Red
}
