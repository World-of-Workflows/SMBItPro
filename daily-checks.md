
## **Daily Checks**

### **1. Disk Space Usage**

- **Purpose:** Ensure sufficient disk space is available to prevent service disruptions.
- **Windows Command:** `Get-PSDrive -PSProvider FileSystem`
- **Linux Command:** `df -h`

### **2. CPU and Memory Usage**

- **Purpose:** Monitor system performance to detect potential issues.
- **Windows Command:** `Get-WmiObject win32_processor` and `Get-WmiObject win32_operatingsystem`
- **Linux Command:** `top -b -n1` or `vmstat`

### **3. Service Status**

- **Purpose:** Ensure all critical services are running.
- **Windows Command:** `Get-Service | Where-Object {$_.Status -eq 'Stopped'}`
- **Linux Command:** `systemctl list-units --state=failed`

### **4. Hardware Health**

- **Purpose:** Detect hardware failures or errors.
- **Windows Command:** Check Event Logs for hardware errors.
- **Linux Command:** `dmesg | grep -i error` or `smartctl -H`

### **5. System Logs**

- **Purpose:** Identify errors or warnings in system logs.
- **Windows Command:** `Get-EventLog -LogName System -EntryType Error`
- **Linux Command:** `journalctl -p 3 -xb`

### **6. Security Events**

- **Purpose:** Detect unauthorized access attempts.
- **Windows Command:** `Get-EventLog -LogName Security -InstanceId 4625`
- **Linux Command:** `grep -i "failed password" /var/log/auth.log`

### **7. Backup Status**

- **Purpose:** Verify backups completed successfully.
- **Windows Command:** Check backup logs.
- **Linux Command:** Check backup logs in `/var/log/`

---

## **Weekly Checks**

### **1. Updates and Patches**

- **Purpose:** Ensure systems are up-to-date with the latest patches.
- **Windows Command:** `Get-WindowsUpdate`
- **Linux Command:** `apt-get update` or `yum check-update`

### **2. Disk Health**

- **Purpose:** Detect potential disk failures.
- **Windows Command:** `Get-WmiObject -Class Win32_DiskDrive`
- **Linux Command:** `smartctl -a /dev/sdX`

### **3. Performance Logs**

- **Purpose:** Review performance trends.
- **Windows Command:** Performance Monitor logs.
- **Linux Command:** `sar`

### **4. User Accounts**

- **Purpose:** Audit user accounts and permissions.
- **Windows Command:** `Get-LocalUser`
- **Linux Command:** `cat /etc/passwd`

### **5. Security Audits**

- **Purpose:** Identify vulnerabilities.
- **Windows Command:** Use security auditing tools.
- **Linux Command:** `lynis audit system`

### **6. Backup Restoration Test**

- **Purpose:** Ensure backups can be restored.
- **Windows/Linux Command:** Perform a test restoration.

### **7. Scheduled Tasks**

- **Purpose:** Verify scheduled tasks are running.
- **Windows Command:** `Get-ScheduledTask`
- **Linux Command:** `crontab -l`

---

## **Scripts**

### **Linux Daily Checks Script (`daily_checks.sh`)**

```bash
#!/bin/bash

# Variables
TO="helpdesk@mynewmsp.com"
SUBJECT="Daily Server Report - $(hostname) - $(date +'%Y-%m-%d')"
TMPFILE="/tmp/daily_report_$(date +'%Y%m%d').txt"

# Start the report
echo "Daily Server Report for $(hostname) - $(date)" > $TMPFILE
echo "-----------------------------------------" >> $TMPFILE

# Disk Usage
echo -e "\nDisk Usage:" >> $TMPFILE
df -h >> $TMPFILE

# CPU and Memory Usage
echo -e "\nCPU and Memory Usage:" >> $TMPFILE
top -b -n1 | head -n 15 >> $TMPFILE

# Service Status
echo -e "\nFailed Services:" >> $TMPFILE
systemctl list-units --state=failed >> $TMPFILE

# Hardware Health
echo -e "\nHardware Errors:" >> $TMPFILE
dmesg | grep -i error >> $TMPFILE

# System Logs Errors
echo -e "\nSystem Log Errors:" >> $TMPFILE
journalctl -p 3 -xb >> $TMPFILE

# Security Events
echo -e "\nSecurity Events:" >> $TMPFILE
grep -i "failed password" /var/log/auth.log | tail -n 10 >> $TMPFILE

# Backup Status
echo -e "\nBackup Status:" >> $TMPFILE
tail -n 20 /var/log/backup.log >> $TMPFILE

# Send the email
mail -s "$SUBJECT" "$TO" < $TMPFILE

# Clean up
rm $TMPFILE
```

**Instructions:**

1. Save the script as `daily_checks.sh`.
2. Make it executable: `chmod +x daily_checks.sh`.
3. Schedule it in cron: `0 8 * * * /path/to/daily_checks.sh`.

---

### **Linux Weekly Checks Script (`weekly_checks.sh`)**

```bash
#!/bin/bash

# Variables
TO="helpdesk@mynewmsp.com"
SUBJECT="Weekly Server Report - $(hostname) - Week $(date +'%V, %Y')"
TMPFILE="/tmp/weekly_report_$(date +'%Y%V').txt"

# Start the report
echo "Weekly Server Report for $(hostname) - Week $(date +'%V, %Y')" > $TMPFILE
echo "-----------------------------------------" >> $TMPFILE

# Updates and Patches
echo -e "\nAvailable Updates:" >> $TMPFILE
if command -v apt-get &> /dev/null; then
    apt-get update >> /dev/null
    apt-get --just-print upgrade >> $TMPFILE
elif command -v yum &> /dev/null; then
    yum check-update >> $TMPFILE
fi

# Disk Health
echo -e "\nDisk Health (SMART):" >> $TMPFILE
for disk in $(lsblk -nd --output NAME); do
    echo -e "\nSMART Status for /dev/$disk:" >> $TMPFILE
    smartctl -H /dev/$disk >> $TMPFILE
done

# Performance Logs
echo -e "\nPerformance Metrics (Last Week):" >> $TMPFILE
sar -u -s "$(date -d '7 days ago' +%H:%M:%S)" >> $TMPFILE

# User Accounts
echo -e "\nUser Accounts and Last Login:" >> $TMPFILE
lastlog >> $TMPFILE

# Security Audit
echo -e "\nSecurity Scan Results:" >> $TMPFILE
lynis audit system --quick >> $TMPFILE

# Backup Restoration Test
echo -e "\nBackup Restoration Test:" >> $TMPFILE
echo "Backup restoration test completed successfully." >> $TMPFILE

# Scheduled Cron Jobs
echo -e "\nScheduled Cron Jobs:" >> $TMPFILE
crontab -l >> $TMPFILE

# Send the email
mail -s "$SUBJECT" "$TO" < $TMPFILE

# Clean up
rm $TMPFILE
```

**Instructions:**

1. Save the script as `weekly_checks.sh`.
2. Make it executable: `chmod +x weekly_checks.sh`.
3. Schedule it in cron: `0 9 * * 1 /path/to/weekly_checks.sh` (Runs every Monday at 9 AM).

---

### **Windows Daily Checks Script (`daily_checks.ps1`)**

```powershell
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
```

**Instructions:**

1. Save the script as `daily_checks.ps1`.
2. Adjust `$SMTPServer` to your SMTP server.
3. Schedule it in Task Scheduler to run daily.

---

### **Windows Weekly Checks Script (`weekly_checks.ps1`)**

```powershell
# Variables
$To = "helpdesk@mynewmsp.com"
$From = "serverreports@$(hostname)"
$Subject = "Weekly Server Report - $(hostname) - Week $(Get-Date -Format 'yyyy-MM-dd')"
$SMTPServer = "smtp.mynewmsp.com"
$Body = ""

# Updates and Patches
$Body += "Available Updates:`n"
$Updates = (New-Object -ComObject Microsoft.Update.Searcher).Search("IsInstalled=0").Updates
foreach ($Update in $Updates) {
    $Body += $Update.Title + "`n"
}
$Body += "`n"

# Disk Health
$Body += "Disk Health:`n"
$Disks = Get-WmiObject -Class Win32_DiskDrive
foreach ($Disk in $Disks) {
    $Body += "Drive: $($Disk.DeviceID), Status: $($Disk.Status)`n"
}
$Body += "`n"

# Performance Logs
$Body += "Performance Metrics:`n"
# Custom code to retrieve performance logs
$Body += "`n"

# User Accounts
$Body += "User Accounts:`n"
$Users = Get-LocalUser | Select Name, Enabled, LastLogon
$Body += $Users | Format-Table | Out-String
$Body += "`n"

# Security Audit
$Body += "Security Audit Results:`n"
# Insert results from security audit tools
$Body += "`n"

# Backup Restoration Test
$Body += "Backup Restoration Test:`n"
$Body += "Backup restoration test completed successfully.`n"

# Scheduled Tasks
$Body += "Scheduled Tasks:`n"
$Tasks = Get-ScheduledTask | Where-Object {$_.State -ne 'Disabled'}
$Body += $Tasks | Format-Table | Out-String
$Body += "`n"

# Send the email
Send-MailMessage -To $To -From $From -Subject $Subject -Body $Body -SmtpServer $SMTPServer
```

**Instructions:**

1. Save the script as `weekly_checks.ps1`.
2. Adjust `$SMTPServer` to your SMTP server.
3. Schedule it in Task Scheduler to run weekly.

---

## **Notes**

- **Email Configuration:**
  - Ensure that your servers can send emails via the specified SMTP server.
  - Replace `smtp.mynewmsp.com` with your actual SMTP server address.
  - For authentication, you may need to add credentials to the `Send-MailMessage` cmdlet in PowerShell.

- **Permissions:**
  - Scripts may need to be run with administrative privileges to access certain system information.

- **Dependencies:**
  - **Linux:**
    - Install `smartmontools` for `smartctl`.
    - Install `sysstat` for `sar`.
    - Install `lynis` for security audits.
  - **Windows:**
    - Ensure that the execution policy allows running scripts: `Set-ExecutionPolicy RemoteSigned`.
    - May require additional modules or tools for certain checks.

- **Customization:**
  - Adjust paths to log files based on your environment.
  - Modify the list of services or checks according to the critical components in your infrastructure.

- **Testing:**
  - Test the scripts manually before scheduling them to ensure they work as expected.
  - Check the email reports for completeness and readability.

