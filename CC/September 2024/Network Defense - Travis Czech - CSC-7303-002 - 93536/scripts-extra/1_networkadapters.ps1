# Create a NAT network called "WAN"
VBoxManage natnetwork add --netname "WAN" --network "10.0.2.0/24" --dhcp on

# Create a Host-only network adapter called "LAN" without DHCP
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0

# Ensure that the DHCP is disabled on the Host-only network
VBoxManage dhcpserver remove --ifname vboxnet0

# Optional: Display the current configuration for verification
Write-Host "NAT Networks:"
VBoxManage list natnetworks

Write-Host "Host-only Networks:"
VBoxManage list hostonlyifs

Write-Host "DHCP Servers:"
VBoxManage list dhcpservers