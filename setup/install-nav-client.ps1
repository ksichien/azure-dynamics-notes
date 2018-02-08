#!/usr/bin/env pwsh
$path = '\\internal.vandelayindustries.com\shares\DyNav\'
& "$path\setup.exe" /quiet /config "$path\nav100-live.xml" /log C:\log.txt
