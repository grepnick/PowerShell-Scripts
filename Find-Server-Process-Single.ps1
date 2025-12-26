Get-NetTCPConnection -LocalPort 443 |
    ForEach-Object {
        $p = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            LocalAddress = $_.LocalAddress
            LocalPort    = $_.LocalPort
            State        = $_.State
            PID          = $_.OwningProcess
            ProcessName  = $p.ProcessName
            Path         = $p.Path
        }
    }
