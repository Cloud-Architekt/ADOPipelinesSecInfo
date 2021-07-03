
<#
 .Synopsis
  Displays details of all ARM service connections and the relation to the used service principal.

 .Description
  The following function displays all ARM service connections in the Azure DevOps organization with detailed information.
  This includes the relation of the connection to the DevOps project, service principal and creator.

 .Example
   # Export CSV of service connections for enrichment or import as WatchList in Azure Sentinel:
   Get-ADOServiceConnectionDetails | Export-Csv .\SentinelServiceConnection-Watchlist.csv -NoTypeInformation

#>

Function Get-ADOServiceConnectionDetails
{
    $AzDOProjects = (Invoke-RestMethod ($UriOrga + "_apis/projects?api-version=6.0") -Headers $Header -ErrorAction Stop).Value
    $ServiceEndpoints = $AzDOProjects | ForEach-Object {
        (Invoke-RestMethod ($UriOrga + $_.name + "/_apis/serviceendpoint/endpoints?api-version=6.1-preview.4") -Headers $Header -ErrorAction Stop).Value
    }


    $ARMServiceEndpoints = $ServiceEndpoints | where-object {$_.type -eq "azurerm"}

    $ARMServiceEndpoints | foreach-object {
        $ReferencedADOProject = $_.serviceEndpointProjectReferences.projectReference.name
        $UsedSPforAuth = (Invoke-RestMethod ($UriOrga + $ReferencedADOProject + "/_apis/serviceendpoint/endpoints/" + $_.id + "?api-version=6.1-preview.4") -Headers $Header -ErrorAction Stop).authorization.parameters

        [pscustomobject]@{
            ServiceConnectionId         = $_.id
            ServiceConnectionName       = $_.name
            ServiceConnectionCreatorUPN = $_.createdBy.uniqueName 
            ServiceConnectionCreatorID  = $_.createdBy.id
            ADOProjectID                = $_.serviceEndpointProjectReferences.projectReference.id
            ADOProjectName              = $_.serviceEndpointProjectReferences.projectReference.Name
            ServicePrincipalID          = $UsedSPforAuth.serviceprincipalid
            ServicePrincipalTenantID    = $UsedSPforAuth.tenantid
            ServicePrincipalAuthType    = $UsedSPforAuth.authenticationType
            ServicePrincipalKey         = $UsedSPforAuth.serviceprinicpalkey
        }
    }
}