#!/bin/bash
# File: daily_linux_check.sh
LOGFILE="/var/log/daily_checks.log"

# System uptime
echo "Uptime:" >> $LOGFILE
uptime >> $LOGFILE

# Disk usage
echo "Disk Usage:" >> $LOGFILE
df -h >> $LOGFILE

# Memory usage
echo "Memory Usage:" >> $LOGFILE
free -h >> $LOGFILE

# CPU load
echo "CPU Load:" >> $LOGFILE
top -b -n 1 | head -n 10 >> $LOGFILE

# Check for failed systemd services
echo "Failed Services:" >> $LOGFILE
systemctl --failed >> $LOGFILE

# Check for root logins
echo "Root Login Attempts:" >> $LOGFILE
grep "session opened for user root" /var/log/auth.log >> $LOGFILE

# Check for package updates
echo "Package Updates:" >> $LOGFILE
apt list --upgradable >> $LOGFILE

# Notify upon completion
echo "Daily check completed on $(date)" >> $LOGFILE
