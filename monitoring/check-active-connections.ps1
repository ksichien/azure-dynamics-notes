#!/usr/bin/env pwsh
Import-Module 'C:\Program Files\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1'

$limit_value = 50 # sessions allowed by the nav license
$warning_percentage = 80 # percentage at which a warning will be issued
$warning_value = [int]($limit*($warning_percentage/100))

$navinstances = @('nav100-live','nav100-dev')

$recipient = 'nav-admins@vandelayindustries.com'

function mail-nav-report ([string]$to,[string]$subject,[string]$body) {
    $from = 'hourly-nav-report@vandelayindustries.com'
    $smtpserver = 'smtp.vandelayindustries.com'
    $smtpport = '587'
    $securepassword = ConvertTo-SecureString 'P@ssword!' -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ('hourly-nav-report', $securepassword)

    Send-MailMessage -From $from -to $to -Subject $subject `
    -Body $body -SmtpServer $smtpserver -port $smtpport -UseSsl `
    -Credential $credential -BodyAsHtml
}

foreach ($navinstance in $navinstances) {
    $count_value = [int](get-NAVServerSession -ServerInstance $navinstance).count
    $subject = "Hourly NAV Report for ${navinstance}"
    $body = "<h2>Current nav instance: ${navinstance}</h2>"
    if ($count_value -ne 0) {
        $count_percentage = [int](($count_value/$limit_value)*100)
        $body += "<p>Total number of user sessions allowed by the nav license: ${limit_value}</p>"
        $body += "<p>Maximum number of user sessions allowed before a warning is issued: ${warning_value}</p>"
        $body += "<p>Current number of user sessions: ${count_value}</p>"
        if ($count_value -ge $limit_value) {
            $body += "<p>The current number of user sessions has reached the limit allowed by the nav license.</p>"
        }
        elseif ($count_percentage -ge $warning_percentage) {
            $body += "<p>The current number of user sessions has exceeded the normal range.</p>"
        }
        else {
            $body += "<p>The current number of user sessions is within the normal range.</p>"
        }
    }
    else {
        $body += "<p>There are currently no users connected.</p>"
    }
    mail-nav-report $recipient $subject $body
}
