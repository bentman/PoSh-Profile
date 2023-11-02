$amIAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$whoIsMe = whoami.exe
if ($amIAdmin) {
    $Host.UI.RawUI.WindowTitle = "Administrator: $whoIsMe"
} else {$Host.UI.RawUI.WindowTitle = "$whoIsMe"}
$pubIp4 = Invoke-RestMethod -Uri ('https://ipinfo.io/')
$pubIp6 = (Invoke-WebRequest http://ifconfig.me/ip).Content
##### PoSh Environment Setup #####
$workFldr = "D:\_WORK\CODE"
$gitRepos = "D:\USR\GitHub\bentman\Repositories"
$poShProfile = Get-Item -Path $PROFILE.CurrentUserAllHosts
Write-Host "Reticulating Splines..." -ForegroundColor Yellow
function Open-Edge {Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"}
if (-not (Get-Alias -Name edge -ea 0)) {Set-Alias -Name edge -Value Open-Edge -Description "open edge as current user"}
function Get-PublicIp {Write-Host "`n  Public IP4: $($pubIp4.ip) `n  Public IP6: $($pubIp6)`n" -ForegroundColor Magenta}
if (-not (Get-Alias -Name myip -ea 0)) {Set-Alias -Name myip -Value Get-PublicIp -Description 'what is my public ip?'}
function Start-RDP ($systemName) {Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList "/v:$systemName"}
if (-not (Get-Alias -Name rdp -ea 0)) {Set-Alias -Name rdp -Value Start-RDP -Description 'rdp computer/server'}
function Find-Work {if (-not (Test-Path $workFldr -ea 0)) {New-Item -Path $workFldr -ItemType Directory -Force} Push-Location -Path $workFldr}
if (-not (Get-Alias -Name work -ea 0)) {Set-Alias -Name work -Value Find-Work -Description "if not work, create, goto work"}
##### Git functions #####
function Find-GitRepo {if (-not (Test-Path $gitRepos -ea 0)) {New-Item -Path "$gitRepos" -ItemType Directory -Force} Push-Location -Path $gitRepos}
if (-not (Get-Alias -Name repo -ea 0)) {Set-Alias -Name repo -Value Find-GitRepo -Description "if not repo, create, goto repo"}
function Invoke-GitCommit ($message) {git add .;git commit -m $message}
if (-not (Get-Alias -Name gcom -ea 0)) {Set-Alias -Name gcom -Value Invoke-GitCommit -Description 'git commit "$message"'}
function Invoke-GitPush ($message) {git add .;git commit -m $message;git push}
if (-not (Get-Alias -Name gpush -ea 0)) {Set-Alias -Name gpush -Value Invoke-GitPush -Description 'git commit "$message" & push'}
##### Linux style functions #####
function Find-Pattern ($pattern) {$input | Out-String -Stream | Select-String $pattern}
if (-not (Get-Alias -Name grep -ea 0)) {Set-Alias -Name grep -Value Find-Pattern -Description 'grep - find $pattern from $input'}
function New-File ($file) {if (-not (Test-Path $file -ea 0)) {New-Item -Path "$file" -Force -ItemType File}}
if (-not (Get-Alias -Name touch -ea 0)) {Set-Alias -Name touch -Value New-File -Description 'touch - if not $file, create here'}
function Set-Pattern ($file,$pattern,$replace) {(Get-Content $file).replace("$pattern","$replace") | Set-Content $file}
if (-not (Get-Alias -Name sed -ea 0)) {Set-Alias -Name sed -Value Set-Pattern -Description 'sed - $replace a $pattern in $file'}
function Expand-ZipFileToFolder ($file,$folder) {
    if ($null -eq $folder) {$folder = New-Item -Path "$($PWD.Path)\$($file.Basename)" -ItemType Directory -Force -ea 0 
    } else {$folder = New-Item -Path $folder -ItemType Directory -Force -ea 0}
    Expand-Archive -Path $file -DestinationPath $folder -Verbose}
if (-not (Get-Alias -Name unzip -ea 0)) {Set-Alias -Name unzip -Value Expand-ZipFileToFolder -Description 'unzip - $file to $folder'}
function ix ($file) {curl.exe -F "f:1=@$file" ix.io}
##### PoSh Environment Result #####
Get-Alias | Where-Object {($_.Name -eq 'edge') -or 
    ($_.Name -eq 'rdp') -or 
    ($_.Name -eq 'repo') -or 
    ($_.Name -eq 'work') -or 
    ($_.Name -eq 'myip') -or
    ($_.Name -eq 'grep') -or 
    ($_.Name -eq 'touch') -or 
    ($_.Name -eq 'unzip')} |
Format-Table Name,Definition,Description -AutoSize
Write-Host "Who am I?" -ForegroundColor Yellow
Write-Host "    $whoIsMe" -ForegroundColor Green
Write-Host "    Running as admin?... $($amIAdmin)" 
Write-Host "" # Empty line for console readability
Write-Host "Where is my stuff?" -ForegroundColor Yellow
Write-Host "    $(Test-Path $workFldr)... $workFldr"
Write-Host "    $(Test-Path $gitRepos)... $gitRepos"
Write-Host "    $(Test-Path $poShProfile.FullName)... $($poShProfile.FullName)"
Write-Host "" # Empty line for console readability
Push-Location $workFldr

# $PROFILE | Format-List * -Force

<# Dot Source files in profile
Push-Location $poShProfile.Directory.FullName
. .\Use-BasicLinuxFunctions.ps1
Pop-Location
#>
<#
##### Azure Environment Setup (work-in-progress - msgraph) #####
function Get-MyAz {
    $myAzId = 'ec6c28b8-2f81-4ba0-8ee2-d6f798590f76' # AzureAD User ObjectId
    $myAzName = 'bentley@bentman.onmicrosoft.com' # AzureAD User ObjectId
    $myAzDevice = '1K73PK3' # AzureAD Primary Device (Computername)
    $azTenant = 'b32514e3-d308-4e48-af55-624905e74d8a' # Corp Tenant
    $azDomain = 'bentman.onmicrosoft.com' # Corp Domain
    $azSubId = '18c6a6e1-bd51-4605-839f-78fe85f6461d' # az-sub-p2-01
        $myCreds = Get-Credential -Credential "bentley@bentman.onmicrosoft.com"
    # Connect-AzureAD -Credential $myCreds
    $myAzId = Get-AzureADUser -ObjectId $myAzId
    $myAzGroups = Get-AzureADUserMembership -ObjectId $myAzId | Sort-Object -Property DisplayName | Format-Table
    # $myAzDevice = Get-AzureADDevice -SearchString $myAzDevice | Format-List
    Write-Host 'Reminder: Shortcut variables start with $az & $my' -ForegroundColor Green
}
if (-not (Get-Alias -Name myaz -ea 0)) {Set-Alias -Name myaz -Value Get-MyAz -Description "connect to azuread"}
#>