##
# script: RestartNinjaAgent.cmd
# author: NinjaRMM Team <https://ninjarmm.zendesk.com/hc/en-us/articles/115001062906-Custom-Script-Restart-NinjaRMMAgent>
#
# name: Restart NinjaAgent
# description: Restart the NinjaRMM Agent for troubleshooting
# category: Control
# language: CMD
# OS: Windows
# architecture: both
#
# runas: System
##
start cmd /c "ping 1.1.1.1 -n 75 -w 1000 & taskkill /im ninjarmmagent.exe /f & net stop NinjaRMMAgent & ping 1.1.1.1 -n 75 -w 1000 & net start NinjaRMMAgent"
