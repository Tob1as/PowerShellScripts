# internetloginwithpowershell
Internet-Login/Logout for Windows with PowerShell for dormitory network of the Johannes-Gutenberg-University Mainz and Studierendenwerk Mainz.

* login_config.cfg - configuration file
* login_wohnheim_uni_mainz_de.ps1 - Login and Logout script!
* networkmonitoring.ps1 - checked if the device is logged in. If not, it will be logged in with the login script.

Use:
* ``` git clone https://github.com/Tob1as/PowerShellScripts.git ```
* Edit ``` login_config.cfg ``` - File and enter your credentials (username and password).
* Login
	* manually: ``` .\login_wohnheim_uni_mainz_de.ps1 -cmd login ``` 
	* automatically, when not logged in: ``` .\networkmonitoring.ps1 ```  (or Link in Autostart)

Note:
* This script is successful tested with *Windows Server 2012 R2* with PowerShell 4.0 and *Windows Server 2016*. For Windows 10 see [MS Docs](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-6) about execution policies and [windowspro.de: PowerShell (signieren und) ausführen](https://www.windowspro.de/andreas-kroschel/powershell-executionpolicy-setzen-scripts-signieren-und-ausfuehren). 
* other Mirror: [GitLab.RLP.net](https://gitlab.rlp.net/stwmz-nags/internetloginwithpowershell)
* or for Linux: [Click](https://github.com/Tob1as/internetloginwithwget)
