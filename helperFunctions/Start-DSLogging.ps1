Function Start-DSLogging
{
    #    If (-not (Get-Module pslogging))
    #    {
    #        If (Get-Module -ListAvailable | Where-Object { $_.Name -eq "pslogging" })
    #        {
    #            Import-Module pslogging
    #            Write-Verbose "PSLogging has been imported and is ready for use"
    #        }
    #        Else
    #        {
    #            Find-Module pslogging | Install-Module
    #        }
    #    }
    #    Else
    #    {
    #        Write-verbose "Good News! PSLogging is loaded"
    #    }
    
    
    $callingfunction = $global:functioncall
    #$callingfunction
    
    $loglocation = "$env:USERPROFILE\logs\"
    
    If (!(Test-Path $loglocation))
    {
        New-Item -Path $env:USERPROFILE -Name "logs" -ItemType "directory"
    }
    
    
    $global:logdate = (get-date -Format "yyyy-MM-dd hh-mm-ss")
    $logname = $callingfunction + "_" + $global:logdate + ".log"
    
    $scriptversion = "1"
    
    $global:logpath = $loglocation + $logname
    
    #$logname = $logname.Substring(0,$logname.IndexOf(' '))
    
    Start-Log -LogPath $loglocation -LogName $logname -ScriptVersion $scriptversion
    
    
    If ($global:functioncall -contains "script")
    {
        If (Test-Path $global:functioncall)
        {
            $global:scriptpath = $loglocation + $global:functioncall.substring(0, $global:functioncall.indexof('_'))
        }
    }
}