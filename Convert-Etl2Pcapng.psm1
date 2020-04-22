# Convert-Etl2Pcapng Module

<# TO-DO: 

- Add Manual setting for environments where the module cannot reach the internet
- Add proxy details to settings and update script so it works with a proxy. Possibly create/update a cmdlet to add those settings.

#>


# FUNCTION : Register-Etl2Pcapng
# PURPOSE  : Registers the ecript to ETL files  
function Register-Etl2Pcapng 
{
    <#
    .SYNOPSIS
        Adds a right-click menu option in Windows for etl2pcapng.
    .DESCRIPTION
        Registers a shell context menu item for Convert-Etl2Pcapng. Right-clicking on an ETL fill will show an option "Convert with etl2pcapng". This will execute Convert-Etl2Pcapng with default settings against the ETL file.
    .EXAMPLE
        Register-Etl2Pcapng

        Registers the "Convert with etl2pcapng" shell menu item.
    .NOTES
        Author: Microsoft Edge OS Networking Team and Microsoft CSS
        Please file issues on GitHub @ https://github.com/microsoft/Convert-Etl2Pcapng
    .LINK
        More projects               : https://github.com/topics/msftnet
        Windows Networking Blog     : https://blogs.technet.microsoft.com/networking/
    #>

    [CmdletBinding()]
    param (
        # Causes the explorer menu option, "Convert with etl2pcapng", to not exit the command prompt when complete and output Verbose logging.
        [switch]$UseVerbose,
        # Causes the explorer menu option, "Convert with etl2pcapng", to not exit the command prompt when complete and output Debug logging.
        [switch]$UseDebug
    )

    function New-RegKey 
    {
        [CmdletBinding()]
        param(
            [string]$path,
            [string]$type,
            $value
        )

        Write-Verbose "New-RegKey: Starting"
        # make sure the PSDrive to HKCR is created
        if (-NOT (Get-PSDrive -Name HKCR -EA SilentlyContinue)) 
        {
            New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -Scope Local | Out-Null
        }

        # do the reg work
        try 
        {
            Write-Verbose "New-RegKey: Creating key $path"
            if ($type -eq "Directory") {
                New-Item $path -ItemType $type -Force -EA SilentlyContinue | Out-Null
            }
            else {
                Write-Verbose "New-RegKey: Setting property on $path to $value"
                Set-ItemProperty -LiteralPath $path -Name '(Default)' -Value $value -Force -EA SilentlyContinue | Out-Null
            }
        }
        catch 
        {
            Write-Error "New-RegKey: Failed to create $path."
            return $false
        }

        Write-Verbose "New-RegKey: Work complete!"
        return $true
    }

    Write-Verbose "Register-Etl2Pcapng: Work! Work!"

    # test for Admin access
    Write-Verbose "Register-Etl2Pcapng: Test admin rights."
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) 
    {
        Write-Error "Register-Etl2Pcapng: Administrator rights are needed to execute this command. Please run PowerShell as Administrator and try again."
        return $null
    }

    # make sure the module is installed, just in case
    Write-Verbose "Register-Etl2Pcapng: Verify this is running from the module."
    $isModFnd = Get-Module -ListAvailable Convert-ETL2PCAPNG -EA SilentlyContinue

    if (-NOT $isModFnd) {
        Write-Error "This cannot be run outside of the Convert-ETL2PCAPNG module. Please install the Convert-ETL2PCAPNG module first:`n`nInstall-Module Convert-ELT2PCAPNG."
        return $null
    }

    # create a PSDrive to HKEY_CLASSES_ROOT
    Write-Verbose "Register-Etl2Pcapng: Create PSDrive for HKEY_CLASSES_ROOT."
    if (-NOT (Get-PSDrive -Name HKCR -EA SilentlyContinue)) 
    {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -Scope Local | Out-Null
    }

    #### NEED TO CLEAN THIS UP IN THE FUTURE ####
    # create the shell extension for etl2pcapng
    Write-Verbose "Register-Etl2Pcapng: Add the Convert-Etl2Pcapng app in HKCR."
    if (-NOT (New-RegKey "HKCR:\Convert-Etl2Pcapng\Shell\CONVERT\Command" Directory)) { Write-Error "Could not write reg 1."; exit }

    # create the command
    Write-Verbose "Register-Etl2Pcapng: Configure Convert-ETL2PCAPNG."
    if (-NOT (New-RegKey "HKCR:\Convert-Etl2Pcapng\Shell\CONVERT" -value "Convert with etl2pcapng")) { Write-Error "Could not write reg 2."; exit }

    if ($UseVerbose) 
    {
        $cmd = 'cmd /k powershell -NoProfile -NonInteractive -NoLogo Convert-Etl2Pcapng %1 -Verbose'
    }
    elseif ($UseDebug) 
    {
        $cmd = 'cmd /k powershell -NoProfile -NonInteractive -NoLogo Convert-Etl2Pcapng %1 -Debug'
    }
    else 
    {
        $cmd = 'cmd /c powershell -NoProfile -NonInteractive -NoLogo Convert-Etl2Pcapng %1'
    }


    if (-NOT (New-RegKey "HKCR:\Convert-Etl2Pcapng\Shell\CONVERT\Command" -Value $cmd)) { Write-Error "Could not write reg 3."; exit }


    # check for the ETL extenstion in HKCR, create if missing
    Write-Verbose "Register-Etl2Pcapng: Add the context item to .etl files."
    if (-NOT (New-RegKey "HKCR:\.etl" Directory)) { Write-Error "Could not write reg 4."; exit }

    if (-NOT (New-RegKey "HKCR:\.etl" -Value 'Convert-Etl2Pcapng')) { Write-Error "Could not write reg 5."; exit }

    Write-Verbose "Register-Etl2Pcapng: Work complete!"
} #end Register-Etl2Pcapng


# FUNCTION : Unregister-Etl2Pcapng
# PURPOSE  : Unregisters the ecript to ETL files  
function Unregister-Etl2Pcapng 
{
    [CmdletBinding()]
    param()

    <#
    .SYNOPSIS
        Removes the right-click menu option in Windows for etl2pcapng.
    .DESCRIPTION
        Unregisters the shell context menu item for Convert-Etl2Pcapng. This will remove the option to right-click on an ETL file and select "Convert with etl2pcapng". 
    .EXAMPLE
        Unregister-Etl2Pcapng

        Unregisters the "Convert with etl2pcapng" menu item.
    .NOTES
        Author: Microsoft Edge OS Networking Team and Microsoft CSS
        Please file issues on GitHub @ https://github.com/microsoft/Convert-Etl2Pcapng
    .LINK
        More projects               : https://github.com/topics/msftnet
        Windows Networking Blog     : https://blogs.technet.microsoft.com/networking/
    #>

    Write-Verbose "Unregister-Etl2Pcapng: Work! Work!"

    # test for Admin access
    Write-Verbose "Unregister-Etl2Pcapng: Test admin rights."
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) 
    {
        Write-Error "Unregister-Etl2Pcapng: Administrator rights are needed to execute this command. Please run PowerShell as Administrator and try again."
        return $null
    }

    # create a PSDrive to HKEY_CLASSES_ROOT
    Write-Verbose "Unregister-Etl2Pcapng: Creating HKCR PSDrive."
    if (-NOT (Get-PSDrive -Name HKCR -EA SilentlyContinue)) 
    {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -Scope Local | Out-Null
    }

    # remove the Convert-ETL2PCAPNG HKCR key
    Write-Verbose "Unregister-Etl2Pcapng: Removing Convert-Etl2Pcapng HKCR app."
    Remove-Item "HKCR:\Convert-Etl2Pcapng" -Recurse -Force -EA SilentlyContinue

    # remove the default to .etl, but don't delete it
    Write-Verbose "Unregister-Etl2Pcapng: Cleanup .etl extension option."
    Set-ItemProperty -LiteralPath "HKCR:\.etl" -Name '(Default)' -Value "" -Force -EA SilentlyContinue

    Write-Verbose "Unregister-Etl2Pcapng: Work complete!"
} #end Unregister-Etl2Pcapng


# FUNCTION : Convert-Etl2Pcapng
# PURPOSE  : Executes ETL2PCAPNG 
function Convert-Etl2Pcapng 
{
    <#
    .SYNOPSIS
        ndiscap tracing is the built-in packet capture tool used in Windows. ETL files cannot be read by third-party tools like Wireshark. Etl2pcapng converts ndiscap packet captures to a format readable by Wireshark.
    .DESCRIPTION
        This script converts ndiscap packets in an ETL into a Wireshark readable pcapng file.
    .PARAMETER Path
        The path to the ETL file or path containing the ETL file(s). When a container/directory is provided the script will search the partent directory for ETL files to convert.
    .PARAMETER Out
        The output path for the files. This parameter is optional. By default the script saves to the same directory the ETL file is located in.
    .PARAMETER Recurse
        Searches through child containers/directories for ETL files. Only valid when Path is a directory.
    .EXAMPLE
        Convert-Etl2Pcapng -Path C:\traces -Out D:\temp -Recurse

        Searches through C:\traces and all child directories for ETL files. The converted PCAPNG files will be saved to D:\temp.
    .EXAMPLE
        Convert-LBFO2Set C:\traces

        Converts all ETL files in C:\traces, but not any child directories, for ETLs and saves the PCAPNG files to the same directory (C:\traces).
    .NOTES
        Author: Microsoft Edge OS Networking Team and Microsoft CSS
        Please file issues on GitHub @ https://github.com/microsoft/Convert-Etl2Pcapng
    .LINK
        More projects               : https://github.com/topics/msftnet
        Windows Networking Blog     : https://blogs.technet.microsoft.com/networking/
    #>

    [CmdletBinding(DefaultParameterSetName = 'LiteralPath')]
    param (
        # Path accepts a literal string path.
        [parameter( Position = 0,
            ParameterSetName = 'LiteralPath',
            HelpMessage = 'Enter one or more filenames as a string',
            ValueFromPipeline = $false )]
        [string]
        $Path,

        # PSPath accepts a FileSystemInfo object from cmdlets like Get-Item and Get-ChildItem. Accepts pipeline input.
        [parameter( Position = 0,
            ParameterSetName = 'Path',
            HelpMessage = 'Enter one or more filenames as a string',
            ValueFromPipeline = $true )]
        [System.IO.FileSystemInfo]
        $PSPath,

        [parameter( Position = 1,
            ParameterSetName = 'Path',
            ValueFromPipeline = $false )]
        [parameter( Position = 1,
            ParameterSetName = 'LiteralPath',
            ValueFromPipeline = $false )]
        [string]
        $Out = $null,

        [parameter( Mandatory = $false,
            ParameterSetName = 'Path',
            ValueFromPipeline = $false )]
        [parameter( Mandatory = $false,
            ParameterSetName = 'LiteralPath',
            ValueFromPipeline = $false )]
        [switch]
        $Recurse
    )

    Write-Verbose "Convert-Etl2Pcapng: Work! Work!"

    ### Validating paths and parameters ###
    # check the path param
    Write-Verbose "Convert-Etl2Pcapng: Validate Path."
    if ($PSPath -is [System.IO.FileSystemInfo]) 
    {
        $isPathFnd = $PSPath
    }
    else 
    {
        $isPathFnd = Get-Item $Path -EA SilentlyContinue    
    }
    
    # if a dir/container, then look for ETL files
    if ($isPathFnd) 
    {
        # is this a container/directory
        if ($isPathFnd.PSisContainer) 
        {
            Write-Verbose "Convert-Etl2Pcapng: Searching for ETL files in $($isPathFnd.FullName)."
            # look for ETL files
            if ($Recurse) 
            {
                Write-Verbose "Convert-Etl2Pcapng: Dir with child container recurse."
                [array]$etlFiles = Get-ChildItem $isPathFnd.FullName -Filter "*.etl" -Recurse -Force -ErrorAction SilentlyContinue
            }
            else 
            {
                Write-Verbose "Convert-Etl2Pcapng: Dir with no child containers."
                [array]$etlFiles = Get-ChildItem $isPathFnd.FullName -Filter "*.etl" -Force -ErrorAction SilentlyContinue
            }
        }
        elseif ($isPathFnd.Extension -eq ".etl") 
        {
            Write-Verbose "Convert-Etl2Pcapng: Single file."
            [array]$etlFiles = $isPathFnd
        }
    }

    # exit if no ETL file(s) found
    if (-NOT $etlFiles) 
    {
        if ($PSPath -is [System.IO.FileSystemInfo]) 
        {
            Write-Error "Convert-Etl2Pcapng: Failed to find a valid ETL file. Path: $($PSPath.FullName)"
        }
        else 
        {
            Write-Error "Convert-Etl2Pcapng: Failed to find a valid ETL file. Path: $Path"
        }
        return $null
    }

    # make sure $Out is a valid location
    if ($Out) 
    {
        Write-Verbose "Convert-Etl2Pcapng: Validate Out."

        if (-NOT (Test-Path $Out -IsValid)) 
        {
            Write-Error "Convert-Etl2Pcapng: The Out path is an invalid path. Out: $Out"
            return $null
        }

        # create the dir if it's not there
        $isOutFnd = Get-Item $Out -EA SilentlyContinue
        if (-NOT $isOutFnd) 
        {
            try {
                Write-Verbose "Convert-Etl2Pcapng: Creating output path $Out"
                New-Item $Out -ItemType Directory -Force -EA Stop | Out-Null
            }
            catch {
                Write-Error "Convert-Etl2Pcapng: Failed to create Out directory at $Out. Error: $($error[0].ToString())"
            }
        }
    }


    ### get the path to etl2pcapng.exe
    Write-Verbose "Convert-Etl2Pcapng: Getting for etl2pcapng location."
    $e2pPath = Update-Etl2Pcapng

    # validate etl2pcapng is actually there and strip out the parent dir
    if ($e2pPath) 
    {
        $isE2PFnd = Get-Item $e2pPath -EA SilentlyContinue

        if ($isE2PFnd) {
            $e2pDir = $isE2PFnd.DirectoryName
        }
        else {
            Write-Error "Convert-Etl2Pcapng: Failed to locate etl2pcanpng.exe."
            return $null
        }
    }

    #### Finally do the conversion work ####
    Write-Verbose "Convert-Etl2Pcapng: Starting ETL to PCAPNG conversion(s)."
    Push-Location $e2pDir
    foreach ($file in $etlFiles) 
    {
        if ($Out) 
        {
            Write-Verbose "Convert-Etl2Pcapng: Converting $($file.FullName) to $Out\$($file.BaseName).pcapng"
            .\etl2pcapng.exe "$($file.FullName)" "$Out\$($file.BaseName).pcapng"
        }
        else 
        {
            Write-Verbose "Convert-Etl2Pcapng: Converting $($file.FullName) to $($file.DirectoryName)\$($file.BaseName).pcapng"
            .\etl2pcapng.exe "$($file.FullName)" "$($file.DirectoryName)\$($file.BaseName).pcapng"
        }
    }
    Pop-Location

    Write-Verbose "Convert-Etl2Pcapng: Work complete!"
} #end Convert-Etl2Pcapng



# FUNCTION : Update-Etl2Pcapng
# PURPOSE  : Gets the newest version of ETL2PCAPNG  
function Update-Etl2Pcapng 
{
    [CmdletBinding()]
    param([switch]$Force)

    <# 
     # Check for etl2pcapng updates only once a week
     #
     # The last time an update was checked for is located
     # in the module directory under settings.json.
     #
     # The -Force param causes an etl2pcapng update check regardless of the last date checked.
     #
     #>


    Write-Verbose "Update-Etl2Pcapng: Starting"

    # check if etlpcapng is already downloaded - do not use pwsh terney to maintain Windows PowerShell backwards compatibilty!
    if ([System.Environment]::Is64BitOperatingSystem) 
    {
        $arch = "x64"
    }
    else {
        $arch = "x86"    
    }

    Write-Verbose "Update-Etl2Pcapng: OS architecture is $arch."

    # read settings.json
    $settings = Get-E2PSettings

    Write-Verbose "Update-Etl2Pcapng: Settings:`n`n$($settings | Format-List | Out-String)`n`n"

    # store app data path in an easier to use var
    $here = $settings.appDataPath

    Write-Verbose "Update-Etl2Pcapng: Timestamps:`nCurrent date:`t$((Get-Date).Date)`nSettings date:`t$($settings.LastUpdate.Date)`n"

    # check for an update when -Force set or it's been 7 days since we last checked
    if ($Force -or ((Get-Date).Date.AddDays(-7) -gt $settings.LastUpdate.Date)) 
    {
        Write-Verbose "Update-Etl2Pcapng: Checking for an update to etl2pcapng."
        # controls whether a download of etl2pcapng.exe is needed
        $download = $false

        Write-Verbose "Update-Etl2Pcapng: Getting etl2pcapng releases from GitGub."
        $tagsUri = 'https://github.com/microsoft/etl2pcapng/releases' 

        # grab the etl2pcapng releases page from GitHub
        try 
        {
            $tags = Invoke-WebRequest -Uri $tagsUri -EA Stop
        }
        catch 
        {
            Write-Error "Update-Etl2Pcapng: Cannot reach the etl2pcapng GitHub page: $($error[0].ToString())"
            break
        }

        # parse the HTML content
        $HTML = New-Object -Com "HTMLFile"

        # this manages parsing the HTML based on a variety of conditions
        try 
        {
            # works with Win PoSh
            $html.IHTMLDocument2_write($tags.Content)
        }
        catch 
        {
            # works with pwsh7
            $src = [System.Text.Encoding]::Unicode.GetBytes($tags.RawContent)
            $html.write($src)

            $rawReleases = $html.getElementsByClassName("release-entry")
        }
        finally 
        {
            # parses out the data needed to create the releases list
            if (-NOT $rawReleases) 
            {
                $rawReleases = $html.getElementsByTagName("div") | Where-Object OuterHtml -match "release-entry"
            }
        }


        # get all the etl2pcapng releases
        $releases = @()

        foreach ($release in ($rawReleases | Select-Object OuterHTML)) 
        {
            # get release version
            [array]$tmpRawVer = $release.OuterHTML.Split("`n") | Where-Object { $_ -match ".zip" }
            
            [string]$tmpUri = $tmpRawVer[0].Split(" ") | Where-Object { $_ -match "href=" } | ForEach-Object { $_.Split('"')[1] }
            
            [string]$tmpVer = $tmpUri.Split("/") | Where-Object { $_ -match "^v[0-9].*$" }

            if ($tmpVer -match ".zip") 
            {
                $tmpVer = $tmpVer.Replace(".zip", "")
            }
            
            # get release time
            [array]$tmpRawTime = $release.OuterHTML.Split("`n") | Where-Object { $_ -match "datetime=" }
            [datetime]$tmpTime = $tmpRawTime[0].Split('<').Split('>').Split(" ") | Where-Object { $_ -match "datetime" } | ForEach-Object { $_.Split('"')[1] }

            
            $releases += [PSCustomObject]@{
                Version = $tmpVer
                URI     = "https://github.com$tmpUri"
                Time    = $tmpTime
            }


            Remove-Variable tmpRawVer, tmpVer, tmpRawTime, tmpTime, tmpUri
        }

        # parse out duplicates, which happens
        $releases = $releases | Sort-Object -Property Version -Unique

        Write-Verbose "Update-Etl2Pcapng: Found the following releases:`n`n$($releases | Format-Table | Out-String)"

        # find the newest release
        $newest = ($releases | Sort-Object -Property Time -Descending)[0]

        Write-Verbose "Update-Etl2Pcapng: Detected newest release: $($newest.Version)"

        # see if etl2pcapng.exe is already downloaded
        $isE2PFnd = Get-Item "$here\etl2pcapng\$arch\etl2pcapng.exe" -EA SilentlyContinue

        # download if the etl2pcapng.exe file is missing
        if (-NOT $isE2PFnd) 
        {
            Write-Verbose "Update-Etl2Pcapng: etl2pcapng not found. Will download etl2pcapng."
            $download = $true
        }
        # download when a newer version is available
        elseif ($newest.Time.Date -gt $isE2PFnd.LastWriteTime.Date) 
        {
            # newer version online
            Write-Verbose "Update-Etl2Pcapng: A newer etl2pcapng was found. Will download the update."
            $download = $true
        }

        if ($download) 
        {
            Write-Verbose "Update-Etl2Pcapng: Cleaning up existing files."
            # delete existing zip file
            $isZipFnd = Get-Item "$here\etl2pcapng.zip" -EA SilentlyContinue
            if ($isZipFnd) { Remove-Item "$here\etl2pcapng.zip" -Force | Out-Null }
            
            # make sure VC Redist is installed
            Write-Verbose "Update-Etl2Pcapng: Checking for Visual Studio C++ Redistribution install."

            # look for VS C++ 2015-2019
            $isVCRedistFnd = Find-E2PSoftware "Microsoft Visual C\+\+ 2015-2019 Redistributable \($arch\)"

            # try to download and install when missing
            if (-NOT $isVCRedistFnd) 
            {
                if ($arch -eq "x64") 
                {
                    $URI = $settings.vcredist64Uri
                }
                else 
                {
                    $URI = $settings.vcredist32Uri
                }

                Write-Verbose "Update-Etl2Pcapng: Downloading Microsoft Visual C\+\+ 2015-2019 Redistributable from $URI`."

                # download vcredist
                try 
                {
                    # force to TLS 1.2 and download
                    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                    Invoke-WebRequest -Uri $URI -OutFile "$here\vcredist.exe" -ErrorAction Stop
                }
                catch 
                {
                    Write-Error "Update-Etl2Pcapng: Microsoft Visual C`+`+ 2015-2019 Redistributable `($arch`) is not installed and could not be downloaded. Please manually download and install from $URI before using etl2pcapng."
                    exit
                }

                # try to install vcredist
                try 
                {
                    Push-Location $here
                    Write-Verbose "Update-Etl2Pcapng: Installing Microsoft Visual C\+\+ 2015-2019 Redistributable."
                    .\vcredist.exe /install /quiet /log "$here\Install_vc_redist_2017_x64.log"
                    Pop-Location
                }
                catch 
                {
                    Write-Error "Update-Etl2Pcapng: Failed to install Microsoft Visual C`+`+ 2015-2019 Redistributable `($arch`). Please download from $URI and install before continuing."
                    Pop-Location
                    Remove-Item "$here\vcredist.exe" -Force | Out-Null
                    exit
                }

                # cleanup
                Start-Sleep 1
                Remove-Item "$here\vcredist.exe" -Force | Out-Null
                Remove-Item "$here\Install*.log" -Force | Out-Null
                Write-Verbose "Update-Etl2Pcapng: VC redist installed."
            }
            
            
            # remove the existing etl2pcapng
            $isDirFnd = Get-Item "$here\etl2pcapng" -EA SilentlyContinue

            ### There is a -Recurse bug here when using OneDrive sync'ed dirs.
            ### It is supposed to be fixed in pwsh 7, but it's not.
            ### This should not be an issue for production since this should be run from a %LocalAppData%, not OneDrive.
            ### https://github.com/PowerShell/PowerShell/issues/9461

            if ($isDirFnd) { Remove-Item $isDirFnd.FullName -Recurse -Force -EA SilentlyContinue | Out-Null }

            Write-Verbose "Update-Etl2Pcapng: Downloading etl2pcapng"
            # grab the etl2pcapng tags page from GitHub
            try 
            {
                Invoke-WebRequest -Uri $newest.URI -OutFile "$here\etl2pcapng.zip" -EA Stop
            }
            catch 
            {
                Write-Error "Update-Etl2Pcapng: Cannot reach the etl2pcapng GitHub page: $($error[0].ToString())"
                return $null
            }
        
            # extract and overwrite
            Write-Verbose "Update-Etl2Pcapng: Extracting the etl2pcapng archive."
            try 
            {
                Expand-Archive "$here\etl2pcapng.zip" $here -Force -EA Stop    
            }
            catch 
            {
                Write-Error "Update-Etl2Pcapng: Could not extract etl2pcapng. Error: $($error[0].ToString())" 
                return $null
            }
            
            # cleanup the zip
            Write-Verbose "Update-Etl2Pcapng: Cleaning up the zip file."
            $isZipFnd = Get-Item "$here\etl2pcapng.zip" -EA SilentlyContinue
            if ($isZipFnd) { Remove-Item "$here\etl2pcapng.zip" -Force -EA SilentlyContinue | Out-Null }
        }

        # update Settings.LastUpdate
        Write-Verbose "Update-Etl2Pcapng:  Updating LastUpdate in settings."
        $settings.LastUpdate = (Get-Date).Date.ToUniversalTime()
        $settings | ConvertTo-Json | Out-File "$here\settings.json" -Force -Encoding utf8
    }

    
    $isE2PFnd = Get-Item "$here\etl2pcapng\$arch\etl2pcapng.exe" -EA SilentlyContinue

    
    if ($isE2PFnd) 
    {
        Write-Verbose "Update-Etl2Pcapng: Returning etl2pcapng.exe at $here\etl2pcapng\$arch\etl2pcapng.exe"
        Write-Verbose "Update-Etl2Pcapng: Work complete."
        return ("$here\etl2pcapng\$arch\etl2pcapng.exe")
    }
    else 
    {
        Write-Verbose "Update-Etl2Pcapng: Failed to find or download etl2pcapng.exe."
        Write-Verbose "Update-Etl2Pcapng: Work complete."
        return $null    
    }

} #end Update-Etl2Pcapng


##### AUX functions that are not exported #####

# FUNCTION : Get-E2PSettings
# PURPOSE  : Finds and returns the module settings  
function Get-E2PSettings 
{
    Write-Verbose "Get-E2PSettings: Starting"
    ### Redist URLs are found here: https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads
    ### [datetime]::FromFileTimeUtc(0) sets the date to 1 Jan 1601 00:00, the first day of the Gregorian calendar. ###
    # create default settings
    $defSettings = [PSCustomObject]@{
        LastUpdate    = [datetime]::FromFileTimeUtc(0)
        vcredist64Uri = 'https://aka.ms/vs/16/release/vc_redist.x64.exe'
        vcredist32Uri = 'https://aka.ms/vs/16/release/vc_redist.x86.exe'
        appDataPath   = "$env:LocalAppData\etl2pcapng"
    }

    $setPath = "$($defSettings.appDataPath)\settings.json"

    # is there a settings file at the appDataPath location?
    $isADP = Get-Item $setPath -ErrorAction SilentlyContinue

    # read the file if it exists
    if ($isADP) 
    {
        Write-Verbose "Get-E2PSettings: Settings file found. Getting settings from file."
        # read the settings file
        $settings = Get-Content $setPath | ConvertFrom-Json

        # return the settings
        Write-Verbose "Get-E2PSettings: Work complete!"
        return $settings

        # create the file if it does not exist
    }
    else 
    {
        # create the etl2pcapng dir
        Write-Verbose "Get-E2PSettings: Settings file not found. Using defaults."
        try 
        {
            $tmpResult = New-Item "$(Split-Path $setPath -Parent)" -ItemType Directory -Force -ErrorAction Stop
            Write-Verbose $tmpResult
        }
        catch 
        {
            Write-Error "Get-E2PSettings: Unable to create settings file at $setPath`. Please try again running from an elevated prompt (Run as administrator)."
            exit
        }

        # write the settings JSON file
        $defSettings | ConvertTo-Json | Out-File $setPath -Force -Encoding utf8
        
        # return default settings
        Write-Verbose "Get-E2PSettings: Work complete!"
        return $defSettings
    }
    Write-Verbose "Get-E2PSettings: Something unexpected went wrong and no settings were returned."
    Write-Verbose "Get-E2PSettings: Work complete!"
    return $null
} #end Get-E2PSettings


# FUNCTION: Find-E2PSoftware
# PURPOSE:  Gets a list of all installed software from the registry with optional filter on the DisplayName.

function Find-E2PSoftware 
{
    [CmdletBinding()]
    param ($displayFilter = $null)

    Write-Verbose "Find-E2PSoftware: Starting"

    $apps = @()
    
    [string[]]$regPaths = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432node\Microsoft\Windows\CurrentVersion\Uninstall"
      
    foreach ($regPath in $regPaths) 
    { 
      
        Write-Verbose "Find-E2PSoftware: Checking Path: $regPath"

        try 
        { 
            $reg = Get-Item $regPath -ErrorAction Stop
        }
        catch 
        { 
            Write-Debug "Find-E2PSoftware: Could not find the path: $_ "
            continue 
        } 
      

        # change the EAP to stop to force the try to fail if there is an error
        $ErrorActionPreference = "SilentlyContinue"

        # get all the child keys
        [array]$regkeys = Get-ChildItem $regPath

        #echo "$($regKeys.PSChildName | Out-String)"
      
        foreach ($key in $regkeys) 
        {   
            Write-Verbose "Find-E2PSoftware: $($key.PSChildName)"
                
            if ($displayFilter) 
            {
                Write-Verbose "Find-E2PSoftware: Filter $((Get-ItemProperty -Path $key.PsPath -Name DisplayName).DisplayName) match $displayFilter"
                if ( "$((Get-ItemProperty -Path $key.PsPath -Name DisplayName).DisplayName)" -match $displayFilter) 
                {
                    # create the PsCustomObject that stores software details
                    $tmpObj = [pscustomobject]@{
                        Name = $key.PSChildName
                    }
        
                    # loop through all the properties and add them to the object
                    $key.Property | ForEach-Object {
                         
                        $tmpObj | Add-Member -Name $_ -MemberType NoteProperty -Value "$((Get-ItemProperty -Path $key.PsPath -Name $_)."$_")"
                    }
        
                    # add the software to the apps array
                    $apps += $tmpObj
                    Remove-Variable tmpObj
                }
            }
            else 
            {
                $tmpObj = [pscustomobject]@{
                    Name = $key.PSChildName
                }
    
                $key.Property | ForEach-Object {
                     
                    $tmpObj | Add-Member -Name $_ -MemberType NoteProperty -Value "$((Get-ItemProperty -Path $key.PsPath -Name $_)."$_")"
                }
    
                # add the software to the apps array
                $apps += $tmpObj
                Remove-Variable tmpObj
            }
        }
    }

    Write-Verbose "Find-E2PSoftware: Work complete!"
    return $apps     
} #end Find-E2PSoftware


# the list of functions the module will export.
Export-ModuleMember -Function Register-Etl2Pcapng
Export-ModuleMember -Function Unregister-Etl2Pcapng
Export-ModuleMember -Function Convert-Etl2Pcapng
Export-ModuleMember -Function Update-Etl2Pcapng