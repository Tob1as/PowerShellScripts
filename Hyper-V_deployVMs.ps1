<#
    Hyper-V
    deploy virtual machines (VMs)

    Version: 1.0
    Author: Tobias Hargesheimer
    Creation Date: 10.04.2018
#>


# Variables
$virtual_hard_disks_path = "D:\Hyper-V\Virtual Hard Disks\"
$virtual_hard_disk_file_extension = ".vhdx"
$vm_masterimage = "srv-vm-ubuntu-master"
$vm_prefix = "srv-vm-"
$vm_number = ""
$check_input = "false"

$vm_network_switch_name = "VMs-NetworkSwitch"
$vm_MacAddress = "00:15:5D:1B:15:"
$vm_IpAddress = "10.153.32."
$vm_cpu_count = 2
$vm_MemoryMinimumBytes = 1024MB
$vm_MemoryMaximumBytes = 4096MB

$script_close_time = 5

# check user is admin for hyper-v
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Sie besitzen keine Rechte zum Ausführen des Scripts.`nBitte führen Sie das Script in 'Powershell ISE' als Administrator aus!"
    Start-Sleep -Seconds $script_close_time
    exit
}

# User input
$vm_number = Read-Host -Prompt 'Geben Sie eine nicht verwendete zweistellige Nummer zwischen 00 und 99 für die VM ein'
Write-Host " "

# Check input contain two letters and only numbers
if($vm_number.length -eq 2 -and $vm_number -match "[0-9]"){
    $check_input = "true"
} else {
    $check_input = "false"
    Write-Host "Fehler in Eingabe!" -ForegroundColor "Red"
    Start-Sleep -Seconds $script_close_time
    exit
}

# do something
if ($check_input -eq "true"){

    # Check virtual_hard_disk of new vm not exist 
    if(-not (Test-Path "${virtual_hard_disks_path}${vm_prefix}${vm_number}${virtual_hard_disk_file_extension}")){
        # Copy virtual_hard_disk
        Write-Host "* Festplatte wird nach ${virtual_hard_disks_path}${vm_prefix}${vm_number}${virtual_hard_disk_file_extension} kopiert ..."
        Copy-Item -path "${virtual_hard_disks_path}${vm_masterimage}${virtual_hard_disk_file_extension}" -destination "${virtual_hard_disks_path}${vm_prefix}${vm_number}${virtual_hard_disk_file_extension}"
        #New-VHD -ParentPath "${virtual_hard_disks_path}${vm_masterimage}${virtual_hard_disk_file_extension}" -Path "${virtual_hard_disks_path}${vm_prefix}${vm_number}${virtual_hard_disk_file_extension}" -Differencing
    } else {
        Write-Host "Die virtuelle Festplatte ${vm_prefix}${vm_number}${virtual_hard_disk_file_extension} existiert bereits!" -ForegroundColor "RED"
        #exit
    }

    # Check new vm not exist
    $vm_exists = get-vm -name ${vm_prefix}${vm_number} -ErrorAction SilentlyContinue
    if(-not $vm_exists) {
        # Create VM with this virtual_hard_disk
        # https://docs.microsoft.com/en-us/powershell/module/hyper-v/?view=win10-ps
        Write-Host " "
        Write-Host "* VM ${vm_prefix}${vm_number} wird mit ${vm_MemoryMaximumBytes} Byte RAM und Netzwerk-Switch ${vm_network_switch_name} erstellt ..."
        New-VM -Name "${vm_prefix}${vm_number}" -MemoryStartupBytes $vm_MemoryMaximumBytes -SwitchName "${vm_network_switch_name}" -Generation 2 -NoVHD
        Write-Host "* die kopierte Festplatte ${vm_prefix}${vm_number}${virtual_hard_disk_file_extension} wird hinzugefügt ..."
        Add-VMHardDiskDrive -VMName "${vm_prefix}${vm_number}" -Path "${virtual_hard_disks_path}${vm_prefix}${vm_number}${virtual_hard_disk_file_extension}"
        Write-Host "* der VM werden ${vm_cpu_count} CPUs zugewiesen ..."
        Set-VMProcessor -VMName "${vm_prefix}${vm_number}" -Count $vm_cpu_count
        Write-Host "* der Arbeitsspeicher wird auf dynamisch von $vm_MemoryMinimumBytes bis $vm_MemoryMaximumBytes Byte RAM eingestellt ..."
        Set-VMMemory -VMName "${vm_prefix}${vm_number}" -DynamicMemoryEnabled $true -MinimumBytes $vm_MemoryMinimumBytes -MaximumBytes $vm_MemoryMaximumBytes
        Write-Host "* der MAC-Adresse wird auf Statisch gestellt (${vm_MacAddress}${vm_number}, IP: ${vm_IpAddress}${vm_number}) ..."
        Set-VMNetworkAdapter -VMName "${vm_prefix}${vm_number}" -StaticMacAddress "${vm_MacAddress}${vm_number}"
        Write-Host "* Firmwareeinstellungen (SecureBoot usw.) werden vorgenommen ..."
        Set-VMFirmware -VMName "${vm_prefix}${vm_number}" -EnableSecureBoot On -SecureBootTemplate "MicrosoftUEFICertificateAuthority" 
        Set-VMFirmware -VMName "${vm_prefix}${vm_number}" -FirstBootDevice $(Get-VMHardDiskDrive -VMName "${vm_prefix}${vm_number}")
        #Write-Host "* VM ${vm_prefix}${vm_number} wird gestartet ..."
        #Start-VM "${vm_prefix}${vm_number}"

        # Final
        Write-Host " "
        Write-Host "Die VM ${vm_prefix}${vm_number} wurde erstellt!" -ForegroundColor "Green"
        Write-Host " "
    } else {
        Write-Host "Die VM ${vm_prefix}${vm_number} existiert bereits!" -ForegroundColor "Red"
        #exit
    }

    Start-Sleep -Seconds $script_close_time
}