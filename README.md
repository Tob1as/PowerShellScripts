# PowerShell Scripte

* Hyper-V_deployVMs.ps1 ist zum Clonen (Kopieren) einer Hyper-V VM. 
	* Das Script mit dem Programm "Powershell ISE" als Administrator aufrufen (rechte Maustaste->Als Admin ausführen), das Script öffnen und mit F5 oder der Play-Taste ausführen. Das Script fragt nach einer zweistelligen Nummer, am besten im Hyper-V-Manager schauen welche noch frei ist (letzte Teil des VM-Namens). Anschließend kopiert das Script die Festplatte (VHD) des Master-Images und erstellt eine VM mit den im Script eingestellten Werten. (2CPUs, dynamischer Ram 1-4GB, der VHD, statischer MAC-Adresse für IPs, usw.)
	* Die VM z.B. Ubuntu, welche kopiert werden soll muss vorher angepasst werden: https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/Supported-Ubuntu-virtual-machines-on-Hyper-V oder auch https://decatec.de/home-server/ubuntu-server-als-hyper-v-gastsystem-installieren-und-optimal-einrichten/ 
