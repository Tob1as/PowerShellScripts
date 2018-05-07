<#
    Hyper-V
    copy virtual machines (VMs)

    Version: 1.1
    Author: Tobias Hargesheimer
    Creation Date: 10.04.2018 | Last Change: 07.05.2018
#>

param (
    [String]$number = $null, # VM Number
    [Int]$sct = 5 # script_close_time
)

# Variables - do not change
[String]$virtual_hard_disks_path = $null
[String]$virtual_hard_disk_file_extension = $null
[String]$vm_masterimage = $null
[String]$vm_prefix = $null
[String]$vm_network_switch_name = $null
[String]$vm_MacAddress = $null
[String]$vm_IpAddress = $null
[Int]$vm_cpu_count = $null
[Int64]$vm_MemoryMinimumBytes = $null
[Int64]$vm_MemoryMaximumBytes = $null
[Int]$script_close_time = $null
[bool]$check_input = $false
[String]$vm_number = ""
[String]$vm_name = ""


# check user is admin for hyper-v
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Sie besitzen keine Rechte zum Ausführen des Scripts.`nBitte führen Sie das Script in 'Powershell ISE' als Administrator aus!"
    Start-Sleep -Seconds 5
    exit
}

# read config file
if (Test-Path "$PSScriptRoot\vmcopy.ini") {
    $Path = "$PSScriptRoot\vmcopy.ini"
    $values = Get-Content $Path | Out-String | ConvertFrom-StringData 
    $virtual_hard_disks_path = $($values.virtual_hard_disks_path)
    $virtual_hard_disk_file_extension = $($values.virtual_hard_disk_file_extension)
    $vm_masterimage = $($values.vm_masterimage)
    $vm_prefix = $($values.vm_prefix)
    $vm_network_switch_name = $($values.vm_network_switch_name)
    $vm_MacAddress = $($values.vm_MacAddress)
    $vm_IpAddress = $($values.vm_IpAddress)
    $vm_cpu_count = $($values.vm_cpu_count)
    $vm_MemoryMinimumBytes = [int64]$($values.vm_MemoryMinimumBytes).Replace('MB','') * 1MB # not nice but work
    $vm_MemoryMaximumBytes = [int64]$($values.vm_MemoryMaximumBytes).Replace('MB','') * 1MB # not nice but work
    $script_close_time = $($values.script_close_time)
} else {
    Write-Host "Config File not found!" -ForegroundColor "Red"
    Start-Sleep -Seconds 5
    exit
}

# user input
if([string]::IsNullOrEmpty($number)){
    $vm_number = Read-Host -Prompt 'Geben Sie eine nicht verwendete zweistellige Nummer zwischen 00 und 99 für die VM ein'
    Write-Host " "
} else {
    $script_close_time = $sct
    $vm_number = $number
}

# Check input contain two letters and only numbers
if($vm_number.length -eq 2 -and $vm_number -match "^[0-9\s]+$"){
    $check_input = $true
    $vm_name = "${vm_prefix}${vm_number}"
    } else {
    $check_input = $false
    Write-Host "Fehler in Eingabe!" -ForegroundColor "Red"
    Start-Sleep -Seconds $script_close_time
    exit
}


# copy vhd and create vm
if ($check_input -eq $true){

    # Check virtual_hard_disk of new vm not exist 
    if(-not (Test-Path "${virtual_hard_disks_path}${vm_name}${virtual_hard_disk_file_extension}")){
        # Copy virtual_hard_disk
        Write-Host "* Festplatte wird nach ${virtual_hard_disks_path}${vm_name}${virtual_hard_disk_file_extension} kopiert ..."
        Copy-Item -path "${virtual_hard_disks_path}${vm_masterimage}${virtual_hard_disk_file_extension}" -destination "${virtual_hard_disks_path}${vm_name}${virtual_hard_disk_file_extension}"
        #New-VHD -ParentPath "${virtual_hard_disks_path}${vm_masterimage}${virtual_hard_disk_file_extension}" -Path "${virtual_hard_disks_path}${vm_name}${virtual_hard_disk_file_extension}" -Differencing
    } else {
        Write-Host "Die virtuelle Festplatte ${vm_name}${virtual_hard_disk_file_extension} existiert bereits!" -ForegroundColor "RED"
        #exit
    }

    # Check new vm if not exist
    $vm_exists = get-vm -name ${vm_name} -ErrorAction SilentlyContinue | select -expand Name
    if(-not $vm_exists) {
        # Create VM with this virtual_hard_disk
        # https://docs.microsoft.com/en-us/powershell/module/hyper-v/?view=win10-ps
        Write-Host " "
        Write-Host "* VM ${vm_name} wird mit ${vm_MemoryMaximumBytes} Byte RAM und Netzwerk-Switch ${vm_network_switch_name} erstellt ..."
        New-VM -Name "${vm_name}" -MemoryStartupBytes $vm_MemoryMaximumBytes -SwitchName "${vm_network_switch_name}" -Generation 2 -NoVHD
        Write-Host "* die kopierte Festplatte ${vm_name}${virtual_hard_disk_file_extension} wird hinzugefügt ..."
        Add-VMHardDiskDrive -VMName "${vm_name}" -Path "${virtual_hard_disks_path}${vm_name}${virtual_hard_disk_file_extension}"
        Write-Host "* der VM werden ${vm_cpu_count} CPUs zugewiesen ..."
        Set-VMProcessor -VMName "${vm_name}" -Count $vm_cpu_count
        Write-Host "* der Arbeitsspeicher wird auf dynamisch von $vm_MemoryMinimumBytes bis $vm_MemoryMaximumBytes Byte RAM eingestellt ..."
        Set-VMMemory -VMName "${vm_name}" -DynamicMemoryEnabled $true -MinimumBytes $vm_MemoryMinimumBytes -MaximumBytes $vm_MemoryMaximumBytes
        Write-Host "* der MAC-Adresse wird auf Statisch gestellt (${vm_MacAddress}${vm_number}, IP: ${vm_IpAddress}${vm_number}) ..."
        Set-VMNetworkAdapter -VMName "${vm_name}" -StaticMacAddress "${vm_MacAddress}${vm_number}"
        Write-Host "* Firmwareeinstellungen (SecureBoot usw.) werden vorgenommen ..."
        Set-VMFirmware -VMName "${vm_name}" -EnableSecureBoot On -SecureBootTemplate "MicrosoftUEFICertificateAuthority" 
        Set-VMFirmware -VMName "${vm_name}" -FirstBootDevice $(Get-VMHardDiskDrive -VMName "${vm_name}")
        #Write-Host "* VM ${vm_name} wird gestartet ..."
        #Start-VM "${vm_name}"

        # Final
        Write-Host "`nDie VM ${vm_name} wurde erstellt!`n" -ForegroundColor "Green"
    } else {
        Write-Host "Die VM ${vm_name} existiert bereits!" -ForegroundColor "Red"
        #exit
    }

    Start-Sleep -Seconds $script_close_time
}