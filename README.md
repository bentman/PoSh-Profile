# PoSh-Profile

This is a base Powershell $PROFILE ... & it is always a "Work-in-Progress". 

## Highlights

- Easy to extend with additional functions and aliases.
- Launches on every machine that is syncing `$env:OneDrive`.
- This is "dynamic" - customize it for each work environment purpose.
- Includes PowerShell functions to emulate Linux utilities (`grep`, `sed`, `touch`, `unzip`, etc.).

## Use Locations

- Windows PowerShell (Modern `pwsh.exe`): `$env:OneDrive\Docments\PowerShell\profile.ps1`
- Windows PowerShell (Legacy `powershell.exe`): `$env:OneDrive\Docments\WindowsPowerShell\profile.ps1`
- Linux/Mac PowerShell (bash/zsh `pwsh`): `~/.config/powershell/profile.ps1` (...stay tuned for update!)
- Helpful command to find appropriate $PROFILE location: `$PROFILE | Format-List * -Force`

## Contributions
Contributions are welcome. Please open an issue or submit a pull request if you have any suggestions, questions, or would like to contribute to the project.

### GNU General Public License
This script is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this script.  If not, see <https://www.gnu.org/licenses/>.
