# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Script: Inicializar Terraform con Remote State                             ║
# ║  Uso: .\scripts\init-backend.ps1 -Arquitectura "01-fundamentos-webserver"  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

param(
    [Parameter(Mandatory = $true)]
    [string]$Arquitectura,

    [switch]$Migrate,
    [switch]$Reconfigure
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$BootstrapDir = Join-Path $RootDir "00-bootstrap-remotestate"
$ArqDir = Join-Path $RootDir $Arquitectura
$BackendConfig = Join-Path $BootstrapDir "backend.hcl"
$S3Creds = Join-Path $BootstrapDir "s3_credentials"

# ─── Validaciones ────────────────────────────────────────────────────────────
if (-not (Test-Path $ArqDir)) {
    Write-Error "Arquitectura no encontrada: $ArqDir"
    exit 1
}

if (-not (Test-Path $BackendConfig)) {
    Write-Host "`n⚠️  No se encontró backend.hcl. Ejecuta primero el bootstrap:" -ForegroundColor Yellow
    Write-Host "   cd $BootstrapDir" -ForegroundColor Cyan
    Write-Host "   terraform init && terraform apply" -ForegroundColor Cyan
    exit 1
}

# ─── Cargar credenciales S3 desde archivo ────────────────────────────────────
if (Test-Path $S3Creds) {
    $content = Get-Content $S3Creds -Raw
    if ($content -match 'aws_access_key_id\s*=\s*(.+)') {
        $env:AWS_ACCESS_KEY_ID = $Matches[1].Trim()
    }
    if ($content -match 'aws_secret_access_key\s*=\s*(.+)') {
        $env:AWS_SECRET_ACCESS_KEY = $Matches[1].Trim()
    }
    # Requerido para OCI Object Storage S3 Compatibility con Terraform >= 1.6
    # Evita "AWS chunked encoding not supported"
    $env:AWS_REQUEST_CHECKSUM_CALCULATION = "WHEN_REQUIRED"
    $env:AWS_RESPONSE_CHECKSUM_VALIDATION = "WHEN_REQUIRED"
    Write-Host "✅ Credenciales S3 y variables SDK cargadas" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  No se encontró s3_credentials." -ForegroundColor Yellow
    Write-Host "   Asegúrate de tener las variables de entorno:" -ForegroundColor Yellow
    Write-Host "   AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY" -ForegroundColor Cyan
    if (-not $env:AWS_ACCESS_KEY_ID -or -not $env:AWS_SECRET_ACCESS_KEY) {
        Write-Error "Faltan credenciales S3. Ejecuta el bootstrap o configura las variables de entorno."
        exit 1
    }
}

# ─── Ejecutar terraform init ─────────────────────────────────────────────────
Write-Host "`n🚀 Inicializando $Arquitectura con remote state..." -ForegroundColor Cyan
Set-Location $ArqDir

$initArgs = @("init", "-backend-config=$BackendConfig")
if ($Migrate) { $initArgs += "-migrate-state" }
if ($Reconfigure) { $initArgs += "-reconfigure" }

Write-Host "   terraform $($initArgs -join ' ')`n" -ForegroundColor DarkGray
& terraform @initArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Inicialización exitosa. State remoto en: v2/$Arquitectura/terraform.tfstate" -ForegroundColor Green
} else {
    Write-Host "`n❌ Error en la inicialización. Revisa los mensajes anteriores." -ForegroundColor Red
}
