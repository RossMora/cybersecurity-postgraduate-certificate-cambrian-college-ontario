# Path to oscdimg
$oscdimgPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
echo $oscdimgPath
# IMG and ISO file paths
$imgFile = '..\img\OPNsense.img'
$isoFile = '..\iso\OPNsense.iso'

echo $imgFile
echo $isoFile

# Create an ISO from the mounted IMG file directly (assuming $imgFile is extracted)
Start-Process -FilePath $oscdimgPath -ArgumentList "/o /u2 `"$imgFile`" `"$isoFile`"" -Wait
echo "Operation Completed"