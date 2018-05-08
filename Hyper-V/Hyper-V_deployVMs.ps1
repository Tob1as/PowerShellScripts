<#
    Hyper-V
    deploy more than one virtual machines (VMs)

    Version: 2.0
    Author: Tobias Hargesheimer
    Creation Date: 07.05.2018 | Last Change: 08.05.2018
#>

# Variables
[Int]$vm_number_max = 99

# Variables - do not change
[String]$vm_prefix = $null
[Int]$script_close_time = $null
[Int]$count_vm_create = 0
[Int]$vm_number = 1 # 0 is master, begin with 1
[String]$vm_name = ""
[String]$vm_number_asString = ""
[bool]$check_input = $false

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
    $vm_prefix = $($values.vm_prefix)
    $script_close_time = $($values.script_close_time)
} else {
    Write-Host "Config File not found!" -ForegroundColor "Red"
    Start-Sleep -Seconds 5
    exit
}

# User input
$count_input = Read-Host -Prompt 'Geben Sie die gewünschte Anzahl an VMs an'

# Check input contain only numbers
if($count_input -match "^[0-9\s]+$"){
    $check_input = $true
} else {
    $check_input = $false
    Write-Host "Fehler in Eingabe!" -ForegroundColor "Red"
    Start-Sleep -Seconds $script_close_time
    exit
}


# create some VM
if ($check_input -eq $true){
    do {
        
        # add sign or not
        if("${vm_number}".length -eq 1 -and $vm_number -is [int]){
            $vm_number_asString = "0${vm_number}"
        } else {
            $vm_number_asString = $vm_number
        }

        # Check new vm not exist
        $vm_name = "${vm_prefix}${vm_number_asString}"
        $vm_exists = get-vm -name $vm_name -ErrorAction SilentlyContinue | select -expand Name
        if(-not $vm_exists) {
            Write-Host "Create VM $vm_name ..."
            Invoke-Expression -Command "$PSScriptRoot\Hyper-V_copyVM.ps1 -number ${vm_number_asString} -sct 0"
            $count_vm_create++
        }
        $vm_number++
    } while ($count_vm_create -lt $count_input -or $vm_number -gt $vm_number_max)

    Start-Sleep -Seconds $script_close_time
}