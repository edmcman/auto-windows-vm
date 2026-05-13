# Wait for analysis agent (port 8000) to be listening inside guest
param(
    [int]$Port = 8000,
    [int]$TimeoutSeconds = 600,
    [int]$IntervalSeconds = 5
)

Write-Host "Waiting for agent to be listening on port $Port (timeout ${TimeoutSeconds}s)" -ForegroundColor Cyan
$start = Get-Date
while (((Get-Date) - $start).TotalSeconds -lt $TimeoutSeconds) {
    try {
        $isListening = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
        if ($isListening) {
            Write-Host "Agent is listening on port $Port" -ForegroundColor Green
            exit 0
        }
    } catch {
        # Fallback: try Test-NetConnection (works for older Windows)
        try {
            $result = Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -WarningAction SilentlyContinue
            if ($result.TcpTestSucceeded) {
                Write-Host "Agent is listening on port $Port" -ForegroundColor Green
                exit 0
            }
        } catch { }
    }
    Start-Sleep -Seconds $IntervalSeconds
}

Write-Host "Timeout waiting for agent after ${TimeoutSeconds}s" -ForegroundColor Yellow
exit 1