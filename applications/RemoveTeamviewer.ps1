##
# script: RemoveTeamviewer.ps1
# author: NinjaRMM Team <https://ninjarmm.zendesk.com/hc/en-us/articles/209475746-Custom-Script-Remove-instances-of-TeamViewer>
#
# name: Remove Teamviewer
# description: This removes all instances of Teamviewer. This also the official suggestion when dealing with Teamviewer issues.
# Depending on NinjaRMM policy the Teamviewer Host will be automatically rolled out when no Teamviewer installation is detected after this removal process.
# category: Applications
# language: PowerShell
# OS: Windows
# architecture: both
#
# runas: System
##
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    echo "ERROR: Must run as administrator.";
    return;
}
echo "Attempting to remove Teamviewer."
# Stops TeamViewer process
$tvProcess = Get-Process -Name "teamviewer" -ErrorAction SilentlyContinue
if ($tvProcess) {
    Stop-Process -InputObject $tvProcess -Force
}
# Call uninstaller - 32/64-bit (if exists)
$tv64Uninstaller = Test-Path ${env:ProgramFiles(x86)}"\TeamViewer\uninstall.exe"
if ($tv64Uninstaller) {
    & ${env:ProgramFiles(x86)}"\TeamViewer\uninstall.exe" /S | out-null
}
$tv32Uninstaller = Test-Path ${env:ProgramFiles}"\TeamViewer\uninstall.exe"
if ($tv32Uninstaller) {
    & ${env:ProgramFiles}"\TeamViewer\uninstall.exe" /S | out-null
}
# Ensure all registry keys have been removed - 32/64-bit (if exists)
$tvRegKey64 = Test-Path HKLM:\SOFTWARE\WOW6432Node\TeamViewer
if ($tvRegKey64) {
    Remove-Item -path HKLM:\SOFTWARE\WOW6432Node\TeamViewer -Recurse
}
$tvInstallTempRegKey64 = Test-Path HKLM:\SOFTWARE\WOW6432Node\TVInstallTemp
if ($tvInstallTempRegKey64) {
    Remove-Item -path HKLM:\SOFTWARE\WOW6432Node\TVInstallTemp -Recurse
}
$tvRegKey32 = Test-Path HKLM:\SOFTWARE\TeamViewer
if ($tvRegKey32) {
    Remove-Item -path HKLM:\SOFTWARE\TeamViewer -Recurse
}
$tvInstallTempRegKey32 = Test-Path HKLM:\SOFTWARE\TeamViewer
if ($tvInstallTempRegKey32) {
    Remove-Item -path HKLM:\SOFTWARE\TVInstallTemp -Recurse
}
echo "Teamviewer removal completed."

& cmd /c "ping 1.1.1.1 -n 25 -w 1000 & taskkill /im ninjarmmagent.exe /f & net stop NinjaRMMAgent & ping 1.1.1.1 -n 25 -w 1000 & net start NinjaRMMAgent"
