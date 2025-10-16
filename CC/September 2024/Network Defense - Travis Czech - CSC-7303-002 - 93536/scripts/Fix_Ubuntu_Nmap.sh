#!/bin/bash
# Fix_Ubuntu_Nmap.sh – Script to address vulnerabilities identified by Nmap on Ubuntu
# Ensure the script is run on the correct system
if [[ "$(hostname)" != "ubuntu-desktop" ]]; then
  echo "This script is intended for Ubuntu. Exiting to prevent errors."
  exit 1
fi
echo "Starting Fix_Ubuntu_Nmap.sh on 'ubuntu-desktop'..."
# Fix SSH Configuration (disable root login)
echo "Securing SSH configuration..."
if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
  sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
  echo "Root login disabled in SSH."
else
  echo "Root login already disabled."
fi
# Restart SSH service
echo "Restarting SSH service..."
systemctl restart ssh
# Restrict HTTP methods (disable TRACE/TRACK in Apache)
echo "Restricting HTTP methods..."
if [[ -f /etc/apache2/apache2.conf ]]; then
  echo "
<Directory /var/www/html>
    <IfModule mod_headers.c>
        Header always unset X-Powered-By
    </IfModule>
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} ^(TRACE|TRACK)
    RewriteRule .* - [F]
</Directory>
" >> /etc/apache2/apache2.conf
  echo "HTTP methods TRACE and TRACK restricted."
else
  echo "Apache configuration file not found. Skipping HTTP methods restriction."
fi
# Restart Apache service
echo "Restarting Apache service..."
systemctl restart apache2
# Close unused ports via UFW
echo "Closing unused ports..."
ufw enable
ufw deny 4444
ufw deny 3389
ufw reload
echo "Ports 4444 and 3389 closed."
echo "Fix_Ubuntu_Nmap.sh completed. Please verify changes and re-run Nmap for validation."
