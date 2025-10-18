#!/bin/bash
# install_openvas.sh – Automates OpenVAS installation and setup on Kali
set -e
apt update
apt install -y openvas
gvm-setup       # Initialize Greenbone Vulnerability Manager (fetch feeds, etc.)
gvm-start       # Start OpenVAS services (gvmd, ospd-openvas, and gsad)
echo "OpenVAS installation and setup complete."
