# File: daily_windows_check.ps1
$LogFile = "C:\Logs\daily_checks.txt"

# System uptime
Add-Content -Path $LogFile -Value "Uptime:"
Get-Uptime | Out-File -Append -FilePath $LogFile

# Disk usage
Add-Content -Path $LogFile -Value "Disk Usage:"
Get-PSDrive -PSProvider FileSystem | Format-Table Used, Free, @{Name='UsedGB';Expression={[math]::round($_.Used / 1GB, 2)}}, @{Name='FreeGB';Expression={[math]::round($_.Free / 1GB, 2)}} | Out-File -Append -FilePath $LogFile

# Memory usage
Add-Content -Path $LogFile -Value "Memory Usage:"
Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory | Format-Table | Out-File -Append -FilePath $LogFile

# CPU load
Add-Content -Path $LogFile -Value "CPU Load:"
Get-Counter '\Processor(_Total)\% Processor Time' | Out-File -Append -FilePath $LogFile

# Failed services
Add-Content -Path $LogFile -Value "Failed Services:"
Get-Service | Where-Object {$_.Status -eq 'Stopped'} | Out-File -Append -FilePath $LogFile

# Check for critical event logs
Add-Content -Path $LogFile -Value "Critical Event Logs:"
Get-EventLog -LogName System -EntryType Error -Newest 10 | Out-File -Append -FilePath $LogFile

# Completion notification
Add-Content -Path $LogFile -Value "Daily check completed on $(Get-Date)"
