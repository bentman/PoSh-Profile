# PoSh-Profile

This is a base Powershell $PROFILE ... & it is always a "Work-in-Progress". 

It is not "static" and gets customized for each work environment purpose.

## Highlights

- Easy to extend with additional functions and aliases.
- Launches on every machine that is syncing `$env:OneDrive`.
- Includes PowerShell functions to emulate Linux utilities (`grep`, `sed`, `touch`, `unzip`, etc.).

## Use Locations

- Windows Modern PowerShell (`pwsh.exe`): `$env:OneDrive\Docments\PowerShell\profile.ps1`
- Windows PowerShell (`powershell.exe`): `$env:OneDrive\Docments\WindowsPowerShell\profile.ps1`
- Linux Modern PowerShell (`pwsh`): `~/.config/powershell/profile.ps1`
- Helpful command to find appropriate $PROFILE location: `$PROFILE | Format-List * -Force`

### Contributions

Contributions are welcome! Please open an issue or submit a pull request if you have suggestions or enhancements.

### License

This script is distributed without any warranty; use at your own risk.
This project is licensed under the GNU General Public License v3. 
See [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html) for details.
