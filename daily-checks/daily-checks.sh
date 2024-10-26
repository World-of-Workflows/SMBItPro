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
