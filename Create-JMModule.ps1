
function Get-DSCallingFunction {
    <#
	.SYNOPSIS
		Get-DSCallingFunction is used to collect the name of the function that called it

	.DESCRIPTION
		Get-DSCallingFunction is used to collect the name of the function that called it. This is used when generating logfile names for some functions

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
    $callStack = Get-PSCallStack
    If ($callStack.Count -gt 1) {
        '{0}' -f $callStack[1].FunctionName
    }
}

Function Start-DSLogging {
    If (-not (Get-Module pslogging)) {
        If (Get-Module -ListAvailable | Where-Object { $_.Name -eq "pslogging" }) {
            Import-Module pslogging
            Write-Verbose "PSLogging has been imported and is ready for use"
        }
        Else {
            Find-Module pslogging | Install-Module
        }
    }
    Else {
        Write-verbose "Good News! PSLogging is loaded"
    }

    #specify main function of this module for easier logging purposes
    $global:functioncall = "Create-JMModule"
    $callingfunction = $global:functioncall
    #$callingfunction

    $loglocation = "$env:USERPROFILE\logs\"

    If (!(Test-Path $loglocation)) {
        New-Item -Path $env:USERPROFILE -Name "logs" -ItemType "directory"
    }


    $global:logdate = (get-date -Format "yyyy-MM-dd hh-mm-ss")
    $logname = $callingfunction + "_" + $global:logdate + ".log"

    $scriptversion = "1"

    $global:logpath = $loglocation + $logname

    #$logname = $logname.Substring(0,$logname.IndexOf(' '))

    Start-Log -LogPath $loglocation -LogName $logname -ScriptVersion $scriptversion



}

Function get-linenumber {
    $MyInvocation.ScriptLineNumber -1
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
        [Parameter()][string]$CompanyName = "Jewelers Mutual Insurance Group",
        [parameter(HelpMessage = "Only functions, internal, classes, and resources are valid folders.")]
        [ValidateSet("functions","internal","classes","resources")][string[]]$ModuleFolders,
        [parameter()][switch]$GitHub,
        [parameter()][string]$remoteGitUri
    )

    BEGIN {
        Start-DSLogging

    }
    Process {
        If (test-path "C:\Powershell\") {
            If (test-path "C:\Powershell\PlasterTemplate") {
                $PlasterPath = "C:\PowerShell\PlasterTemplate"
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)][Line $(get-linenumber )] Set path to Plaster Template - C:\powershell\PlasterTemplate "

            }
            Else {
                Set-Location C:\Powershell
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Change to PowerShell Directory - c:\PowerShell "

                git clone https://github.com/derekschauland/PlasterTemplate.git
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Clone the PlasterTemplate Git Repo to local for use - https://github.com/derekschauland/PlasterTemplate.git"

            }

        }
        Else {
            mkdir "C:\PowerShell\"
            Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Made c:\powershell directory "

            Set-Location C:\Powershell
            Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Change to c:\powershell directory "

            git clone https://github.com/derekschauland/PlasterTemplate.git
            Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Clone PlasterTemplate to local - https://github.com/derekschauland/PlasterTemplate.git "

        }

        If ([string]::IsNullOrEmpty($GitHub)) {
            #NoGH
            $gh = "No"
        }
        Else {
            #Prep new Module Git Repo

            If (test-path $env:userprofile\modules\$ModuleName) {
                If (test-path $env:userprofile\modules\$modulename\.git\) {
                    #git already initialized

                }
                Else {
                    Set-Location $env:userprofile\modules\$modulename
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Change to folder for the new Module $("$env:USERPROFILE\modules\$ModuleName") "

                    git init
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Initialize directory for git "
                    $localModPath = "$($env:userprofile)\modules\$($modulename)"
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Set LocalModPath variable to $localmodpath  "
                }
            }
            Else {
                Set-Location $env:userprofile
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Change Directory to User Profile for logged in user $($env:USERPROFILE) "

                If (test-path $env:userprofile\modules) {
                    Set-Location modules

                    If (test-path $env:userprofile\modules\$modulename) {
                        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Module Directory for $modulename exists"
                        set-location $ModuleName
                    }
                    Else {
                        mkdir $ModuleName
                        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Made directory for new module $ModuleName "

                        Set-Location $ModuleName
                        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Changed to $ModuleName directory "
                        $localModPath = "$($env:userprofile)\modules\$($modulename)"
                        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Set LocalModPath variable to $localmodpath  "
                    }
                }
                Else {

                    mkdir modules
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Create Modules Directory in UserProfile - $($env:USERPROFILE) "

                    Set-Location modules
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Change to modules directory "

                    mkdir $modulename
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Make Directory for $ModuleName in $($env:USERPROFILE)\modules "


                    Set-Location $ModuleName
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Change Directory to $ModuleName  "
                    $localModPath = "$($env:userprofile)\modules\$($modulename)"
                    Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Set LocalModPath variable to $localmodpath  "

                }

                #write-host "Hi Im going to set the modpath next"
                $localModPath = "$($env:userprofile)\modules\$($modulename)"
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Set LocalModPath variable to $localmodpath  "
                #$localmodpath = $pwd.path

                #$localmodpath

                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber  -1) ] Set local module path variable - $($env:USERPROFILE)\modules\$modulename "

                git init
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber )] Intialize $($env:USERPROFILE)\modules\$ModuleName for git "

                git add .
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber  -1 )] Add folder contents of $($env:USERPROFILE)\modules\$ModuleName to Git "

                git commit -m "Creating $moduleName - first commit"
                Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber  -1 )] Create initial commit of $modulename "

            }

            #Clone repo to local Path $localModPath

            $gh = "Yes"
            Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber)] Set gh variable to Yes - this will set Plaster to include git when creating Module "

        }
        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber)] Prepare the PlasterParams for use by splatting "

        $PlasterParams = @{
            TemplatePath      = $PlasterPath #"C:\Powershell\PlasterTemplate"
            DestinationPath   = $localModPath #If using GitHub - create a repo there first and clone it locally - enter that path here
            AuthorName        = "$AuthorName"
            AuthorEmail       = "$AuthorEmail"
            CompanyName       = "$CompanyName"
            ModuleName        = "$ModuleName" #Edit this to add the name of the new Module
            ModuleDescription = "$Description" #Edit this to add a description to your new Module
            ModuleVersion     = "0.1"
            ModuleFolders     = "$ModuleFolders"
            GitHub            = "$gh" #Yes to use Github - the default or No to not use GH
            License           = "Yes"
        }

        invoke-plaster @PlasterParams
        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber)] Run plaster cmdlet with PlasterParams splatted paramters "

        #Remote Push to Github - disabled for now - more learning neded
        # git remote add $ModuleName $remoteGitUri
        # Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] [Line $(get-linenumber -1 )] Add remote to git for module $ModuleName "
    }
    End {
        Write-LogInfo -LogPath $global:logpath -Message "[$env:USERNAME on $([DateTime]::Now)] Function operation Completed"
        Stop-Log -LogPath $global:logpath -NoExit
    }
}