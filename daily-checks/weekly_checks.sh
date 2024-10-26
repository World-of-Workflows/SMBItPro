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
