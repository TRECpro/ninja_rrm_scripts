##
# script: ChocoInstallPackage.ps1
# author: cfoellmann <christian@foellmann.de>
#
# name: Chocolatey Install/Upgrade package
# description: Installs a package defined by the parameter via Chocolatey or Upgrades the package if already present.
# category: Applications
# language: PowerShell
# OS: Windows
# architecture: both
#
# runas: System
##
param(
    [string]$package
)

choco install $package --yes --limitoutput --no-progress
