$ZabbixInstallPath = "$Env:Programfiles\Zabbix Agent 2"
$ZabbixConfFile = "$Env:Programfiles\Zabbix Agent 2"

$Senderarg0 = "$ZabbixInstallPath\zabbix_sender.exe"
$Senderarg1 = '-vv'
$Senderarg2 = '-c'
$Senderarg3 = "$ZabbixConfFile\zabbix_agent2.conf"
$Senderarg4 = '-i'
$SenderargUpdateReboot = '\updatereboot.txt'
$Senderarglastupdated = '\lastupdated.txt'
$Senderargcountcritical = '\countcritical.txt'
$SenderargcountOptional = '\countOptional.txt'
$SenderargcountHidden = '\countHidden.txt'

& $Senderarg0 $Senderarg1 $Senderarg2 $Senderarg3 $Senderarg4 $env$SenderargUpdateReboot -s "$env:computername"
& $Senderarg0 $Senderarg1 $Senderarg2 $Senderarg3 $Senderarg4 $env$Senderarglastupdated -s "$env:computername"
& $Senderarg0 $Senderarg1 $Senderarg2 $Senderarg3 $Senderarg4 $env$Senderargcountcritical -s "$env:computername"
& $Senderarg0 $Senderarg1 $Senderarg2 $Senderarg3 $Senderarg4 $env$SenderargcountOptional -s "$env:computername"
& $Senderarg0 $Senderarg1 $Senderarg2 $Senderarg3 $Senderarg4 $env$SenderargcountHidden -s "$env:computername"