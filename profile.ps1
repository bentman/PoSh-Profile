<#
.SYNOPSIS
    Initializes the PowerShell environment with configurations for local, internet, and cloud environments.

.DESCRIPTION
    This PowerShell profile script sets up the environment by defining variables, creating necessary directories,
    and establishing functions and aliases for efficient task management and navigation.

.DECLARATIONS
    - Local Environment:
        $whoIsMe: Contains the username retrieved from native posh/pwsh.
        $poShProfile: Path to the PowerShell profile for all hosts.
        $localDrives: Lists all local drives, excluding temporary and 'Temp' drives.
        $workFldr: Searches or creates a 'WORK' directory on available drives.
        $codeFldr: Defines or creates a 'CODE' directory inside the 'WORK' folder.

    - Internet Environment:
        $gitName: GitHub username.
        $gitOnline: URL to the GitHub profile's repositories.
        $gitRepos: Local path for GitHub repository workspace.
        $gitProfile: Path to the PowerShell profile stored on GitHub.

    - Cloud Environment:
        Variables for Azure tenant and subscription IDs, admin IDs, and SSH keys for remote connections to virtual machines.

.FUNCTIONS
    - General Utilities:
        Find-Work, Find-CodeDev, Open-Edge, Start-RDP, Move-ToRecycleBin, Clear-OldTemp, Get-PublicIp
    - Git Operations:
        Find-GitRepo, Invoke-GitCommit, Invoke-GitPush, Open-GitOnline
    - Linux-style commands:
        Find-Pattern (grep), New-File (touch), Set-Pattern (sed), Expand-ZipToFolder (unzip)
    - Visual Studio Code operations:
        Open-Ps1Files, Open-TerraVars, Open-TerraFiles
    - Azure Functions:
        Connect-Azure, Connect-JumpWin, Connect-JumpLin

.ALIASES
    - Provides shorthand access to the defined functions, such as 'work' for Find-Work and 'dev' for Find-CodeDev.

.EXECUTION
    - Initializes with a fun phrase, sets the console title based on the user's admin status, and configures the command prompt.
    - Displays aliases and path configurations for quick reference.
    - Checks and displays user identity and admin status, along with the existence of essential directories.

.EXAMPLE
    PowerShell starts and executes the profile script, setting up the environment automatically.

.NOTES
    Ensure to replace placeholder values in cloud and internet environment variables with actual data.
#>
##### VSCode Shell Integration #####
if ($env:TERM_PROGRAM -eq "vscode") { . "$(code --locate-shell-integration-path pwsh)" }

########## DECLARATION ##########
##### Local Environment #####
$whoIsMe = "$($env:userdomain.ToLower())" + '\' + "$($env:username.ToLower())"
$poShProfile = Get-Item -Path $PROFILE.CurrentUserAllHosts # Powershell Profile
$localDrives = Get-PSDrive -PSProvider 'FileSystem' | Where-Object { $_.DisplayRoot -eq $null -and $_.Name -ne 'Temp' }
$workFldr = ($localDrives | ForEach-Object { Get-ChildItem "$($_.Root)" -Filter 'WORK' -Directory -ea 0 }).FullName
if ($null -eq $workFldr) { New-Item -Path "$env:SystemDrive\WORK" -ItemType Directory -Force }
$codeFldr = "$workFldr\CODE"; if (-not (Test-Path $codeFldr)) { New-Item -Path "$codeFldr" -ItemType Directory -Force }

##### Internet Environment #####
$gitName = 'bentman' # GitHub Name
$gitOnline = "https://GitHub.com/$($gitName)?tab=repositories" # GitHub Repository
$gitRepos = "$codeFldr\GitHub\$($gitName)\Repositories" # Local GitHub Workspace
if (-not (Test-Path $gitRepos)) { New-Item -Path "$gitRepos" -ItemType Directory -Force }
$gitProfile = "$gitRepos\PoSh-Profile\profile.ps1" # PoshProfile on GitHub Repository

##### Cloud Environment #####
$myAzTenant = '< YourTenantId >'
$myAzSub = '< YourSubscriptionId >'
$jumpWinAdmin = '< YourAdminId >'
$winSshKey = "$env:OneDrive\.ssh\ssh-jumpwin.pem" # Your SSH Private-Key
$jumpWin = "$jumpWinAdmin.< YourRegion >.cloudapp.azure.com"
$jumpLinAdmin = '< YourAdminId >'
$linSshKey = "$env:OneDrive\.ssh\ssh-jumplin.pem" # Your SSH Private-Key
$jumpLin = "$jumpLinAdmin.< YourRegion >.cloudapp.azure.com"

##########  FUNCTIONS  ##########
# work - Function to navigate to work folder
function Find-Work { Push-Location -Path $workFldr }
Set-Alias -Name work -Value Find-Work -Description 'goto $workFldr' -ea 0

# dev - Function to navigate to code folder
function Find-CodeDev { Push-Location -Path $codeFldr }
Set-Alias -Name dev -Value Find-CodeDev -Description 'goto $codeFldr' -ea 0

# edge - Function to open Microsoft Edge
function Open-Edge { Start-Process "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe" }
Set-Alias -Name edge -Value Open-Edge -Description "open edge as current user" -ea 0

# rdp - Function to start a remote desktop connection
function Start-RDP ($systemName) { Start-Process "$env:SystemRoot\system32\mstsc.exe" -ArgumentList "/v:$systemName" }
Set-Alias -Name rdp -Value Start-RDP -Description 'rdp computer/server' -ea 0

# recycle - Function to move file to recycle bin
function Move-ToRecycleBin ($fileName) { 
  if (!(Get-Module Recycle)) { Install-Module Recycle; Import-Module Recycle }; Remove-ItemSafely -Path "$fileName" 
}
Set-Alias -Name recycle -Value Move-ToRecycleBin -Description "move file to recycle bin" -ea 0

# clrtmp - Function to remove $env:TEMP items older than 7 days
function Clear-OldTemp { Get-ChildItem "$env:TEMP\*" -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | Remove-Item -Recurse -Verbose }
Set-Alias -Name clrtmp -Value Clear-OldTemp -Description 'remove $env:TEMP items older 7 days' -ea 0

# myip - Function to display public IP addresses
function Get-PublicIp {
  # Retrieve public IP addresses
  $pubIp4 = (Invoke-WebRequest 'https://ipv4.icanhazip.com').Content
  $pubIp6 = (Invoke-WebRequest 'https://icanhazip.com').Content
  Write-Host "`n  Public IP4: $($pubIp4)  Public IP6: $($pubIp6)" -ForegroundColor Magenta
}
Set-Alias -Name mypip -Value Get-PublicIp -Description 'what is my public ip?' -ea 0

function Copy-FolderWithProgress {
  [CmdletBinding()]param([Parameter(Mandatory)][string]$Source, [Parameter(Mandatory)][string]$Destination)
  if (!(Test-Path $Source)) { throw "Source path '$Source' does not exist" }
  if (!(Test-Path $Destination)) { New-Item -ItemType Directory -Path $Destination | Out-Null }
  $files = Get-ChildItem $Source -Recurse -File
  if ($files.Count -eq 0) { Write-Warning "No files found in source directory"; return }
  $total = $files.Count; $i = 0
  foreach ($f in $files) {
    $i++
    $t = Join-Path $Destination $f.FullName.Substring($Source.Length).TrimStart('\', '/')
    $d = Split-Path $t -Parent
    if (!(Test-Path $d)) { New-Item $d -ItemType Directory | Out-Null }
    Copy-Item $f.FullName $t -Force
    Write-Progress -Activity "Copying Files" -Status "$i/$total" -PercentComplete (($i / $total) * 100) -CurrentOperation "Copying $($f.Name)"
    if ($i -eq $total) { Write-Progress -Activity "Copying Files" -Completed }
  }
  return
}
Set-Alias -Name cfp -Value Copy-FolderWithProgress -Description 'copy folder w progress' -ea 0

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

# gme - Function to open edge and goto online git-repo
function Open-GitOnline { Start-Process "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe" -ArgumentList $gitOnline }
Set-Alias -Name gme -Value Open-GitOnline -Description 'gme - open online git repo' -ea 0

##### Linux style functions (written like a tux :-)) #####

# awk - Function to process a pattern with an action in a file
function Select-PatternReplace ([string]$p, [string]$a, [string]$f) {
  if (!(Test-Path $f)) { Write-Error "File not found: $f"; return }
  $c = gc $f; foreach ($l in $c) { if ($l -match $p) { iex ($a -replace '\$', '$l') } }
}
Set-Alias -Name awk -Value Select-PatternReplace -Description 'awk - process $pattern with $action in $file' -ea 0

# grep - Function to find a pattern in the input
function Find-Pattern ([string]$p, [string]$i, [switch]$r) {
  if (!(Test-Path $i)) { Write-Error "Input path not found: $i"; return }; $item = gi $i; 
  if ($item -is [System.IO.FileInfo]) { cat $i | sls $p | % { "$($i):$($_.LineNumber): $_" } } 
  elseif ($item -is [System.IO.DirectoryInfo]) { gi $i -File -Recurse:$r | % { cat $_.FullName | sls $p | % { "$($_.Path):$($_.LineNumber): $_" } } } 
  else { Write-Error "Unsupported input type: $i" } 
}
Set-Alias -Name grep -Value Find-Pattern -Description 'grep - find $pattern from $input' -ea 0

# sed - Function to replace a pattern in a file
function Set-Pattern ([string]$f, [string]$p, [string]$r) {
  if (!(Test-Path $f)) { Write-Error "File not found: $f"; return }
  (gc $f) -replace $p, $r | sc $f
}
Set-Alias -Name sed -Value Set-Pattern -Description 'sed - replace $pattern in $file with $replace' -ea 0

# touch - Function to create a new file if it does not exist
function New-File ($f) { if (!(Test-Path $f)) { ni -Path $f -ItemType File -Force } }
Set-Alias -Name touch -Value New-File -Description 'touch - if not $file, create here' -ea 0

# unzip - Function to expand a zip file to a folder
function Expand-ZipToFolder ([string]$zf, [string]$zfd) {
  if (!$zfd) { $zi = gi $zf; $zfd = ni -Path "$($PWD.Path)\$($zi.BaseName)" -ItemType Directory -Force }
  else { $zfd = ni -Path $zfd -ItemType Directory -Force }; Expand-Archive -Path $zf -DestinationPath $zfd -Verbose 
}
Set-Alias -Name unzip -Value Expand-ZipToFolder -Description 'unzip - $zipFile to $zipFolder' -ea 0

##### Azure Functions ##### 
# myaz - Function to use az cli to connect to tenant
function Connect-Azure { az login -t $myAzTenant }
Set-Alias -Name myaz -Value Connect-Azure -Description 'use az cli to connect to tenant' -ea 0

# jumpwin - Function to SSH Windows vm jumpbox
function Connect-JumpWin { ssh "$jumpAdmin@$jumpWin" -i $winSshKey }
Set-Alias -Name jumpwin -Value Connect-JumpWin -Description 'ssh az jumpwin vm' -ea 0

<# jumpwin - Function to RDP Windows vm jumpbox
function Connect-JumpWin { Start-Process "$env:SystemRoot\system32\mstsc.exe" -ArgumentList "/v:$jumpWin" }
Set-Alias -Name jumpwin -Value Connect-JumpWin -Description 'rdp az jumpwin vm' -ea 0#>

# jumplin - Function to SSH Linux vm jumpbox
function Connect-JumpLin { ssh "$jumpAdmin@$jumpLin" -i $linSshKey }
Set-Alias -Name jumplin -Value Connect-JumpLin -Description 'ssh az jumplin vm' -ea 0

##########  EXECUTION  ##########
# Fun phrase to display 
Write-Host "`nReticulating Splines..." -ForegroundColor Yellow

# Set prompt user@device + pwd (truncated)
function prompt { 
    "$(Write-Host "$(($env:USERNAME).ToLower())@$(($env:COMPUTERNAME).ToLower()) " -ForegroundColor Green -nonewline)" + `
    "$(Write-Host $("{0}\$([char]0x221E)\{1}>" -f (Split-Path -Qualifier (Get-Location)), (Split-Path -Leaf (Get-Location))) -nonewline)"
}

# Set the console title 
$amIAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$Host.UI.RawUI.WindowTitle = if ($amIAdmin) { "Administrator: $whoIsMe" } else { "$whoIsMe" }

if (!(($env:TERM_PROGRAM -eq "vscode") -or ($env:PSModulePath -eq "WarpTerminal"))) { 
  # Display aliases and paths for quick reference
  (Get-Alias | Where-Object { $_.Description } | Format-Table Name, Definition, Description -AutoSize -HideTableHeaders | Out-String).trim()
  # Who am I? & am I running as admin?
  Write-Host "`nWho am I?" -ForegroundColor Yellow
  Write-Host "    $whoIsMe" -ForegroundColor Green
  Write-Host "    Running as admin?... $($amIAdmin)" 
  # Is my stuff here?
  Write-Host "`nWhere is my stuff?" -ForegroundColor Yellow
  Write-Host "    $(Test-Path $workFldr)... $workFldr"
  Write-Host "    $(Test-Path $gitRepos)... $gitRepos"
  Write-Host "    $(Test-Path $poShProfile.FullName)... $($poShProfile.FullName)"
  # Go to work folder
  Find-Work 
}

###########################################
##### $PROFILE | Format-List * -Force #####
###########################################

###########################################
#### More functions than really needed ####
###########################################
function Compare-DnsResolution ([string]$DomainName) {
    # Local DNS resolution
    try { $localResult = Resolve-DnsName $DomainName; Write-Host "Local DNS Resolution for $($DomainName): $($localResult.IPAddress.split(' '))" }
    catch { Write-Host "Local DNS Resolution Failed for $DomainName" }
    # DNS resolution using external servers
    $dnsServers = @("1.1.1.1", "8.8.8.8")
    foreach ($server in $dnsServers) {
        try { $externalResult = Resolve-DnsName $DomainName -Server $server; Write-Host "DNS Resolution using $($server) for $($DomainName): $($externalResult.IPAddress.split(' '))" } 
        catch { Write-Host "DNS Resolution Failed using server $server for $DomainName" }
    }
}
Set-Alias -Name dnschk -Value Compare-DnsResolution -Description 'check dhcp dns vs nslookup' -ea 0
