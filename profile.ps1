##### Personal Environment Setup #####
$gitName = 'bentman' # GitHub Name
$gitOnline = "https://GitHub.com/$($gitName)?tab=repositories" # GitHub Repository
$gitRepos = "d:\GitHub\$($gitName)\Repositories" # Local GitHub Workspace
$gitProfile = "$gitRepos\PoSh-Profile\profile.ps1" # PoshProfile on GitHub Repository
$poShProfile = Get-Item -Path $PROFILE.CurrentUserAllHosts # Powershell Profile
$workFldr = "d:\WORK" # Sandbox Code Workspace

# Set the console title based on administrative status
$amIAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$whoIsMe = whoami.exe
$Host.UI.RawUI.WindowTitle = if ($amIAdmin) { "Administrator: $whoIsMe" } else { "$whoIsMe" }

# Fun phrase to display while profile is loading
Write-Host "Reticulating Splines..." -ForegroundColor Yellow

##### Functions #####
# edge - Function to open Microsoft Edge
function Open-Edge { Start-Process "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe" }
Set-Alias -Name edge -Value Open-Edge -Description "open edge as current user" -ea 0

# myip - Function to display public IP addresses
function Get-PublicIp {
    # Retrieve public IP addresses
    $pubIp4 = Invoke-RestMethod -Uri ('https://ipinfo.io/')
    $pubIp6 = (Invoke-WebRequest http://ifconfig.me/ip).Content
    Write-Host "`n  Public IP4: $($pubIp4.ip) `n  Public IP6: $($pubIp6)`n" -ForegroundColor Magenta
}
Set-Alias -Name mypip -Value Get-PublicIp -Description 'what is my public ip?' -ea 0

# rdp - Function to start a remote desktop connection
function Start-RDP ($systemName) { Start-Process "$env:SystemRoot\system32\mstsc.exe" -ArgumentList "/v:$systemName" }
Set-Alias -Name rdp -Value Start-RDP -Description 'rdp computer/server' -ea 0

# work - Function to navigate to or create and navigate to the work folder
function Find-Work {
    if (-not (Test-Path $workFldr -ea 0)) { New-Item -Path $workFldr -ItemType Directory -Force }
    Push-Location -Path $workFldr
}
Set-Alias -Name work -Value Find-Work -Description "if not work, create, goto work" -ea 0

##### Git functions #####
# repo - Function to navigate to or create and navigate to the git repositories folder
function Find-GitRepo {
    if (-not (Test-Path $gitRepos -ea 0)) { New-Item -Path "$gitRepos" -ItemType Directory -Force }
    Push-Location -Path $gitRepos
}
Set-Alias -Name repo -Value Find-GitRepo -Description "if not repo, create, goto repo" -ea 0

# gcom - Function to add all changes and commit with a message
function Invoke-GitCommit ($message) { git add .; git commit -m $message }
Set-Alias -Name gcom -Value Invoke-GitCommit -Description 'git commit "$message"' -ea 0

# gpush - Function to add all changes, commit with a message, and push to the remote repository
function Invoke-GitPush ($message) { git add .; git commit -m $message; git push }
Set-Alias -Name gpush -Value Invoke-GitPush -Description 'git commit "$message" & push' -ea 0

# gme - Function to 
function Open-GitOnline { Start-Process "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe" -ArgumentList $gitOnline }
Set-Alias -Name gme -Value Open-GitOnline -Description 'gme - open online git repo' -ea 0

##### Linux style functions #####
# grep - Function to find a pattern in the input
function Find-Pattern ($pattern) { $input | Out-String -Stream | Select-String $pattern }
Set-Alias -Name grep -Value Find-Pattern -Description 'grep - find $pattern from $input' -ea 0

# touch - Function to create a new file if it does not exist
function New-File ($file) { if (-not (Test-Path $file -ea 0)) { New-Item -Path "$file" -Force -ItemType File } }
Set-Alias -Name touch -Value New-File -Description 'touch - if not $file, create here' -ea 0

# sed - Function to replace a pattern in a file
function Set-Pattern ($file, $pattern, $replace) { (Get-Content $file).replace("$pattern", "$replace") | Set-Content $file }
Set-Alias -Name sed -Value Set-Pattern -Description 'sed - $replace a $pattern in $file' -ea 0

# unzip - Function to expand a zip file to a folder
function Expand-ZipToFolder ($zipFile, $zipFolder) {
    if ($zipFolder) { $zipFolder = New-Item -Path $zipFolder -ItemType Directory -Force -ea 0 }
    else { $zip = Get-Item $zipFile; $zipFolder = New-Item -Path "$($PWD.Path)\$($zip.BaseName)" -ItemType Directory -Force -ea 0 }
    Expand-Archive -Path $zipFile -DestinationPath $zipFolder -Verbose
}
Set-Alias -Name unzip -Value Expand-ZipToFolder -Description 'unzip - $zipFile to $zipFolder' -ea 0

##### VSCode Functions #####
# ops - Function to open all PowerShell files (*.ps1) in current path using VSCode
function Open-Ps1Files { Get-ChildItem -Path . -Filter *.ps1 | ForEach-Object { code $_.FullName } }
Set-Alias -Name ops -Value Open-Ps1Files -Description 'ops - open *.ps1 in vscode' -ea 0

# tff - Function to open all Terraform files (*.tf,*.tfvars) in current path using VSCode
function Open-TerraFiles { Get-ChildItem -Path . -Include *.tf, *.tfvars -Recurse | ForEach-Object { code $_.FullName } }
Set-Alias -Name tff -Value Open-TerraFiles -Description 'tff - open *.tf & *.tfvars in vscode' -ea 0

##### Azure Functions ##### 
$myAzTenant = 'Your-AzTenant-Id'
$jumpAdmin = 'adminuser' # VM Administrator Username
$jumpWin = 'vm-windows.az-region.cloudapp.azure.com' # Windows jumpbox
$jumpLin = 'vm-linux.az-region.cloudapp.azure.com' # Linux jumpbox
$azSshKey = "$env:USERPROFILE\.ssh\az-ssh-key.pem" # Linux jumpbox ssh-key

# myaz - Function to use az cli to connect to tenant
function Connect-Azure { az login -t $myAzTenant } 
Set-Alias -Name myaz -Value Connect-Azure -Description 'use az cli to connect to tenant' -ea 0

# jumpwin - Function to connect to Windows vm jumpbox
function Connect-JumpWin { Start-Process "$env:SystemRoot\system32\mstsc.exe" -ArgumentList "/v:$jumpWin" }
Set-Alias -Name jumpwin -Value Connect-JumpWin -Description 'rdp az jumpwin vm' -ea 0

# jumplin - Function to connect to Linux vm jumpbox
function Connect-JumpLin { ssh "$jumpAdmin@$jumpLin" -i $azSshKey }
Set-Alias -Name jumplin -Value Connect-JumpLin -Description 'ssh az jumplin vm' -ea 0

##### PoSh Environment Result #####
# Display aliases and paths for quick reference
(Get-Alias | Where-Object { $_.Name -in @('edge', 'rdp', 'mypip', 'grep', 'ops', 'tff', 'touch', 'sed', 'unzip') } |
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
