##### Personal Environment Setup #####
$workFldr = "~/WORK" # Sandbox Code Workspace
$poShProfile = Get-Item -Path $PROFILE.CurrentUserAllHosts # Powershell Profile
$gitName = 'bentman' # GitHub Name
$gitRepos = "$workFldr/CODE/$($gitName)/Repositories" # Local GitHub Workspace
$gitProfile = "$($gitRepos)/PoSh-Profile/Linux/profile.ps1" # PoshProfile on GitHub Repository
$gitOnline = "https://GitHub.com/$($gitName)?tab=repositories" # GitHub Repository
$whoIsMe = whoami

# Fun phrase to display while profile is loading
Write-Host "Reticulating Splines..." -ForegroundColor Yellow

##### Functions #####
# edge - Function to open Microsoft Edge
function Open-Edge { Start-Process '/usr/bin/microsoft-edge-stable' -ArgumentList "%U" }
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
function Start-RDP ($systemName) { Start-Process "/snap/bin/remmina" -ArgumentList "-c rdp://$systemName" }
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
function Open-GitOnline { Start-Process '/usr/bin/microsoft-edge-stable' -ArgumentList $gitOnline }
Set-Alias -Name gme -Value Open-GitOnline -Description 'gme - open online git repo' -ea 0

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
$azSshKey = "~/.ssh/az-ssh-key.pem" # Linux jumpbox ssh-key

# myaz - Function to use az cli to connect to tenant
function Connect-Azure { az login -t $myAzTenant }
Set-Alias -Name myaz -Value Connect-Azure -Description 'use az cli to connect to tenant' -ea 0

# jumpwin - Function to connect to Windows vm jumpbox
function Connect-JumpWin { Start-Process "/snap/bin/remmina" -ArgumentList "-c rdp://$jumpWin" }
Set-Alias -Name jumpwin -Value Connect-JumpWin -Description 'rdp az jumpwin vm' -ea 0

# jumplin - Function to connect to Linux vm jumpbox
function Connect-JumpLin { ssh "$jumpAdmin@$jumpLin" -i $azSshKey }
Set-Alias -Name jumplin -Value Connect-JumpLin -Description 'ssh az jumplin vm' -ea 0

##### PoSh Environment Result #####
# Display aliases and paths for quick reference
(Get-Alias | Where-Object { $_.Name -in @('edge', 'rdp', 'mypip', 'grep', 'ops', 'tff') } |
Format-Table Name, Definition, Description -AutoSize -HideTableHeaders | Out-String).trim()

# Who am I & am I running as admin?
Write-Host "`nWho am I?" -ForegroundColor Yellow
Write-Host "    $whoIsMe" -ForegroundColor Green
# Write-Host "    Running as admin?... $($amIAdmin)"

# Is my stuff here?
Write-Host "`nWhere is my stuff?" -ForegroundColor Yellow
Write-Host "    $(Test-Path $workFldr)... $workFldr"
Write-Host "    $(Test-Path $gitRepos)... $gitRepos"
Write-Host "    $(Test-Path $poShProfile.FullName)... $($poShProfile.FullName)"

Push-Location $workFldr
