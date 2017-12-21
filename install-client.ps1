#!/usr/bin/env pwsh
$path = '\\internal.vandelayindustries.com\shares\DyNav\'
& "$path\setup.exe" /quiet /config "$path\nav100_test.xml" /log C:\log.txt
