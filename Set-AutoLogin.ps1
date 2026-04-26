#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Configures Windows automatic login so Echo Speaks Server starts without a manual password prompt.

.DESCRIPTION
    Sets the AutoAdminLogon registry keys under HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon
    so Windows logs in automatically on boot. Run once on the machine that hosts the server.

.PARAMETER Username
    The local Windows username to auto-login as. Defaults to the current user.

.PARAMETER Password
    The account password. Leave blank if the account has no password.

.EXAMPLE
    .\Set-AutoLogin.ps1 -Username "HomeServer" -Password "MyP@ssw0rd"

.EXAMPLE
    # Remove auto-login (restore normal login prompt)
    .\Set-AutoLogin.ps1 -Disable
#>

param(
    [string]$Username = $env:USERNAME,
    [string]$Password = "",
    [switch]$Disable
)

$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

if ($Disable) {
    Set-ItemProperty -Path $regPath -Name "AutoAdminLogon"   -Value "0"
    Remove-ItemProperty -Path $regPath -Name "DefaultPassword" -ErrorAction SilentlyContinue
    Write-Host "Auto-login disabled. A password will be required on next boot."
    exit 0
}

Set-ItemProperty -Path $regPath -Name "AutoAdminLogon"    -Value "1"
Set-ItemProperty -Path $regPath -Name "DefaultUsername"   -Value $Username
Set-ItemProperty -Path $regPath -Name "DefaultPassword"   -Value $Password
Set-ItemProperty -Path $regPath -Name "DefaultDomainName" -Value $env:COMPUTERNAME

Write-Host "Auto-login configured for user: $Username"
Write-Host "Windows will log in automatically on the next restart."
Write-Host ""
Write-Host "To undo this, run:  .\Set-AutoLogin.ps1 -Disable"
