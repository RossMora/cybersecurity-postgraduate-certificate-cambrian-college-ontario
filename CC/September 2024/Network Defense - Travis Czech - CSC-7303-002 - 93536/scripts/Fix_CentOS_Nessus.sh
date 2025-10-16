#!/bin/bash
# Fix_CentOS_Nessus.sh – Address Nessus-reported vulnerabilities on CentOS
# Machine-specific check
if [[ "$(hostname)" != "localhost.localdomain" ]]; then
    echo "This script is intended for the CentOS VM only (hostname: localhost.localdomain). Exiting to prevent errors."
    exit 1
fi
echo "Starting Fix_CentOS_Nessus.sh on $(hostname)..."
# Function to handle errors
handle_error() {
    echo "Error encountered: $1"
    echo "Please review logs and manually address the issue."
}
# 1. Disable Netcat Backdoor Service
echo "Disabling Netcat backdoor service..."
if systemctl is-active --quiet malicious.service; then
    systemctl stop malicious.service || handle_error "Failed to stop malicious.service"
    systemctl disable malicious.service || handle_error "Failed to disable malicious.service"
    echo "Netcat backdoor service disabled."
else
    echo "No malicious Netcat service found."
fi
# 2. Correct File Permissions
echo "Correcting file permissions..."
chmod 644 /etc/passwd || handle_error "Failed to set permissions for /etc/passwd"
chmod 600 /etc/shadow || handle_error "Failed to set permissions for /etc/shadow"
echo "File permissions corrected."
# 3. Update Apache HTTP Server
echo "Updating Apache HTTP server..."
yum clean all && yum update -y httpd || handle_error "Failed to update Apache HTTP server"
echo "Apache HTTP server updated."
# 4. Update FFmpeg
echo "Updating FFmpeg..."
if rpm -q ffmpeg; then
    yum clean all && yum update -y ffmpeg || handle_error "Failed to update FFmpeg"
else
    echo "FFmpeg not installed. Skipping update."
fi
# 5. Remove Malicious Cron Jobs
echo "Removing malicious cron jobs..."
crontab -l | grep -v 'malicious_job_command' | crontab - || handle_error "Failed to remove malicious cron jobs"
echo "Malicious cron jobs removed."
# 6. Secure SSH Configuration
echo "Securing SSH configuration..."
if grep -q "^PermitRootLogin" /etc/ssh/sshd_config; then
    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config || handle_error "Failed to update SSH configuration"
else
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi
systemctl restart sshd || handle_error "Failed to restart SSH service"
echo "SSH configuration secured."
# 7. Upgrade Suricata
echo "Updating Suricata..."
if rpm -q suricata; then
    yum clean all && yum update -y suricata || handle_error "Failed to update Suricata"
else
    echo "Suricata not installed. Skipping update."
fi
echo "Fix_CentOS_Nessus.sh completed. Please review the output and re-run Nessus for validation."
exit 0
