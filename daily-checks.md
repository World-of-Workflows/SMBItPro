## **Daily Server Health Checks: Implementation and Interpretation Guide**

### **Introduction**

Daily server health checks are routine assessments of server performance, resource usage, and potential security concerns. Regular monitoring enables early detection of issues, reducing downtime and improving service reliability. This report covers:
1. The implementation of daily health checks for both Linux and Windows servers.
2. Methods to interpret the results of each check.

---

### **1. Implementing Daily Checks**

#### **1.1 Linux Daily Check Script**

The Linux daily check script performs several vital checks, outputting results to a log file for later review. The script can be scheduled to run automatically using the cron job system.

**Linux Check Script Overview:**

```bash
#!/bin/bash
LOGFILE="/var/log/daily_checks.log"

# Collecting system metrics
echo "Uptime:" >> $LOGFILE
uptime >> $LOGFILE

echo "Disk Usage:" >> $LOGFILE
df -h >> $LOGFILE

echo "Memory Usage:" >> $LOGFILE
free -h >> $LOGFILE

echo "CPU Load:" >> $LOGFILE
top -b -n 1 | head -n 10 >> $LOGFILE

echo "Failed Services:" >> $LOGFILE
systemctl --failed >> $LOGFILE

echo "Root Login Attempts:" >> $LOGFILE
grep "session opened for user root" /var/log/auth.log >> $LOGFILE

echo "Package Updates:" >> $LOGFILE
apt list --upgradable >> $LOGFILE

echo "Daily check completed on $(date)" >> $LOGFILE
```

The script covers:
- **System uptime**: Measures server stability.
- **Disk and memory usage**: Alerts to resource limitations.
- **CPU load**: Monitors for high resource demands.
- **Failed services**: Identifies critical service issues.
- **Root logins**: Detects unauthorized access.
- **Package updates**: Lists available updates for maintenance.

To automate, add this script to `crontab` for daily execution.

#### **1.2 Windows Daily Check Script**

The PowerShell script gathers system information and logs it into a file. Scheduled tasks are configured to run this script automatically.

**Windows Check Script Overview:**

```powershell
$LogFile = "C:\Logs\daily_checks.txt"

Add-Content -Path $LogFile -Value "Uptime:"
Get-Uptime | Out-File -Append -FilePath $LogFile

Add-Content -Path $LogFile -Value "Disk Usage:"
Get-PSDrive -PSProvider FileSystem | Format-Table Used, Free | Out-File -Append -FilePath $LogFile

Add-Content -Path $LogFile -Value "Memory Usage:"
Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory | Format-Table | Out-File -Append -FilePath $LogFile

Add-Content -Path $LogFile -Value "CPU Load:"
Get-Counter '\Processor(_Total)\% Processor Time' | Out-File -Append -FilePath $LogFile

Add-Content -Path $LogFile -Value "Failed Services:"
Get-Service | Where-Object {$_.Status -eq 'Stopped'} | Out-File -Append -FilePath $LogFile

Add-Content -Path $LogFile -Value "Critical Event Logs:"
Get-EventLog -LogName System -EntryType Error -Newest 10 | Out-File -Append -FilePath $LogFile

Add-Content -Path $LogFile -Value "Daily check completed on $(Get-Date)"
```

The script covers similar checks, focusing on Windows-specific tasks.

### **2. Interpreting Daily Check Results**

#### **2.1 Uptime**
   - **Purpose**: Indicates server stability and availability.
   - **Interpretation**: Short uptime can signal recent reboots, planned or unplanned. Frequent reboots may indicate underlying issues requiring deeper investigation.

#### **2.2 Disk Usage**
   - **Purpose**: Ensures that storage does not reach critical levels.
   - **Interpretation**: Disk usage above 80-90% warrants attention to avoid performance issues. Regularly high usage could require disk cleanup, archiving, or additional storage.

#### **2.3 Memory Usage**
   - **Purpose**: Monitors system memory usage.
   - **Interpretation**: Consistently high memory usage can lead to performance degradation. High memory consumption may signal memory leaks, inefficient software, or the need for upgrades.

#### **2.4 CPU Load**
   - **Purpose**: Identifies if CPU resources are under strain.
   - **Interpretation**: High CPU usage (above 70-80%) could suggest resource-heavy processes or potential malware. Investigate top-consuming processes when usage is consistently high.

#### **2.5 Failed Services**
   - **Purpose**: Ensures that critical services are operational.
   - **Interpretation**: Any failed essential services should be restarted or resolved immediately. Investigate logs to determine if failure was expected or indicative of a larger problem.

#### **2.6 Root Login Attempts (Linux)**
   - **Purpose**: Detects possible unauthorised access attempts.
   - **Interpretation**: Root login entries in logs outside scheduled administrative tasks may indicate a security breach. Enforcing strong password policies or two-factor authentication can mitigate risks.

#### **2.7 Package and Security Updates (Linux)**
   - **Purpose**: Lists available software and security updates.
   - **Interpretation**: Regular updates improve security and stability. Apply updates during maintenance windows to minimise disruptions.

#### **2.8 Critical Event Logs (Windows)**
   - **Purpose**: Highlights recent errors or warnings from the system.
   - **Interpretation**: Reviewing recent critical logs allows for troubleshooting issues that may impact server reliability.

---

### **3. Summary and Best Practices**

Daily server health checks are foundational for MSPs to ensure system reliability and security. When implementing and reviewing these checks, it is essential to:

1. **Automate** the execution of scripts through cron jobs (Linux) and Task Scheduler (Windows).
2. **Centralise log storage** on each server and consider aggregating logs to a central system for easy access and historical analysis.
3. **Regularly review** check logs and set thresholds to alert teams to critical issues needing immediate attention.
4. **Document findings and responses** to issues for ongoing system and process improvement.

---

### **Conclusion**

The implementation and routine review of daily server health checks allow MSPs to maintain high levels of service reliability and security for their clients. Regular monitoring ensures that minor issues are addressed before they escalate, ultimately enhancing service quality and customer satisfaction. 

This guide should serve as a comprehensive reference for implementing, reviewing, and troubleshooting server health across Linux and Windows environments, aligning with best practices in server management.