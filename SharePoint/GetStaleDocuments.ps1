<#
$SiteURL= 'REDACTED'
  
#Connect to PnP Online
Write-Host "Scanning" $ListName

Connect-PnPOnline -Url $SiteURL -CurrentCredentials
$ctx = Get-PnPWeb -Includes LastItemModifiedDate, Lists
$LastItemModifiedDate = $ctx.LastItemModifiedDate

foreach($list in $ctx.Lists){
 
#Get All Files from the document library - In batches of 1000
$ListItems = Get-PnPListItem -List $List.Title -PageSize 1000 | Where {$_["FileLeafRef"] -like "*.*"}
  
#Loop through all documents
$DocumentsData=@()
ForEach($Item in $ListItems)
{
    #Collect Documents Data
    $DocumentsData += New-Object PSObject -Property @{
    FileName = $Item.FieldValues['FileLeafRef']
    FileURL = $Item.FieldValues['FileRef']
    LastModified = $Item.FieldValues['Last_x0020_Modified']
    WhoModified = $Item.FieldValues['Editor']
    }
    $LastModdedDateTime = [datetime]::ParseExact($Item.FieldValues['Last_x0020_Modified'].Split('T')[0], 'yyyy-MM-dd', $null)
    If ($LastModdedDateTime.ToShortDateString() -le (Get-Date).AddDays(-365)){
        Write-Host "Stale! File Name:" $Item.FieldValues['FileLeafRef'] '- Modified by' $item.FieldValues['Editor'].LookupValue $LastModdedDateTime.ToShortDateString()
    }
}
}#>







Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
Function Get-SPStaleDocs()
{
    param
    (
        [Parameter(Mandatory=$true)] [string] $SiteURL
    )
    Try {
        Connect-PnPOnline -Url $SiteURL -CurrentCredentials
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
                            "SPJS-vLookupSettings", "MicroFeed", "Site Assets", "Theme Gallery", "Site Pages", "Pages",
                            "Announcements")
        $BadExtensions = @("bmml", "sql", "", "gif","one","onetoc2","aspx","cs","css","dat","db",
                           "default", "dwp", "htm", "html", "ini", "js", "master", "preview", "sas", "webpart", "wsds", "xml",
                           "xsd", "xsl", "asm", "ico", "lic", "license", "mht", "pyd", "rb", "rdl", "rdp", "rsd", "sh",
                           "sqldoc", "udcx", "usr", "xmi")
        #Get All document libraries
        $DocumentLibraries = $Lists | Where {$_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $False -and $_.Title -notin $SystemLibraries}
         
        #Set Versioning Limits
        ForEach($Library in $DocumentLibraries){
            $ListItems = Get-PnPListItem -List $Library.Title -PageSize 2000 | Where{$_["FileLeafRef"] -like "*.*"}

            ForEach($Item in $ListItems){
                write-host $Item.FieldValues['FileLeafRef']
                #Collect Documents Data
                #$LastModdedDateTime = [datetime]::ParseExact($Item.FieldValues['Last_x0020_Modified'].Split('T')[0], 'yyyy-MM-dd', $null)
                $LastModdedDateTime = $Item.FieldValues['Modified']
                If (($LastModdedDateTime -lt (Get-Date).AddDays(-1095)) -and $Item.FieldValues['FileLeafRef'].Split('.')[-1] -notin $BadExtensions){
                    $result += $Library.Title + ',' + $Item.FieldValues['FileLeafRef'] + ',' + $LastModdedDateTime.ToShortDateString() + ',' + $item.FieldValues['Editor'].LookupValue | Out-file $exportto -Append
                    Write-Host "Stale! File Name:" $Item.FieldValues['FileLeafRef'] '- Modified by' $item.FieldValues['Editor'].LookupValue $LastModdedDateTime.ToShortDateString()
                }
            }
        }
    }
    Catch {
        Write-host -f Red "Error:" $_.Exception.Message
    }
}
  
#Call the function to set version history limit
$result = @()
$exportto = "C:\Users\u753693\Desktop\AutoStaleDocuments.csv"
$ListSite = "REDACTED"
$eitmailbox = 'EIT SPS <REDACTED>'
Connect-PnPOnline -Url $ListSite -CurrentCredentials
$listsiteitems = Get-PnPListItem -Web "REDACTED" -List "StaleAutomation" -Query "<View>
                <Query>
                    <Where>
                        <Eq>
                            <FieldRef Name='Status' />
                            <Value Type='Choice'>Waiting</Value>
                        </Eq>
                    </Where>
                </Query>
            </View>"
foreach($row in $listsiteitems){
    $site = $row["Title"]
    $requester = $row["Email"]
    Get-SPStaleDocs -SiteURL $site

    $body1 = @'
    <HTML><HEAD><TITLE>User Completed</TITLE> <META name=GENERATOR content="MSHTML 11.00.10570.1001">
    </HEAD> <BODY> <DIV style="WIDTH: 100%"> <TABLE style="HEIGHT: 35px; WIDTH: 100%"> <TBODY> <TR> 
    <TD style="HEIGHT: 35px; WIDTH: 100%; TEXT-ALIGN: left; PADDING-LEFT: 10px; BACKGROUND-COLOR: #00698c"> 
    <P style="FONT-SIZE: 16pt; FONT-FAMILY: georgia; COLOR: white">Stale Content Report Completed</P>
    </TD></TR></TBODY></TABLE> <DIV style="MARGIN-LEFT: 20px"> <P style="FONT-FAMILY: verdana; COLOR: #44464a">
'@
    $body2 = @'
    </P> 
    <P style="FONT-FAMILY: verdana; COLOR: #44464a">This message is to inform you that your request for a stale content 
    report has been completed based on the information you provided. The report is attached to the email. 
'@
    $body3 = @'
    </P> 
    <P style="FONT-FAMILY: verdana; COLOR: #44464a">Training resources and how-to guides are available on the 
    <A href="REDACTED">Team Sites Learning Resources</A> 
    page or the&nbsp;<A href="REDACTED">Community of Practice</A> site.
    </P> <P style="FONT-FAMILY: verdana; COLOR: #44464a">Follow the options below to check the status of your tickets or submit a 
    new ticket. If you have questions regarding your stale content report or the request process, please contact us at 
    <A href="mailto:REDACTED">REDACTED/A></P> 
    <TABLE style="CURSOR: pointer; HEIGHT: 45px"> <TBODY> <TR> <TD style="OVERFLOW: hidden; CURSOR: pointer; HEIGHT: 45px; 
    BORDER-RIGHT: white 20px solid; WIDTH: 160px; VERTICAL-ALIGN: middle; TEXT-ALIGN: center; BACKGROUND-COLOR: rgb(0,115,55)">
    <A style="FONT-SIZE: 16pt; TEXT-DECORATION: none; FONT-FAMILY: verdana; COLOR: white" 
    href="REDACTED">
    <STRONG style="FONT-WEIGHT: normal">New Ticket</STRONG></A> </TD> 
    <TD style="OVERFLOW: hidden; CURSOR: pointer; HEIGHT: 45px; WIDTH: 160px; VERTICAL-ALIGN: middle; TEXT-ALIGN: center; BACKGROUND-COLOR: rgb(0,105,140)">
    <A style="FONT-SIZE: 16pt; TEXT-DECORATION: none; FONT-FAMILY: verdana; COLOR: white" href="REDACTED">
    <STRONG style="FONT-WEIGHT: normal">Dashboard</STRONG></A> </TD></TR></TBODY></TABLE></DIV></DIV></BODY></HTML>
'@
$body = $body1 + $body2 + $body3
    Send-MailMessage -Attachments $exportto -From $eitmailbox -To $requester -Subject 'SharePoint Stale Content Report' -Body $body -BodyAsHtml -SmtpServer 'REDACTED'
}
