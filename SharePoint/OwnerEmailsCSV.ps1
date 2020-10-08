$result = @()
$exportto = "C:\Users\u753693\Desktop\CLTScrapeResults.csv"
$sites = Import-Csv "C:Users\u753693\Desktop\CLTScrape.csv"

function RetrievePermOwners(){
    foreach($collection in $sites){
        Connect-PnPOnline -Url $collection.url -CurrentCredentials
        Write-Host "You are connected to" $collection.url
        $ownergroup = Get-PnPGroup -AssociatedOwnerGroup | Get-PnPGroupMembers
        $result += $collection.url + ',' + $ownergroup.Email | Out-file $exportto -Append
    }
}

RetrievePermOwners

#Use text to columns with correct delimiters to format


<#
##Variables for Processing
$SiteUrl = "https://crescent.sharepoint.com/sites/poc/"
$ListName="Employee"
$ExportFile ="c:\Scripts\ListRpt.csv"
$UserName="Salaudeen@crescent.com"
$Password ="Password goes here"
 
#Setup Credentials to connect
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))
 
#Set up the context
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl) 
$Context.Credentials = $credentials
  
#Get the List
$List = $Context.web.Lists.GetByTitle($ListName)
 
#Get All List Items
$Query = New-Object Microsoft.SharePoint.Client.CamlQuery
$ListItems = $List.GetItems($Query)
$context.Load($ListItems)
$context.ExecuteQuery()
 
#Array to Hold List Items 
$ListItemCollection = @() 
 
#Fetch each list item value to export to excel
 $ListItems |  foreach {
    $ExportItem = New-Object PSObject 
    $ExportItem | Add-Member -MemberType NoteProperty -name "Title" -value $_["Title"]
    $ExportItem | Add-Member -MemberType NoteProperty -Name "Department" -value $_["Department"]
   
    #Add the object with above properties to the Array
    $ListItemCollection += $ExportItem
 }
#Export the result Array to CSV file
$ListItemCollection | Export-CSV $ExportFile -NoTypeInformation





<#
$web = Get-PnPWeb -Includes RoleAssignments
foreach($ra in $web.RoleAssignments) {
    $member = $ra.Member
    $loginName = get-pnpproperty -ClientObject $member -Property LoginName
    $rolebindings = get-pnpproperty -ClientObject $ra -Property RoleDefinitionBindings
    write-host "$($loginName) - $($rolebindings.Name)"
    write-host 
} 

$ra.Member.LoginName.split('\')[-1] #gives uNumber of user

$credentials = Get-Credential
Connect-PnPOnline -Url "http://teamsites.teamworks.wellsfargo.net/sites/cb-032/005" -Credentials $credentials
$web = Get-PnPWeb -Includes RoleAssignments
foreach($ra in $web.RoleAssignments) {
    $member = $ra.Member
    $loginName = get-pnpproperty -ClientObject $member -Property LoginName
    $rolebindings = get-pnpproperty -ClientObject $ra -Property RoleDefinitionBindings
    write-host "$($loginName) - $($rolebindings.Name)"
    write-host 
}
#><#
$web = Get-PnPWeb -Includes RoleAssignments
foreach($ra in $web.RoleAssignments) {
    $member = $ra.Member
    $loginName = Get-PnPProperty -ClientObject $member -Property LoginName
    $rolebindings = Get-PnPProperty -ClientObject $ra -Property RoleDefinitionBindings
    if(($ra.RoleDefinitionBindings.Name -like '*Full Control*') -and ($ra.Member.LoginName.split('\')[-1] -like "u*")){
        $uNumber = $ra.Member.LoginName.split('\')[-1]
        Write-Host $uNumber
    }
}
#>