function Create-JMModule {
    [cmdletbinding()]

    param(
        [parameter(Mandatory)][string]$ModuleName,
        [parameter(Mandatory)][string]$PlasterPath,
        [parameter(Mandatory)][string]$Description,
        [parameter(Mandatory)][string]$AuthorName,
        [Parameter(Mandatory)]
        [string]
        $AuthorEmail,
        [parameter()][string[]]$ModuleFolders,
        [parameter()][switch]$GitHub
    )

    if ([string]::IsNullOrEmpty($GitHub)) {
        #NoGH
        $gh = "No"
    }
    else {
        #Prep new Module Git Repo

        if (test-path $env:userprofile\$ModuleName) {
            if (test-path $env:userprofile\$modulename\.git\) {
                #git already initialized

            }
            else {
                cd $env:userprofile\$modulename
                git init
            }
        }
        else {
            cd $env:userprofile

            md $modulename

            cd $ModuleName

            git init

            git add .

            git commit -m "Creating $moduleName - first commit"
        }

        #Clone repo to local Path $localModPath

        $gh = "Yes"
    }

    if (test-path "C:\Powershell\") {
        if (test-path "C:\Powershell\PlasterTemplate") {
            $PlasterPath = "C:\PowerShell\PlasterTemplate"
        }
        else {
            cd C:\Powershell

            git clone https://github.com/derekschauland/PlasterTemplate.git
        }

    }
    else {
        md "C:\PowerShell\"

        cd C:\Powershell

        git clone https://github.com/derekschauland/PlasterTemplate.git
    }

    $PlasterParams = @{
        TemplatePath      = $PlasterPath #"C:\Powershell\PlasterTemplate"
        DestinationPath   = "$localModPath" #If using GitHub - create a repo there first and clone it locally - enter that path here
        AuthorName        = "$AuthorName"
        AuthorEmail       = "$AuthorEmail"
        ModuleName        = "$ModuleName" #Edit this to add the name of the new Module
        ModuleDescription = "$Description" #Edit this to add a description to your new Module
        ModuleVersion     = "0.1"
        ModuleFolders     = $ModuleFolders
        GitHub            = "$gh" #Yes to use Github - the default or No to not use GH
        License           = "Yes"
    }

    invoke-plaster @PlasterParams

}
