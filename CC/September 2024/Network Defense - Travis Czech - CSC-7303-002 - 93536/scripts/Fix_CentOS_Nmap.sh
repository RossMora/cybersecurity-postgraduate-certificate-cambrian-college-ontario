#!/bin/bash
# Fix_CentOS_Nmap.sh – Address Nmap-identified issues on CentOS
# Machine-specific check
if [[ "$(hostname)" != "localhost.localdomain" ]]; then
    echo "This script is intended for the CentOS VM only. Exiting to prevent errors."
    exit 1
fi
echo "Starting Fix_CentOS_Nmap.sh on $(hostname)..."
# Function to handle errors
handle_error() {
    echo "Error encountered: $1"
    echo "Please review logs and manually address the issue."
}
# Ensure firewalld is running
echo "Checking if firewalld is running..."
if ! systemctl is-active --quiet firewalld; then
    echo "firewalld is not running. Attempting to start it..."
    systemctl start firewalld || handle_error "Failed to start firewalld"
    systemctl enable firewalld || handle_error "Failed to enable firewalld"
fi
echo "firewalld is active."
# 1. Disable TRACE and OPTIONS HTTP methods in Apache
echo "Disabling TRACE and OPTIONS HTTP methods in Apache..."
if grep -q "TraceEnable" /etc/httpd/conf/httpd.conf; then
    sed -i 's/^TraceEnable.*/TraceEnable Off/' /etc/httpd/conf/httpd.conf
else
    echo "TraceEnable Off" >> /etc/httpd/conf/httpd.conf
fi
cat <<EOF >> /etc/httpd/conf/httpd.conf
<Directory />
    Options -Indexes
    AllowOverride None
</Directory>
EOF
systemctl restart httpd || handle_error "Failed to restart Apache"
echo "Apache HTTP server secured."
# 2. Secure SSH service
echo "Securing SSH service..."
if grep -q "^PermitRootLogin" /etc/ssh/sshd_config; then
    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
else
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi
systemctl restart sshd || handle_error "Failed to restart SSH service"
echo "SSH service secured."
# 3. Restrict access to open ports via firewalld
echo "Restricting access to open ports..."
firewall-cmd --add-service=ssh --permanent || handle_error "Failed to add SSH to firewall"
firewall-cmd --add-service=http --permanent || handle_error "Failed to add HTTP to firewall"
firewall-cmd --reload || handle_error "Failed to reload firewall rules"
echo "Access to open ports restricted."
# 4. Hide HTTP server version and other sensitive headers
echo "Hiding HTTP server version and other sensitive headers..."
if ! grep -q "ServerTokens" /etc/httpd/conf/httpd.conf; then
    echo "ServerTokens Prod" >> /etc/httpd/conf/httpd.conf
fi
if ! grep -q "ServerSignature" /etc/httpd/conf/httpd.conf; then
    echo "ServerSignature Off" >> /etc/httpd/conf/httpd.conf
fi
systemctl restart httpd || handle_error "Failed to restart Apache"
echo "HTTP server headers secured."
# 5. Verify and clean up unnecessary services
echo "Verifying services and cleaning up unnecessary ones..."
systemctl disable avahi-daemon || handle_error "Failed to disable avahi-daemon"
systemctl stop avahi-daemon || handle_error "Failed to stop avahi-daemon"
echo "Unnecessary services cleaned."
echo "Fix_CentOS_Nmap.sh completed. Please re-run Nmap to validate fixes."
