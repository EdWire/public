configuration SetRegistryValue
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [string]$KeyFormat,

        [Parameter(Mandatory = $true)]
        [string]$KeyValue
    )

    $ErrorActionPreference = 'Stop'
    
    $ScriptPath = [system.io.path]::GetDirectoryName($PSCommandPath)
    . (Join-Path $ScriptPath "Functions.ps1")


    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }

        Script ExecuteSetRegistryValue
        {
            GetScript = {
                return @{'Result' = ''}
            }
            SetScript = {
                . (Join-Path $using:ScriptPath "Functions.ps1")
                try {
                    return (& Set-Registry-Value -Path $using:Path -Key $using:Key -KeyFormat $using:KeyFormat -KeyValue $using:KeyValue)
                }
                catch {
                    $ErrMsg = $PSItem | Format-List -Force | Out-String
                    Write-Log -Err $ErrMsg
                    throw [System.Exception]::new("Some error occurred in DSC ExecuteSetRegistryValue SetScript: $ErrMsg", $PSItem.Exception)
                }
            }
        }
    }
}