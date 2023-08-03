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
$Countcriticalnum = '\countcriticalnum.txt'
$responseOkPath = '\responseOk.txt'

# Фича для отправки на сервер ответа ok в случае начала работы скрипта для обхода ограничений timeout  
Write-Output "- Winupdates.statusOk OK" | Out-File -Encoding "ASCII" -FilePath $env$responseOkPath
& $Senderarg0 $Senderarg1 $Senderarg2 $Senderarg3 $Senderarg4 $responseOkPath -s "$env:computername"

# Запрос обновлений
$windowsUpdateObject = New-Object -ComObject Microsoft.Update.AutoUpdate
Write-Output "- Winupdates.LastUpdated $($windowsUpdateObject.Results.LastInstallationSuccessDate)" | Out-File -Encoding "ASCII" -FilePath $env$Senderarglastupdated

# проверка на необходимость обновлений
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"){ 
	Write-Output "- Winupdates.Reboot 1" | Out-File -Encoding "ASCII" -FilePath $env$SenderargUpdateReboot
    Write-Host "`t There is a reboot pending" -ForeGroundColor "Red"
}else {
	Write-Output "- Winupdates.Reboot 0" | Out-File -Encoding "ASCII" -FilePath $env$SenderargUpdateReboot
    Write-Host "`t No reboot pending" -ForeGroundColor "Green"
		}

# считаем обновления
$updateSession = new-object -com "Microsoft.Update.Session"
$updates=$updateSession.CreateupdateSearcher().Search(("IsInstalled=0 and Type='Software'")).Updates

$criticalTitles = "";
$countCritical = 0;
$countOptional = 0;
$countHidden = 0;

foreach ($update in $updates) {
	if ($update.IsHidden) {
		$countHidden++
	}
	elseif ($update.AutoSelectOnWebSites) {
		$criticalTitles += $update.Title + " `n"
		$countCritical++
	} else {
		$countOptional++
	}
}

if ($updates.Count -eq 0) {

	$countCritical | Out-File -Encoding "ASCII" -FilePath $env$Countcriticalnum
	Write-Output "- Winupdates.Critical $($countCritical)" | Out-File -Encoding "ASCII" -FilePath $env$Senderargcountcritical
	Write-Output "- Winupdates.Optional $($countOptional)" | Out-File -Encoding "ASCII" -FilePath $env$SenderargcountOptional
	Write-Output "- Winupdates.Hidden $($countHidden)" | Out-File -Encoding "ASCII" -FilePath $env$SenderargcountHidden
    Write-Host "`t There are no pending updates" -ForeGroundColor "Green"
	
	exit $returnStateOK
}

if (($countCritical + $countOptional) -gt 0) {

	$countCritical | Out-File -Encoding "ASCII" -FilePath $env:temp$Countcriticalnum
	Write-Output "- Winupdates.Critical $($countCritical)" | Out-File -Encoding "ASCII" -FilePath $env$Senderargcountcritical
	Write-Output "- Winupdates.Optional $($countOptional)" | Out-File -Encoding "ASCII" -FilePath $env$SenderargcountOptional
	Write-Output "- Winupdates.Hidden $($countHidden)" | Out-File -Encoding "ASCII" -FilePath $env$SenderargcountHidden
    Write-Host "`t There are $($countCritical) critical updates available" -ForeGroundColor "Yellow"
    Write-Host "`t There are $($countOptional) optional updates available" -ForeGroundColor "Yellow"
    Write-Host "`t There are $($countHidden) hidden updates available" -ForeGroundColor "Yellow"
	
}

if ($countOptional -gt 0) {
	exit $returnStateOptionalUpdates
}

if ($countHidden -gt 0) {
	
	$countCritical | Out-File -Encoding "ASCII" -FilePath $env$Countcriticalnum
	Write-Output "- Winupdates.Critical $($countCritical)" | Out-File -Encoding "ASCII" -FilePath $env$Senderargcountcritical
	Write-Output "- Winupdates.Optional $($countOptional)" | Out-File -Encoding "ASCII" -FilePath $env$SenderargcountOptional
	Write-Output "- Winupdates.Hidden $($countHidden)" | Out-File -Encoding "ASCII" -FilePath $env$SenderargcountHidden
    Write-Host "`t There are $($countCritical) critical updates available" -ForeGroundColor "Yellow"
    Write-Host "`t There are $($countOptional) optional updates available" -ForeGroundColor "Yellow"
    Write-Host "`t There are $($countHidden) hidden updates available" -ForeGroundColor "Yellow"
	
	exit $returnStateOK
}

exit $returnStateUnknown