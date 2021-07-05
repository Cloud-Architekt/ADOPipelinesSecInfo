
<#
 .Synopsis
  Generates authorization header for authentication requests as part of the module. 

 .Description
  Generates authorization header for authentication requests as part of the module. 

 .Parameter ADOOrganizationName
  The name of your Azure DevOps Organization. The name is visible in the "Organization setting" or URL of ADO (https://dev.azure.com/<AzDoOrganizationName>)

 .Parameter ADoPatUserName
  Enter the user name of the Azure DevOps accounts for authentication with Personal Access Token (PAT)

 .Parameter ADOPatToken
  Enter the Personal Access Token (PAT) if you like to authenticate with PAT instead of the System Access Token (from pipeline)

 .Example
   # Generates Authorization header for DevOps Org "contoso" with PAT of ADO admin
   Connect-ADOOrganization -ADOOrganizationName "contoso" -ADOPatUserName "john.smith" -AzDoToken "scfwfkriqhsdfjsaflkafsdffdsfdsfds884305"

#>

[Cmdletbinding()]
Param(
    [Parameter(Mandatory = $false)][string]$ADOOrganizationName,
    [Parameter(Mandatory = $false)][string]$ADOPatUserName,
    [Parameter(Mandatory = $false)][string]$ADOPatToken    
)

$script:UriOrga =  "https://dev.azure.com/$ADOOrganizationName/"
$script:UriReleaseMgmt = "https://vsrm.dev.azure.com/$ADOOrganizationName/"

Function Connect-ADOOrganization
{
    if ($ADOPatUserName -ne $null) {
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $ADOPatUserName, $ADOPatToken)))
        $script:Header = @{
            Authorization = ("Basic {0}" -f $base64AuthInfo)
        }
    }
    else {
        $script:Header = @{
            Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"
        }
    }
}
