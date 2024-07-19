#Microsoft.RDInfra.RDPowerShell and Get-Package both require powershell 5.0 or higher.
#Requires -Version 5.0

<#
.SYNOPSIS
Common functions to be used by DSC scripts
#>

# Setting to Tls12 due to Azure web app security requirements
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

<#
.DESCRIPTION
Set a Registry Value

.PARAMETER Path
The registry path

.PARAMETER Key
The registry key

.PARAMETER KeyFormat
The possible types for a registry value format are: string (REG_SZ or REG_MULTI_SZ), expandable string (REG_EXPAND_SZ), integer (REG_DWORD) and binary (REG_BINARY). In order to define a REG_MULTI_SZ value, enter the strings that compose that value, one per-line.

.PARAMETER KeyValue
The registry key value

[CalledByARMTemplate]
#>
function Set-Registry-Value {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [string]$KeyFormat,

        [Parameter(Mandatory = $true)]
        [string]$KeyValue
    )
    
    try{
        if(!(Test-Path $Path)){
            New-Item -Path $Path -Force
        }

        if(!$Key){
            Set-Item -Path $Path -Value $KeyValue
        }
        else{
            Set-ItemProperty -Path $Path -Name $Key -Value $KeyValue -Type $KeyFormat
        }
        Write-Log "Key set: $Key = $KeyValue"
    }
    catch{
        Write-Log -Err $_.Exception.Message
    }
}

function Write-Log {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        # note: can't use variable named '$Error': https://github.com/PowerShell/PSScriptAnalyzer/blob/master/RuleDocumentation/AvoidAssignmentToAutomaticVariable.md
        [switch]$Err
    )
     
    try {
        $DateTime = Get-Date -Format "MM-dd-yy HH:mm:ss"
        $Invocation = "$($MyInvocation.MyCommand.Source):$($MyInvocation.ScriptLineNumber)"

        if ($Err) {
            $Message = "[ERROR] $Message"
        }
        
        Add-Content -Value "$DateTime - $Invocation - $Message" -Path "$([environment]::GetEnvironmentVariable('TEMP', 'Machine'))\ScriptLog.log"
    }
    catch {
        throw [System.Exception]::new("Some error occurred while writing to log file with message: $Message", $PSItem.Exception)
    }
}