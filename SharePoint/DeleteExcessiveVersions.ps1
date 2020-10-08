$csvimport = Import-Csv -Path 'C:\Users\u753693\Desktop\Versioning.csv'

foreach($site in $csvimport){

    #Config Variable
    $VersionsToKeep = 1
 
    #Connect to PnP Online
    Connect-PnPOnline -Url $site.Url -CurrentCredentials
 
    #Get the Context
    $Ctx= Get-PnPContext
 
    #Get All Items from the List - Exclude 'Folder' List Items
    $ListItems = Get-PnPListItem -List $site.List -Query "<View Scope='RecursiveAll'><Query><Where><Eq><FieldRef Name='FSObjType'/><Value Type='Integer'>0</Value></Eq></Where></Query></View>"
 
    ForEach ($Item in $ListItems)
    {
        #Get File Versions
        $File = $Item.File
        $Versions = $File.Versions
        $Ctx.Load($File)
        $Ctx.Load($Versions)
        $Ctx.ExecuteQuery()
 
        Write-host -f Yellow "Scanning File:"$File.Name
        $VersionsCount = $Versions.Count
        $VersionsToDelete = $VersionsCount - $VersionsToKeep
        If($VersionsToDelete -gt 0)
        {
            write-host -f Cyan "`t Total Number of Versions of the File:" $VersionsCount
            #Delete versions
            For($i=0; $i -lt $VersionsToDelete; $i++)
            {
                write-host -f Cyan "`t Deleting Version:" $Versions[0].VersionLabel
                $Versions[0].DeleteObject()
            }
            $Ctx.ExecuteQuery()
            Write-Host -f Green "`t Version History is cleaned for the File:"$File.Name
        }
    }
}
