#!/usr/bin/env pwsh
$path = '\\internal.vandelayindustries.com\shares\DyNav\'
& "$path\setup.exe" /quiet /config "$path\DynamicsNAV100.xml" /log C:\log.txt
