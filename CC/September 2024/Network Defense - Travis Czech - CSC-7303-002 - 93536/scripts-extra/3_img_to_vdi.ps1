$imgFile = "..\img\OPNsense.img"
$vdiFile = "..\vdi\OPNsense.vdi"

& VBoxManage convertfromraw --format VDI $imgFile $vdiFile