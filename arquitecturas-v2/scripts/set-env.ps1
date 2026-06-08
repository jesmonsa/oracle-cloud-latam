# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Cargar variables de entorno para Terraform Remote State en OCI             ║
# ║  Uso: . .\scripts\set-env.ps1  (nótese el punto al inicio para dot-source) ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$S3Creds = Join-Path $RootDir "00-bootstrap-remotestate\s3_credentials"

if (Test-Path $S3Creds) {
    $content = Get-Content $S3Creds -Raw
    if ($content -match 'aws_access_key_id\s*=\s*(.+)') {
        $env:AWS_ACCESS_KEY_ID = $Matches[1].Trim()
    }
    if ($content -match 'aws_secret_access_key\s*=\s*(.+)') {
        $env:AWS_SECRET_ACCESS_KEY = $Matches[1].Trim()
    }
    # Requerido para OCI Object Storage S3 Compatibility con Terraform >= 1.6
    # Sin esto: "AWS chunked encoding not supported" (error 501)
    $env:AWS_REQUEST_CHECKSUM_CALCULATION = "WHEN_REQUIRED"
    $env:AWS_RESPONSE_CHECKSUM_VALIDATION = "WHEN_REQUIRED"

    Write-Host "✅ Variables de entorno configuradas para Terraform Remote State" -ForegroundColor Green
} else {
    Write-Host "⚠️  No se encontró: $S3Creds" -ForegroundColor Yellow
    Write-Host "   Ejecuta primero: cd 00-bootstrap-remotestate && terraform apply" -ForegroundColor Cyan
}
