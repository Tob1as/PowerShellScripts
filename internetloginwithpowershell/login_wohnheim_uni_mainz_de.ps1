<# 
    This script provides login- and logout-functionality
    for the dormitory network of the Johannes-Gutenberg-University Mainz
    and Studierendenwerk Mainz.
    
    Dependency: -
#>

 param (
    [String]$cmd = "none",
    [String]$configtype = "file"
 )

function delsign([String] $givenVariable){
    # delete ' sign at start and end of the string, if only one exist delete no because it could belong to the password
    if ($givenVariable.StartsWith("'") -and $givenVariable.EndsWith("'")){
         $givenVariable = $givenVariable.TrimStart("'").TrimEnd("'")
    }
    return $givenVariable
}

if ($configtype -eq "file" -and (Test-Path "$PSScriptRoot\login_config.cfg")) {
    $Path = "$PSScriptRoot\login_config.cfg"
    $values = Get-Content $Path | Out-String | ConvertFrom-StringData
    $username = $(delsign($values.ZDV_USERNAME))
    $password = $(delsign($values.ZDV_PASSWORD))
} elseif ($cmd -eq "logout") {
    # do nothing
} else {
    $username = $(Read-Host "Input Username")
    $password = $(Read-Host -assecurestring "Input Password")
    $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
}

function login(){
    Write-Host "Logging in with $username..."
    $postParams = @{user=$username;pass=$password}
    Invoke-WebRequest -Uri 'https://login.wohnheim.uni-mainz.de/cgi-bin/login-cgi' -Method POST -Body $postParams
}

function logout() {
    Write-Host "Logging out..."
    $postParams = @{command='logout'}
    Invoke-WebRequest -Uri 'https://login.wohnheim.uni-mainz.de/cgi-bin/logout.cgi' -Method POST -Body $postParams
}

switch ( $cmd ) {
    'reconnect' { logout | login }
    'logout' { logout }
    'login' { login }
    default { Write-Host "Usage: .\login_wohnheim_uni_mainz_de.ps1 -cmd login|logout|reconnect -configtype file|none"  -ForegroundColor "DarkYellow" }
}

#Start-Sleep -Seconds 30
