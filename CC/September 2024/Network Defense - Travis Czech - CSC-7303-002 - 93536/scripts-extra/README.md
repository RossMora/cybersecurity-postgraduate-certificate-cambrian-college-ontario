# scripts-extra

This folder contains additional scripts referenced during the course labs, beyond the six Bash scripts embedded in the course README.

- 1_networkadapters.ps1 — Enumerate/adjust VirtualBox network adapter settings for lab setup
- 2_img_to_iso.ps1 — Convert image formats during media preparation
- 3_img_to_vdi.ps1 — Convert disk images to VDI for VirtualBox
- makevulnerable.ps1 — Controlled host weakening for final exam scenario (for testing defenses)
- VulnerableCentOS.sh — Apply known weak settings to a CentOS VM (lab/exam)
- VulnerableUbuntu.sh — Apply known weak settings to an Ubuntu VM (lab/exam)

Caution: Do not run the “vulnerable” scripts on production systems. They intentionally reduce security for demonstration/testing.
