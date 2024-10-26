# Variables
$To = "helpdesk@mynewmsp.com"
$From = "serverreports@$(hostname)"
$Subject = "Daily Server Report - $(hostname) - $(Get-Date -Format 'yyyy-MM-dd')"
$SMTPServer = "smtp.mynewmsp.com"
$Body = ""

# Disk Usage
$Body += "Disk Usage:`n"
$DiskInfo = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}}, @{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}}
$Body += $DiskInfo | Format-Table | Out-String
$Body += "`n"

# CPU and Memory Usage
$Body += "CPU and Memory Usage:`n"
$CpuLoad = Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average
$Memory = Get-WmiObject win32_operatingsystem | Select @{Name="FreePhysicalMemory(MB)";Expression={[math]::Round($_.FreePhysicalMemory/1024,2)}}, @{Name="TotalVisibleMemorySize(MB)";Expression={[math]::Round($_.TotalVisibleMemorySize/1024,2)}}
$Body += "CPU Load Average: $($CpuLoad.Average)%`n"
$Body += "Memory Usage:`n"
$Body += $Memory | Format-List | Out-String
$Body += "`n"

# Service Status
$Body += "Stopped Services:`n"
$StoppedServices = Get-Service | Where-Object {$_.Status -eq 'Stopped' -and $_.StartType -eq 'Automatic'}
$Body += $StoppedServices | Format-Table | Out-String
$Body += "`n"

# System Logs Errors
$Body += "System Log Errors:`n"
$SystemErrors = Get-EventLog -LogName System -EntryType Error -Newest 10
$Body += $SystemErrors | Format-Table -AutoSize | Out-String
$Body += "`n"

# Security Events
$Body += "Security Events:`n"
$SecurityEvents = Get-EventLog -LogName Security -InstanceId 4625 -Newest 10
$Body += $SecurityEvents | Format-Table -AutoSize | Out-String
$Body += "`n"

# Backup Status
$Body += "Backup Status:`n"
if (Test-Path "C:\Logs\Backup.log") {
    $BackupLog = Get-Content "C:\Logs\Backup.log" -Tail 20
    $Body += $BackupLog
} else {
    $Body += "Backup log not found."
}
$Body += "`n"

# Send the email
Send-MailMessage -To $To -From $From -Subject $Subject -Body $Body -SmtpServer $SMTPServer
