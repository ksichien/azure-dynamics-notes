#!/usr/bin/env pwsh
Import-Module 'C:\Program Files\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1'

$limit_value = 50 # sessions allowed by the nav license
$warning_percentage = 80 # percentage at which a warning will be issued
$warning_value = [int]($limit*($warning_percentage/100))

$navinstances = @('nav100-live','nav100-dev')

foreach ($navinstance in $navinstances) {
    $count_value = (get-NAVServerSession -ServerInstance $navinstance).count
    write-output "current nav instance: ${navinstance}"
    if ($count_value -ne 0) {
        $count_percentage = [int](($count_value/$limit_value)*100)
        write-output "total number of user sessions allowed by the nav license: ${limit_value}"
        write-output "maximum number of user sessions allowed before a warning is issued: ${warning_value}"
        write-output "current number of user sessions: ${count_value}"
        if ($count_value -ge $limit_value) {
            write-output 'the current number of user sessions has reached the limit allowed by the nav license'
        }
        elseif ($count_percentage -ge $warning_percentage) {
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
