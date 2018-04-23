<# 
    This script checks the online connection every $waittime seconds
    with a ping to $HOSTS and attempts to re-login if ping fails
    
    Dependency: login.ps1
#>



$waittime = 30   # insert time to wait between checks here
$countpings = 4  # insert the number of ping attempts

$HOSTS = @("134.93.178.2","google.de") #uni-mainz.de&google.d	# add ip / hostname separated by comma and quote mark



while($true)
{
    Write-Host "Check start at $(Get-Date -Format 'd.M.yyyy HH:mm:ss')"

    $fail = 0
    $fail_percent = 100

    for ($i=0; $i -lt $HOSTS.length; $i++){
        $pingStatus = Test-Connection $HOSTS[$i] -Count $countpings -Quiet -ErrorAction SilentlyContinue
        if (-not $pingStatus){
            Write-Host "Host : $($HOSTS[$i]) is not available (ping failed) at $(Get-Date -Format 'd.M.yyyy HH:mm:ss')" -ForegroundColor "Red"
            $fail+=1
	    } else {
	        Write-Host "Host : $($HOSTS[$i]) is available (ping successful) at $(Get-Date -Format 'd.M.yyyy HH:mm:ss')" -ForegroundColor "Green"
            $fail+=0
	    }
    }

    # login again, when more then 50% pings to hosts failed
    $fail_percent = ($fail/$HOSTS.length)*100
    Write-Host $("{0:N2}% ping failed" -f $fail_percent) -ForegroundColor "Gray"
    if ($fail_percent -gt 50){
        Write-Host "Logging in... at $(Get-Date -Format 'd.M.yyyy HH:mm:ss')"
        #&"$PSScriptRoot\login_wohnheim_uni_mainz_de.ps1"
        Invoke-Expression -Command "$PSScriptRoot\login_wohnheim_uni_mainz_de.ps1 -cmd login"
    }

    Start-Sleep -Seconds $waittime

}