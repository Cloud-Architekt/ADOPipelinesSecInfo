
Function Get-ADOPipelineEndpointExecutions
{
<#
 .Synopsis
  Displays execution of service connections from a pipeline.

 .Description
  The following function displays all executions of an ARM service connections from a pipeline.
  This includes the detailed information about the execution which includes pipeline and process name and the relation to service principal and subscription.

 .Example
   # Export CSV of service connection executions for enrichment or import as WatchList in Azure Sentinel:
   Get-ADOPipelineEndpointExecutions | Export-Csv .\ADOServiceConnectionEnrichment-Watchlist.csv -NoTypeInformation
#>
    $AzDOProjects = (Invoke-RestMethod ($UriOrga + "_apis/projects?api-version=6.0") -Headers $Header -ErrorAction Stop).Value
    $ServiceEndpoints = $AzDOProjects | ForEach-Object {
    (Invoke-RestMethod ($UriOrga + $_.name + "/_apis/serviceendpoint/endpoints?api-version=6.1-preview.4") -Headers $Header -ErrorAction Stop).Value
    }

    $ARMServiceEndpoints = $ServiceEndpoints | where-object {$_.type -eq "azurerm"}

    $ExecutionHistory = $ARMServiceEndpoints | foreach-object {
    $Endpoint = $_
    $ReferencedADOProject = $_.serviceEndpointProjectReferences.projectReference.name
    $EndpointId = $_.id
    (Invoke-RestMethod ($UriOrga + $ReferencedADOProject + "/_apis/serviceendpoint/" + $EndpointId + "/executionhistory?top=10&api-version=6.0-preview.1") -Headers $Header).value
    }

    $ExecutionHistory | foreach-object {
        $EndpointId = $_.endpointId
        $Endpoint = $ARMServiceEndpoints | Where-Object {$_.id -eq $EndpointId}
            [pscustomobject]@{
            ServiceConnectionId         = $_.endpointId
            ServiceConnectionName       = $Endpoint.name
            AzScopeLevel                = $Endpoint.data.scopeLevel
            AzSubscriptionId            = $Endpoint.data.subscriptionId
            AzSubscriptionName          = $Endpoint.data.subscriptionName
            AppObjectId                 = $Endpoint.data.appObjectId
            ServicePrincipalId          = $Endpoint.data.spnObjectId
            ServicePrincipalPerm        = $Endpoint.data.azureSpnPermissions
            ExecutionPlanType           = $_.data.planType
            ExecutionPipelineId         = $_.data.definition.id
            ExecutionPipelineName       = $_.data.definition.name
            ExecutionRunId              = $_.data.owner.id
            ExecutionRunName            = $_.data.owner.name
            ExecutionId                 = $_.data.id
            ExecutionStartTime          = $_.data.startTime
            ExecutionEndTime            = $_.data.finishTime
            ExecutionResult             = $_.data.result
            }
    }
}
