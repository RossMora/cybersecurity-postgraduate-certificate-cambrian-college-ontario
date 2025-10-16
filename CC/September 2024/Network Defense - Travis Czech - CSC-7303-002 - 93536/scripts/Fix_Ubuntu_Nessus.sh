#!/bin/bash
# Fix_Ubuntu_Nessus.sh – Script to address vulnerabilities identified by Nessus on Ubuntu
# Machine-Specific Precheck
EXPECTED_HOSTNAME="ubuntu-desktop"
if [[ "$(hostname)" != "$EXPECTED_HOSTNAME" ]]; then
  echo "Error: This script is intended for the system with hostname '$EXPECTED_HOSTNAME'."
  echo "Current hostname is '$(hostname)'. Exiting to prevent errors."
  exit 1
fi
echo "Starting Fix_Ubuntu_Nessus.sh on '$EXPECTED_HOSTNAME'..."
# Update Suricata
echo "Updating Suricata..."
apt-get install -y suricata || echo "Error: Suricata update failed. Check repository configuration."
# Secure OpenSSH configuration
echo "Securing OpenSSH..."
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd || echo "Error: Failed to restart OpenSSH."
# Upgrade Apache HTTP Server
echo "Upgrading Apache HTTP Server..."
apt-get install -y apache2 || echo "Error: Apache update failed. Check repository configuration."
# Remove malicious cron job
echo "Removing malicious cron jobs..."
if crontab -u root -l 2>/dev/null | grep -q 'malicious_command'; then
  crontab -u root -l | grep -v 'malicious_command' | crontab -u root
  echo "Malicious cron job removed."
else
  echo "No malicious cron job found."
fi
# Disable Netcat backdoor service
echo "Disabling Netcat backdoor service..."
if systemctl list-units --full -all | grep -q "malicious.service"; then
  systemctl stop malicious.service || echo "Error: Failed to stop malicious.service."
  systemctl disable malicious.service || echo "Error: Failed to disable malicious.service."
  rm -f /etc/systemd/system/malicious.service
  echo "Malicious service removed."
else
  echo "No malicious service found."
fi
# Final message
echo "Fix_Ubuntu_Nessus.sh completed. Review logs for any errors."
