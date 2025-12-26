Get-NetTCPConnection -State Listen |
    ForEach-Object {
        $p = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            Port        = $_.LocalPort
            Address     = $_.LocalAddress
            PID         = $_.OwningProcess
            Process     = $p.ProcessName
            Executable  = $p.Path
        }
    } | Sort-Object Port
