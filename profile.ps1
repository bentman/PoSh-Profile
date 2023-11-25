##### Personal Environment Setup #####
$gitName = 'bentman' # Your Git Name
$workFldr = "d:\_WORK" # Your Sandbox Code Workspace
$gitRepos = "e:\GitHub\$($gitName)\Repositories" # Your Local Github Workspace
$gitProfile = "https://github.com/$gitName" # Your Github Repository
$poShProfile = Get-Item -Path $PROFILE.CurrentUserAllHosts # Your Powershell Profile

# Set the console title based on administrative status
$amIAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$whoIsMe = whoami.exe
$Host.UI.RawUI.WindowTitle = if ($amIAdmin) { "Administrator: $whoIsMe" } else { "$whoIsMe" }

# Fun phrase to display while profile is loading
Write-Host "Reticulating Splines..." -ForegroundColor Yellow

##### Functions #####
# edge - Function to open Microsoft Edge
function Open-Edge { Start-Process "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe" }
Set-Alias -Name edge -Value Open-Edge -Description "open edge as current user" -ea SilentlyContinue

# myip - Function to display public IP addresses
function Get-PublicIp {
    # Retrieve public IP addresses
    $pubIp4 = Invoke-RestMethod -Uri ('https://ipinfo.io/')
    $pubIp6 = (Invoke-WebRequest http://ifconfig.me/ip).Content
    $dnsChks = @('one.one.one.one', 'dns.google')
    Write-Host "`n  Public IP4: $($pubIp4.ip) `n  Public IP6: $($pubIp6)" -ForegroundColor Magenta
    Write-Host "`n  Checking DNS resolvers..." -ForegroundColor Green
    foreach ($dnsChk in $dnsChks) { Resolve-DnsName -Name $dnsChk }
}
Set-Alias -Name myip -Value Get-PublicIp -Description 'what is my public ip?' -ea SilentlyContinue

# rdp - Function to start a remote desktop connection
function Start-RDP ($systemName) { Start-Process "$env:SystemRoot\system32\mstsc.exe" -ArgumentList "/v:$systemName" }
Set-Alias -Name rdp -Value Start-RDP -Description 'rdp computer/server' -ea SilentlyContinue

# work - Function to navigate to or create and navigate to the work folder
function Find-Work {
    if (-not (Test-Path $workFldr -ea 0)) { New-Item -Path $workFldr -ItemType Directory -Force }
    Push-Location -Path $workFldr
}
Set-Alias -Name work -Value Find-Work -Description "if not work, create, goto work" -ea SilentlyContinue

##### Git functions #####
# repo - Function to navigate to or create and navigate to the git repositories folder
function Find-GitRepo {
    if (-not (Test-Path $gitRepos -ea 0)) { New-Item -Path "$gitRepos" -ItemType Directory -Force }
    Push-Location -Path $gitRepos
}
Set-Alias -Name repo -Value Find-GitRepo -Description "if not repo, create, goto repo" -ea SilentlyContinue

# gcom - Function to add all changes and commit with a message
function Invoke-GitCommit ($message) { git add .; git commit -m $message }
Set-Alias -Name gcom -Value Invoke-GitCommit -Description 'git commit "$message"' -ea SilentlyContinue

# gpush - Function to add all changes, commit with a message, and push to the remote repository
function Invoke-GitPush ($message) { git add .; git commit -m $message; git push }
Set-Alias -Name gpush -Value Invoke-GitPush -Description 'git commit "$message" & push' -ea SilentlyContinue

##### Linux style functions #####
# grep - Function to find a pattern in the input
function Find-Pattern ($pattern) { $input | Out-String -Stream | Select-String $pattern }
Set-Alias -Name grep -Value Find-Pattern -Description 'grep - find $pattern from $input' -ea SilentlyContinue

# touch - Function to create a new file if it does not exist
function New-File ($file) { if (-not (Test-Path $file -ea 0)) { New-Item -Path "$file" -Force -ItemType File } }
Set-Alias -Name touch -Value New-File -Description 'touch - if not $file, create here' -ea SilentlyContinue

# sed - Function to replace a pattern in a file
function Set-Pattern ($file, $pattern, $replace) { (Get-Content $file).replace("$pattern", "$replace") | Set-Content $file }
Set-Alias -Name sed -Value Set-Pattern -Description 'sed - $replace a $pattern in $file' -ea SilentlyContinue

# unzip - Function to expand a zip file to a folder
function Expand-ZipToFolder ($zipFile, $zipFolder) {
    if ($zipFolder) { $zipFolder = New-Item -Path $zipFolder -ItemType Directory -Force -ea 0 }
    else { $zip = Get-Item $zipFile; $zipFolder = New-Item -Path "$($PWD.Path)\$($zip.BaseName)" -ItemType Directory -Force -ea 0 }
    Expand-Archive -Path $zipFile -DestinationPath $zipFolder -Verbose
}
Set-Alias -Name unzip -Value Expand-ZipToFolder -Description 'unzip - $zipFile to $zipFolder' -ea SilentlyContinue
##### Azure Functions ##### 
##### (Coming soon to a repo near you!) #####

##### PoSh Environment Result #####
# Display aliases and paths for quick reference
(Get-Alias | Where-Object { $_.Name -in @('edge', 'rdp', 'myip', 'grep', 'touch', 'sed', 'unzip') } |
Format-Table Name, Definition, Description -AutoSize -HideTableHeaders | Out-String).trim()

# Who am I & am I running as admin?
Write-Host "`nWho am I?" -ForegroundColor Yellow
Write-Host "    $whoIsMe" -ForegroundColor Green
Write-Host "    Running as admin?... $($amIAdmin)" 

# Is my stuff here?
Write-Host "`nWhere is my stuff?" -ForegroundColor Yellow
Write-Host "    $(Test-Path $workFldr)... $workFldr"
Write-Host "    $(Test-Path $gitRepos)... $gitRepos"
Write-Host "    $(Test-Path $poShProfile.FullName)... $($poShProfile.FullName)"

Push-Location $workFldr

# $PROFILE | Format-List * -Force
