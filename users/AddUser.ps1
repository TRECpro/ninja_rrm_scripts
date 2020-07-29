##
# script: AddUser.ps1
# author: cfoellmann <foellmann@foe-services.de>
#
# name: Add User
# description: Add a local user and set password to NEVER expire
# category: Users
# language: PowerShell
# OS: Windows
# architecture: both
#
# runas: System
##
param(
    [string]$Username,
    [string]$Password,
    [string]$Admin
)

# Varies depending on the local of the target system
$group = "Administrators"

$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$existing = $adsi.Children | where {$_.SchemaClassName -eq 'user' -and $_.Name -eq $Username }

if ($existing -eq $null) {

    Write-Host "Creating new local user $Username."
    & NET USER $Username $Password /add /y /expires:never

    if ($Admin -ne $null) {
        Write-Host "Adding local user $Username to $group."
        & NET LOCALGROUP $group $Username /add
    }

}
else {
    Write-Host "Setting password for existing local user $Username."
    $existing.SetPassword($Password)
}

# Sets password as never expires
Write-Host "Ensuring password for $Username never expires."
& WMIC USERACCOUNT WHERE "Name='$Username'" SET PasswordExpires=FALSE
