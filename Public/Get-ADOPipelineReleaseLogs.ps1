
Function Get-ADOPipelineReleaseLogs
{
<#
 .Synopsis
  Downloads the logs of release pipelines and store them into single ZIP files.

 .Description
  ADO API allows to download the detailed logs of the agent job(s) from release pipelines.
  This function download all of them and store them into a specific folder as ZIP file(s).
 .Example
   # Save all log files from release pipelines in a specific folder:
   Get-ADOPipelineReleaseLogs -ExportFolder "./AgentLogs/Releases"
#>

[Cmdletbinding()]
Param(
    [Parameter(Mandatory = $false)][string]$ExportFolder="./"
)

    $AzDOProjects = (Invoke-RestMethod ($UriOrga + "_apis/projects?api-version=6.0") -Headers $Header -ErrorAction Stop).Value
    
    $Releases = $AzDOProjects | foreach-object {
        $AzDoProjectName = $_.name
        $URL = "https://vsrm.dev.azure.com/$AzDoOrganizationName/$AzDoProjectName/_apis/release/releases?api-version=6.0"
        (Invoke-RestMethod $URL -Headers $Header -ErrorAction Stop).Value
    }

    $Releases | foreach-object {
        $AzDoProjectName = $_.projectReference.Name
        $ReleaseId = $_.id
        $LogFileName = $AzDoProjectName + "_" + $_.Name + ".zip"
        $URL = "https://vsrm.dev.azure.com/$AzDoOrganizationName/$AzDoProjectName/_apis/Release/releases/$ReleaseId/logs?api-version=6.0-preview.2"
        Invoke-RestMethod $URL -Headers $Header -ErrorAction Stop -ContentType "application/zip" -OutFile ($ExportFolder + "\" + $LogFileName)
    }
}