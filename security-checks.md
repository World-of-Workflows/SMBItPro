### Detailed Report on Automated Security Monitoring Scripts for Linux, Windows, Azure, and Office 365

This document provides a comprehensive overview of scripts designed to monitor security issues and check for potential breaches on Linux and Windows servers, as well as in Azure and Office 365 environments. These scripts collect data on failed login attempts, security updates, suspicious sign-ins, and system audits and send consolidated reports to the designated helpdesk email, `helpdesk@mymsp.com.au`.

---

## **Script Overview**

### 1. **Linux Server Security Check Script**

**Purpose**: This script checks for essential security updates, reviews system logs for suspicious activity (like failed login attempts), and performs a rootkit scan to detect potential compromises on the Linux server.

**Script Details**:
- **Security Updates Check**: Uses `apt` to list available security updates.
- **Failed Login Attempts**: Scans `auth.log` and `secure` logs for evidence of failed login attempts, a common indicator of brute-force attacks.
- **Rootkit Detection**: Uses `chkrootkit`, a rootkit scanning tool, to check for signs of tampering in core system files.

```bash
#!/bin/bash

# Define recipient email and output file
RECIPIENT="helpdesk@mymsp.com.au"
OUTPUT="/tmp/linux_security_report.txt"

# Run security checks and log results
{
    echo "Linux Security Report"
    echo "Date: $(date)"
    echo ""

    # Check for security updates
    echo "Checking for security updates..."
    sudo apt update && apt list --upgradable | grep -i security
    echo ""

    # Log Analysis: Failed login attempts
    echo "Checking for failed login attempts..."
    sudo grep "authentication failure" /var/log/auth.log
    sudo grep "Failed password" /var/log/secure
    echo ""

    # Rootkit Detection
    echo "Running rootkit check..."
    if command -v chkrootkit &> /dev/null; then
        sudo chkrootkit
    else
        echo "chkrootkit not installed. Please install with 'sudo apt install chkrootkit'"
    fi
} > "$OUTPUT"

# Send email with results
mail -s "Linux Security Report" "$RECIPIENT" < "$OUTPUT"

# Cleanup
rm "$OUTPUT"
```

### **Running the Script on Linux**
- **Pre-Requisites**: Ensure `mailutils` and `chkrootkit` are installed.
  ```bash
  sudo apt install mailutils chkrootkit -y
  ```
- **Execution**: Make the script executable and run it manually or via cron:
  ```bash
  chmod +x linux_security_check.sh
  ./linux_security_check.sh
  ```
- **Automate with Cron**: Add to `cron` for regular execution:
  ```bash
  crontab -e
  # Add the following to run daily at midnight
  0 0 * * * /path/to/linux_security_check.sh
  ```

---

### 2. **Windows Server Security Check Script**

**Purpose**: This PowerShell script checks for uninstalled security updates, reviews recent security logs for failed login attempts, and audits critical administrative actions.

**Script Details**:
- **Security Updates Check**: Lists downloaded security updates.
- **Failed Login Attempts**: Extracts failed login attempts from the Security event log.
- **Admin Actions Audit**: Scans for modifications to sensitive files and actions by administrators, highlighting potential insider threats.

```powershell
# Define recipient email, SMTP server, and sender email
$recipient = "helpdesk@mymsp.com.au"
$sender = "server@mymsp.com.au"
$smtpServer = "smtp.mymsp.com"

# Collect results
$output = @()

# Check for Important Updates
$output += "Windows Security Report"
$output += "Date: $(Get-Date)"
$output += "`nChecking for security updates..."
$output += (Get-WindowsUpdate -MicrosoftUpdate | Where-Object { $_.IsDownloaded -eq $true } | Format-Table -Property Title, IsDownloaded | Out-String)

# Log Analysis: Failed login attempts
$output += "`nChecking for failed login attempts..."
$output += (Get-EventLog -LogName Security -InstanceId 4625 -Newest 50 | Format-Table -Property TimeGenerated, EntryType, Message | Out-String)

# Log Analysis: Audit Admin Actions
$output += "`nChecking for critical admin actions..."
$output += (Get-EventLog -LogName Security -InstanceId 4663 -Newest 50 | Format-Table -Property TimeGenerated, EntryType, Message | Out-String)

# Send email
Send-MailMessage -To $recipient -From $sender -Subject "Windows Security Report" -Body ($output -join "`n") -SmtpServer $smtpServer
```

### **Running the Script on Windows**
- **Pre-Requisites**: Ensure PowerShell is configured for remote and email operations, and have SMTP server details ready.
- **Execution**: Run manually in PowerShell or automate with Task Scheduler:
  ```powershell
  powershell -File "C:\path\to\windows_security_check.ps1"
  ```

---

### 3. **Azure and Office 365 Security Check Script**

**Purpose**: This PowerShell script queries Azure Security Center and Office 365 for potential security alerts, risky sign-ins, and logs unusual administrative actions.

**Script Details**:
- **Azure Security Center Alerts**: Retrieves active alerts from Azure Security Center.
- **Azure AD Risky Sign-ins**: Extracts risky login attempts from Azure AD.
- **Office 365 Suspicious Activity**: Collects suspicious sign-ins and changes to audit logs.

```powershell
# Define recipient email, SMTP server, and sender email
$recipient = "helpdesk@mymsp.com.au"
$sender = "azure@mymsp.com.au"
$smtpServer = "smtp.mymsp.com"

# Collect results
$output = @()

# Azure Security Center Alerts
$output += "Azure and Office 365 Security Report"
$output += "Date: $(Get-Date)"
$output += "`nChecking Azure Security Center alerts..."
$output += (az security alert list --query "[?status=='Active']" | ConvertTo-Json | Out-String)

# Azure AD Risky Sign-ins
$output += "`nChecking Azure AD for risky sign-ins..."
$output += (Get-AzureADAuditSignInLogs -Filter "riskLevel eq 'high'" | Format-Table -Property CreatedDateTime, UserPrincipalName, RiskLevel | Out-String)

# Office 365 Suspicious Logins
$output += "`nChecking Office 365 suspicious sign-ins..."
$output += (Get-ActivityAlert -AlertType SignInsFromUnknownSources | Format-Table -Property CreatedDate, Name, Status | Out-String)

# Office 365 Audit Logs
$output += "`nChecking Office 365 audit logs for unusual activities..."
$output += (Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date) -RecordType AzureActiveDirectory | Format-Table -Property CreationDate, Operation, UserId | Out-String)

# Send email
Send-MailMessage -To $recipient -From $sender -Subject "Azure and Office 365 Security Report" -Body ($output -join "`n") -SmtpServer $smtpServer
```

### **Running the Script for Azure/Office 365**
- **Pre-Requisites**: Ensure you have authenticated connections to Azure and Office 365 (you may need to log in with `Connect-AzAccount` and `Connect-ExchangeOnline`).
- **Execution**: Run manually or via an automation solution like **Azure Automation** or **Microsoft Flow** for cloud environments.

---

## **Additional Security Checks to Consider**

To enhance your security monitoring, you might consider adding the following checks:

1. **Intrusion Detection (IDS)**: Implement and monitor IDS tools like **OSSEC** or **Snort** on Linux servers.
2. **Network Activity Monitoring**: Use tools such as **Netstat** and **Wireshark** to monitor unexpected network connections, particularly for sensitive servers.
3. **Disk Space and Configuration Integrity**: Monitor unusual spikes in disk usage and scan for changes in critical files.
4. **Firewall Rules Review**: Regularly check firewall rules on both Linux and Windows servers to identify unexpected changes.
5. **Compliance Audits**: Use CIS (Centre for Internet Security) benchmarks to perform compliance checks on Linux, Windows, and cloud infrastructure.
6. **Phishing and Compromise Detection in Office 365**: Monitor inbox rules and permission changes for signs of compromised accounts.
7. **Automated Remediation**: Implement auto-remediation where possible, such as disabling users after repeated failed logins.

This consolidated monitoring setup, along with these additional checks, will provide a strong security baseline across your hybrid infrastructure, making it easier to identify, report, and mitigate potential threats.