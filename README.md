# Overview

This tool acts as a simple wrapper for [etl2pcapng.exe](https://github.com/microsoft/etl2pcapng).

ETL files, generated by using commands such as "netsh trace start", are created by Windows in-box packet capture and event collection solutions. Think of ETL/ETW logging as something similar to tcpdump plus strace plus dtrace in Linux/Unix, but in a single tool. 

The ETL file format cannot be natively opened by any currently supported Microsoft tool. This poses a problem for people who want to use Windows in-box packet capture functionality.

etl2pcapng was built to extract packets out of ETL files and convert them to a Wireshark readable format, pcapng. This PowerShell wrapper extends the functionality of, and provides automated management and updates for, etl2pcapng.exe.

# Install

The module can be downloaded using the following command in PowerShell.

`Install-Module Convert-Etl2Pcapng`

Use this command to install without any prompts, assuming you accept the MIT license used.

`Install-Module Convert-Etl2Pcapng -Force -AcceptLicense`

It is possible that a new version of PowerShellGet will be needed before the module will install from PSGallery. Run these three commands to update all the necessary components, restart PowerShell, and then try to install Convert-Etl2Pcapng again.

    # Make sure all other instances of PowerShell, including VS Code, PowerShell IDE, etc. are closed
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name PowerShellGet -MinimumVersion 2.2.4.1 -Force -AllowClobber
    
    # A restart of PowerShell is required if the module was updated
    


# Usage

### Convert-Etl2Pcapng

Used to automate etl2pcapng conversion. Accepts a literal path to a location containing ETL files or the literal path to a single ETL file. Paths from the pipeline are accepted.

The Recurse parameter will traverse child directories for ETL files. Only valid when the path is a directory.

The Out parameter can be used to store the results in a new location; otherwise, the same path as the ETL file is used.

### Register-Etl2Pcapng

__*Requires elevated rights (Run as administrator)*__

Registers a shell context menu item for Convert-Etl2Pcapng. Right-clicking on an ETL fill will show an option "Convert with etl2pcapng". This will execute Convert-Etl2Pcapng with default settings against the ETL file.

UseVerbose and UseDebug can be used to enable cli logging to troubleshoot issues with the menu option.

### Unregister-Etl2Pcapng

__*Requires elevated rights (Run as administrator)*__

Unregisters the shell context menu item for Convert-Etl2Pcapng. This will remove the option to right-click on an ETL file and select "Convert with etl2pcapng". 

### Update-Etl2Pcapng

Gets the newest version of etl2pcapng.exe from GitHub and returns the path to etl2pcapng.exe to the caller. This cmdlet generally does not need to be run as Convert-Etl2Pcapng executes this cmdlet. 

GitHub is only queried every 7 days or when the Force parameter is used.

The module files, including etl2pcapng, are stored in %LocalAppData%\etl2pcapng so an elevated prompt is not needed to execute the commands.


# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
