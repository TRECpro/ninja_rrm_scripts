##
# script: EnableWakeOnLan.ps1
# author: manuelfischer <fischer@navanet.de>
# credits: kelvintegelaar, https://www.cyberdrain.com/monitoring-with-powershell-monitor-and-enabling-wol-for-hp-lenovo-dell/
#
# name: Enable Wake On Lan
# description: 	Enables Wake On Lan for Windows, sets BIOS settings for Lenovo, Dell or HP.
#				Disabling "Hiberboot" may be neccessary for WOL to work properly,
#				add the switch-parameter "-DisableFastBoot" to do so.
#
# category: Hardware
# language: PowerShell
# OS: Windows
# architecture: both
#
# runas: System
##


Param(
	[switch]$DisableFastBoot
)
if($DisableFastBoot) {
	Write-Host "Disabling Hiberboot" -forecroundcolor Green
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d "0" /f
}

$PPNuGet = Get-PackageProvider -ListAvailable | Where-Object { $_.Name -eq "Nuget" }
if (!$PPNuget) {
    Write-Host "Installing Nuget provider" -foregroundcolor Green
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
}
$PSGallery = Get-PSRepository -Name PsGallery
if (!$PSGallery) {
    Write-Host "Installing PSGallery" -foregroundcolor Green
    Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
}
$PsGetVersion = (get-module PowerShellGet).version
if ($PsGetVersion -lt [version]'2.0') {
    Write-Host "Installing latest version of PowerShellGet provider" -foregroundcolor Green
    install-module PowerShellGet -MinimumVersion 2.2 -Force
    Write-Host "Reloading Modules" -foregroundcolor Green
    Remove-Module PowerShellGet -Force
    Remove-module PackageManagement -Force
    Import-Module PowerShellGet -MinimumVersion 2.2 -Force
    Write-Host "Updating PowerShellGet" -foregroundcolor Green
    Install-Module -Name PowerShellGet -MinimumVersion 2.2.3 -force
    write-host "You must rerun the script to succesfully set the WOL status. PowerShellGet was found out of date." -ForegroundColor red
	exit 1
}
Write-Host "Checking Manufacturer" -foregroundcolor Green
$Manufacturer = (Get-WmiObject -Class:Win32_ComputerSystem).Manufacturer
if ($Manufacturer -like "*Dell*") {
    Write-Host "Manufacturer is Dell. Installing Module and trying to enable Wake on LAN." -foregroundcolor Green
    Write-Host "Installing Dell Bios Provider" -foregroundcolor Green
    Install-Module -Name DellBIOSProvider -Force
    import-module DellBIOSProvider
    try { 
        set-item -Path "DellSmBios:\PowerManagement\WakeOnLan" -value "LANOnly" -ErrorAction Stop
    }
    catch {
        write-host "an error occured. Could not set BIOS to WakeOnLan. Please try setting WOL manually"
    }
}
if ($Manufacturer -like "*HP*" -or $Manufacturer -like "*Hewlett*") {
    Write-Host "Manufacturer is HP. Installing module and trying to enable WakeOnLan. All HP Drivers are required for this operation to succeed." -foregroundcolor Green
    Write-Host "Installing HP Provider" -foregroundcolor Green
    Install-Module -Name HPCMSL -Force -AcceptLicense
    import-module HPCMSL
    try { 
        $WolTypes = get-hpbiossettingslist | Where-Object { $_.Name -like "*Wake On Lan*" }
        ForEach ($WolType in $WolTypes) {
            write-host "Setting WOL Type: $($WOLType.Name)"
            Set-HPBIOSSettingValue -name $($WolType.name) -Value "Boot to Hard Drive" -ErrorAction Stop 
        }
    }
    catch {
        write-host "an error occured. Could not set BIOS to WakeOnLan. Please try manually"
    }
}
if ($Manufacturer -like "*Lenovo*") {
    Write-Host "Manufacturer is Lenovo. Trying to set via WMI. All Lenovo Drivers are required for this operation to succeed." -foregroundcolor Green
    try { 
        Write-Host "Setting BIOS." -foregroundcolor Green
        (Get-WmiObject -ErrorAction Stop -class "Lenovo_SetBiosSetting" -namespace "root\wmi").SetBiosSetting('WakeOnLAN,Primary') | Out-Null
        Write-Host "Saving BIOS." -foregroundcolor Green
        (Get-WmiObject -ErrorAction Stop -class "Lenovo_SaveBiosSettings" -namespace "root\wmi").SaveBiosSettings() | Out-Null
    }
    catch {
        write-host "an error occured. Could not set BIOS to WakeOnLan. Please try manually"
    }
}
write-host "Setting NIC to enable WOL" -ForegroundColor Green
$NicsWithWake = Get-CimInstance -ClassName "MSPower_DeviceWakeEnable" -Namespace "root/wmi"
foreach ($Nic in $NicsWithWake) {
    write-host "Enabling for NIC" -ForegroundColor green
    Set-CimInstance $NIC -Property @{Enable = $true }
}