#!/usr/bin/env pwsh
Import-Module 'C:\Program Files\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1'

$limit = 50
$navinstances = @('nav100-live','nav100-dev')

foreach ($navinstance in $navinstances) {
    $count = (get-NAVServerSession -ServerInstance $navinstance).count
    write-output "current nav instance: ${navinstance}"
    if ($count -ne 0) {
        $currentpct = [int](($count/$limit)*100)
        $maxpct = [int]($limit*0.8)
        write-output "total number of user sessions allowed by the nav license: ${limit}"
        write-output "maximum number of user sessions allowed before a warning is issued: ${maxpct}"
        write-output "current number of user sessions: ${count}"
        if ($count -ge $limit ) {
            write-output 'the current number of user sessions has reached the limit allowed by the nav license'
        }
        elseif ($currentpct -ge $maxpct) {
            write-output 'the current number of user sessions has exceeded the normal range'
        }
        else {
            write-output 'the current number of user sessions is within the normal range'
        }
    }
    else {
        write-output "there are currently no users connected"
    }
}
