Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
Function Set-SPSiteVersionHistoryLimit()
{
    param
    (
        [Parameter(Mandatory=$true)] [string] $SiteURL,
        [parameter(Mandatory=$false)][int]$VersioningLimit = 5
    )
    Try {
        #Get Credentials to connect 
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)     
         
        #Get All Lists from the Web
        $Lists = $Ctx.Web.Lists
        $Ctx.Load($Lists)
        $Ctx.ExecuteQuery()
          
        #Array to exclude system libraries
        $SystemLibraries = @("Form Templates", "Preservation Hold Library", "Images","Site Collection Documents", 
                            "Site Collection Images","Style Library","Theme Gallery","Master Page Gallery",
                            "Solution Gallery","Workflows","List Template Gallery","Converted Forms",
                            "wfpub","wfsvc","Access Requests","SPJS-DynamicFormsForSharePoint",
                            "SPJS-vLookupSettings", "MicroFeed")
        #Get All document libraries
        $DocumentLibraries = $Lists | Where {$_.Hidden -eq $False -and $_.Title -notin $SystemLibraries}
         
        #Set Versioning Limits
        ForEach($Library in $DocumentLibraries)
        {
            #for a list of the methods and properties: Get-Member -InputObject $Library
            #Get the Library's versioning settings
            $Library.Retrieve("EnableVersioning")
            $Ctx.ExecuteQuery()
 
            #powershell to set limit on version history
            If($Library.EnableVersioning -and $Library.MajorVersionLimit -ne $VersioningLimit)
            {
                #Set versioning limit
                $Library.MajorVersionLimit = $VersioningLimit
                $Library.EnableMinorVersions = $false
                $Library.Update()
                $Ctx.ExecuteQuery() 
                Write-host -f Green "Version History Settings has been Updated on '$($Library.Title)'"
            }
            Else
            {
                Write-host -f Yellow "Version History is turned off (and unchanged) at '$($Library.Title)'"
            }
        }
    }
    Catch {
        Write-host -f Red "Error:" $_.Exception.Message
    }
}
  
#Call the function to set version history limit
$csvimport = Import-Csv -Path 'C:\Users\u753693\Desktop\VersioningQCC2.csv'
foreach($site in $csvimport){
    write-host $site.Url
    Set-SPSiteVersionHistoryLimit -SiteURL $site.Url
}
