<#
.SYNOPSIS
  Verifica que un deployment OCI funcione: HTTP + SSH + cloud-init
.DESCRIPTION
  Prueba conectividad HTTP (puerto 80), SSH, y revisa el log de cloud-init.
  Espera hasta que cloud-init termine (máximo 5 minutos).
.PARAMETER IPs
  Lista de IPs públicas a verificar
.PARAMETER MaxWaitSeconds
  Tiempo máximo de espera para cloud-init (default: 300)
.EXAMPLE
  .\verificar-deploy.ps1 -IPs "150.136.230.199","158.101.126.29"
#>
param(
    [Parameter(Mandatory=$true)]
    [string[]]$IPs,

    [int]$MaxWaitSeconds = 300,
    [string]$User = "opc",
    [string]$KeyPath = "$env:USERPROFILE\.ssh\oci_webserver"
)

$GitSSH = "C:\Program Files\Git\usr\bin\ssh.exe"

function Test-HTTP {
    param([string]$IP, [int]$TimeoutSec = 10)
    try {
        $response = Invoke-WebRequest -Uri "http://$IP" -TimeoutSec $TimeoutSec -UseBasicParsing -ErrorAction Stop
        return @{ Success = $true; StatusCode = $response.StatusCode; Content = $response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)) }
    } catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

function Test-SSH {
    param([string]$IP, [string]$Cmd)
    $outFile = "$env:TEMP\ssh_verify_$($IP.Replace('.','_')).txt"
    $errFile = "$env:TEMP\ssh_verify_err_$($IP.Replace('.','_')).txt"

    $proc = Start-Process -FilePath $GitSSH -ArgumentList @(
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=/dev/null",
        "-o", "ConnectTimeout=10",
        "-o", "LogLevel=ERROR",
        "-i", $KeyPath,
        "$User@$IP",
        $Cmd
    ) -NoNewWindow -Wait -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile

    $output = if (Test-Path $outFile) { Get-Content $outFile -Raw } else { "" }
    $errors = if (Test-Path $errFile) { Get-Content $errFile -Raw } else { "" }
    return @{ ExitCode = $proc.ExitCode; Output = $output; Errors = $errors }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  VERIFICACION POST-DEPLOY OCI" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$allPassed = $true

foreach ($ip in $IPs) {
    Write-Host "--- Verificando: $ip ---" -ForegroundColor Yellow

    # 1. Test SSH connectivity
    Write-Host "  [1/4] SSH..." -NoNewline
    $sshResult = Test-SSH -IP $ip -Cmd "echo SSH_OK"
    if ($sshResult.ExitCode -eq 0 -and $sshResult.Output -match "SSH_OK") {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " FALLO (exit: $($sshResult.ExitCode))" -ForegroundColor Red
        $allPassed = $false
        continue
    }

    # 2. Wait for cloud-init to finish
    Write-Host "  [2/4] Cloud-init..." -NoNewline
    $waited = 0
    $ciDone = $false
    while ($waited -lt $MaxWaitSeconds) {
        $ciResult = Test-SSH -IP $ip -Cmd "cloud-init status 2>/dev/null || echo 'status: done'"
        if ($ciResult.Output -match "status: done" -or $ciResult.Output -match "status: error") {
            $ciDone = $true
            break
        }
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 15
        $waited += 15
    }
    if ($ciDone) {
        if ($ciResult.Output -match "status: error") {
            Write-Host " COMPLETO (con errores)" -ForegroundColor Yellow
        } else {
            Write-Host " COMPLETO" -ForegroundColor Green
        }
    } else {
        Write-Host " TIMEOUT ($MaxWaitSeconds`s)" -ForegroundColor Red
    }

    # 3. Test HTTP
    Write-Host "  [3/4] HTTP puerto 80..." -NoNewline
    $httpResult = Test-HTTP -IP $ip
    if ($httpResult.Success) {
        Write-Host " OK (Status: $($httpResult.StatusCode))" -ForegroundColor Green
    } else {
        Write-Host " FALLO ($($httpResult.Error))" -ForegroundColor Red
        $allPassed = $false
    }

    # 4. Check userdata log
    Write-Host "  [4/4] Log cloud-init..." -NoNewline
    $logResult = Test-SSH -IP $ip -Cmd "tail -5 /var/log/userdata.log 2>/dev/null"
    if ($logResult.ExitCode -eq 0) {
        Write-Host "" -ForegroundColor Green
        $logResult.Output -split "`n" | ForEach-Object { Write-Host "        $_" -ForegroundColor Gray }
    } else {
        Write-Host " No disponible" -ForegroundColor Yellow
    }

    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "  RESULTADO: TODOS LOS TESTS PASARON" -ForegroundColor Green
} else {
    Write-Host "  RESULTADO: ALGUNOS TESTS FALLARON" -ForegroundColor Red
}
Write-Host "========================================`n" -ForegroundColor Cyan
