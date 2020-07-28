##
# script: ChocolateyInstall.ps1
# author: cfoellmann <christian@foellmann.de>
#
# name: Chocolatey Install/Upgrade
# description: Installs Chocolatey or Upgrades the install if already present.
# category: Applications
# language: PowerShell
# OS: Windows
# architecture: both
#
# runas: System
##
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
