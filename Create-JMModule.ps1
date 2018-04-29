<#
	.SYNOPSIS
		A brief description of the Name function.

	.DESCRIPTION
		A detailed description of the Name function.

	.PARAMETER  ParameterA
		The description of a the ParameterA parameter.

	.PARAMETER  ParameterB
		The description of a the ParameterB parameter.

	.EXAMPLE
		PS C:\> Name -ParameterA 'One value' -ParameterB 32
		'This is the output'
		This example shows how to call the Name function with named parameters.

	.EXAMPLE
		PS C:\> Name 'One value' 32
		'This is the output'
		This example shows how to call the Name function with positional parameters.

	.INPUTS
		System.String,System.Int32

	.OUTPUTS
		System.String

	.NOTES
		For more information about advanced functions, call Get-Help with any
		of the topics in the links listed below.

	.LINK
		about_functions_advanced

	.LINK
		about_comment_based_help

	.LINK
		about_functions_advanced_parameters

	.LINK
		about_functions_advanced_methods
#>
function Get-DSCallingFunction {
     
   $callStack = Get-PSCallStack
   If ($callStack.Count -gt 1)
   {
       '{0}' -f $callStack[1].FunctionName
   }        
}

Function Start-DSLogging
{
    If (-not (Get-Module pslogging))
    {
        If (Get-Module -ListAvailable | Where-Object { $_.Name -eq "pslogging" })
        {
            Import-Module pslogging
            Write-Verbose "PSLogging has been imported and is ready for use"
        }
        Else
        {
            Find-Module pslogging | Install-Module
        }
    }
    Else
    {
        Write-verbose "Good News! PSLogging is loaded"
    }
    
    
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

Function Get-Linenumber
{
    $MyInvocation.ScriptLineNumber    
}

function Create-JMModule {
    [cmdletbinding()]

    param(
        [parameter(Mandatory)][string]$ModuleName,
        #[parameter(Mandatory)][string]$PlasterPath,
        [parameter(Mandatory)][string]$Description,
        [parameter(Mandatory)][string]$AuthorName,
        [Parameter(Mandatory)]
        [string]
        $AuthorEmail,
        [parameter()][string[]]$ModuleFolders,
        [parameter()][switch]$GitHub,
        [parameter()][string]$remoteGitUri
    )
    
    BEGIN 
    {
        #make sure the plaster template is available$global:functioncall = (get-callingfunction)
        $global:functioncall = $global:functioncall.substring(0, $global:functioncall.indexof('<'))
        Start-DSLogging
        
    }
    Process
    {
        If (test-path "C:\Powershell\")
        {
            If (test-path "C:\Powershell\PlasterTemplate")
            {
                $PlasterPath = "C:\PowerShell\PlasterTemplate"
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)][Line $(get-linenumber) - 1] Set path to Plaster Template - C:\powershell\PlasterTemplate "
                
            }
            Else
            {
                Set-Location C:\Powershell
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Change to PowerShell Directory - c:\PowerShell "
                
                git clone https://github.com/derekschauland/PlasterTemplate.git
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Clone the PlasterTemplate Git Repo to local for use - https://github.com/derekschauland/PlasterTemplate.git"
                
            }
            
        }
        Else
        {
            mkdir "C:\PowerShell\"
            Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Made c:\powershell directory "
            
            Set-Location C:\Powershell
            Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Change to c:\powershell directory "
            
            git clone https://github.com/derekschauland/PlasterTemplate.git
            Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Clone PlasterTemplate to local - https://github.com/derekschauland/PlasterTemplate.git "
            
        }
        
        If ([string]::IsNullOrEmpty($GitHub))
        {
            #NoGH
            $gh = "No"
        }
        Else
        {
            #Prep new Module Git Repo
            
            If (test-path $env:userprofile\modules\$ModuleName)
            {
                If (test-path $env:userprofile\modules\$modulename\.git\)
                {
                    #git already initialized
                    
                }
                Else
                {
                    Set-Location $env:userprofile\modules\$modulename
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Change to folder for the new Module $("$env:USERPROFILE\modules\$ModuleName") "
                    
                    git init
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Initialize directory for git "
                    
                }
            }
            Else
            {
                Set-Location $env:userprofile
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Change Directory to User Profile for logged in user $($env:USERPROFILE) "
                
                If (test-path $env:userprofile\modules)
                {
                    Set-Location modules
                    
                    If (test-path $env:userprofile\modules\$modulename)
                    {
                        
                    }
                    Else
                    {
                        mkdir $ModuleName
                        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Made directory for new module $ModuleName "
                        
                        Set-Location $ModuleName
                        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Changed to $ModuleName directory "
                        
                    }
                }
                Else
                {
                    
                    mkdir modules
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Create Modules Directory in UserProfile - $($env:USERPROFILE) "
                    
                    Set-Location modules
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Change to modules directory "
                    
                    mkdir $modulename
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Make Directory for $ModuleName in $($env:USERPROFILE)\modules "
                    
                    
                    Set-Location $ModuleName
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Change Directory to $ModuleName  "
                    
                    If (Test-Path "C:\powershell\PlasterTemplate\Helperfunctions")
                    {
                        Copy-Item "C:\powershell\PlasterTemplate\HelperFunctions" -Include *.* "$($env:USERPROFILE)\modules\$ModuleName"    
                    }
                    
                }
                
                $localModPath = "$env:userprofile\modules\$modulename"
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Set local module path variable - $($env:USERPROFILE)\modules\$modulename "
                
                git init
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Intialize $($env:USERPROFILE)\modules\$ModuleName for git "
                
                git add .
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Add folder contents of $($env:USERPROFILE)\modules\$ModuleName to Git "
                
                git commit -m "Creating $moduleName - first commit"
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Create initial commit of $modulename "
                
            }
            
            #Clone repo to local Path $localModPath
            
            $gh = "Yes"
            Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Set gh variable to Yes - this will set Plaster to include git when creating Module "
            
        }
        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber)] Prepare the PlasterParams for use by splatting "
        
        $PlasterParams = @{
            TemplatePath       = $PlasterPath #"C:\Powershell\PlasterTemplate"
            DestinationPath    = "$localModPath" #If using GitHub - create a repo there first and clone it locally - enter that path here
            AuthorName         = "$AuthorName"
            AuthorEmail        = "$AuthorEmail"
            ModuleName         = "$ModuleName" #Edit this to add the name of the new Module
            ModuleDescription  = "$Description" #Edit this to add a description to your new Module
            ModuleVersion      = "0.1"
            ModuleFolders      = "$ModuleFolders"
            GitHub             = "$gh" #Yes to use Github - the default or No to not use GH
            License            = "Yes"
        }
        
        invoke-plaster @PlasterParams
        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Run plaster cmdlet with PlasterParams splatted paramters "
        
        git remote add $ModuleName $remoteGitUri
        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber) - 1] Add remote to git for module $ModuleName "
    }
    End
    {
        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] Function operation Completed"
        Stop-Log -LogPath $global:logpath -NoExit    
    }
}