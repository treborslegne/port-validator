# Port Validation Script
# Flags any port whose actual state does not match its expected state
# Output: violations only, plus final issue count

$IpsFile        = "ips.txt"
$OpenPortsFile  = "ports_open.txt"
$ClosedPortsFile = "ports_closed.txt"
$Issues = 0

$ips         = Get-Content $IpsFile         | Where-Object { $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' }
$openPorts   = Get-Content $OpenPortsFile   | Where-Object { $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' }
$closedPorts = Get-Content $ClosedPortsFile | Where-Object { $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' }

foreach ($ip in $ips) {

    # Ports that should be open — flag if NOT responding
    foreach ($port in $openPorts) {
        $result = Test-NetConnection -ComputerName $ip -Port $port -WarningAction SilentlyContinue
        if (-not $result.TcpTestSucceeded) {
            Write-Host "VIOLATION: $ip  port $port  expected OPEN — not responding"
            $Issues++
        }
    }

    # Ports that should be closed — flag if IS responding
    foreach ($port in $closedPorts) {
        $result = Test-NetConnection -ComputerName $ip -Port $port -WarningAction SilentlyContinue
        if ($result.TcpTestSucceeded) {
            Write-Host "VIOLATION: $ip  port $port  expected CLOSED — is responding"
            $Issues++
        }
    }
}

Write-Host ""
if ($Issues -eq 0) {
    Write-Host "All ports validated — no issues found."
} else {
    Write-Host "Validation complete — $Issues violation(s) found."
}
