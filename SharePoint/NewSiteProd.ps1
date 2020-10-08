#Use Module from within common folder
Import-Module "$PSScriptRoot\..\..\Common\SpsCommon\SharePointPnPPowerShell2016"

Write-Host " "
Write-Host "---------------------------"
$ListSite= "http://solutions.entshpt.wellsfargo.net/sites/wftrc/001/"
$error.clear()

Connect-PnPOnline -Url $ListSite -CurrentCredentials

<#############################
    
Pulling list items where Status = In Progress

##############################>

$item = Get-PnPListItem -Web "/sites/wftrc/001" -List "Auto New Site Requests" -Query "<View>
                <Query>
                    <Where>
                        <And>
                            <Eq>
                                <FieldRef Name = 'Status'/>
                                <Value Type='Text'>Assigned</Value>
                            </Eq>
                            <IsNotNull>
                                <FieldRef Name='SecondaryName' />
                            </IsNotNull>
                        </And>
                    </Where>
                </Query>
            </View>"

<#############################
    
Loop through pulled items

##############################>

foreach($row in $item){

    Write-Host " "
    Write-Host $row["Title"] "is in progress"
    

    <#############################
    
    pulling info from sp list

    ##############################>

    $newsitetitle = $row["Title"]
    $newsiteurlname = $row["SiteURL"]
    $newsitedescription = $row["DescriptionMulti"]
    $sitecollectionurl = $row["SiteCollectionURL"]
    $owneremail = $row["PrimaryEmail"]
    $accountinfo = $row["PrimaryLogin"]
    $fullname = $row["PrimaryName"]
    $ownersgroupname = $row["Title"] + " Owners"
    $membersgroupname = $row["Title"] + " Members"
    $visitorsgroupname = $row["Title"] + " Visitors"
    $sponsorlogin = $row["SponsorLogin"]
    $sponsorname = $row["SponsorName"]
    $sponsoremail = $row["SponsorEmail"]
    $secondarylogin = $row["SecondaryLogin"]
    $secondaryname = $row["SecondaryName"]
    $secondaryemail = $row["SecondaryEmail"]
    $aunumber = $row["AU"]
    $siteLOB = $row["LOB"]

    <# this part is unused, would have been good if we had permissions to run "New-PnPTerm"
    $division = $row["DivisionColumnName"]
    $DivisionTermPath = 'Self Site Creator|DIV|' + $division
    $Divtaxterm = Get-PnPTaxonomyItem -TermPath $DivisionTermPath
    if($Divtaxterm){
        $DivName = $Divtaxterm.Name
        $Divid = $Divtaxterm.Id.Guid
        Set-PnPPropertyBagValue -Key tmp_sitedivision -Value $sitedivisionfullvalue
    }
    else{
        New-PnPTerm -TermGroup "Self Site Creator" -TermSet "DIV" -Name $division
        Set-PnPPropertyBagValue -Key tmp_sitedivision -Value $sitedivisionfullvalue
    }
    #>

    <#############################
    
    formatting propertybag info from sp list

    ##############################>

    #format owner name to last, first in pbag
    $fullnamesplit = $fullname.split()
    $last = $fullnamesplit[-1]
    $firstname = $fullnamesplit[0..($fullnamesplit.length - 2)]
    $lastfirst = $last + ', ' + $firstname
    #format secondary owner name
    $secondarynamesplit = $secondaryname.split()
    $secondarylast = $secondarynamesplit[-1]
    $secondaryfirstname = $secondarynamesplit[0..($secondarynamesplit.length - 2)]
    $secondarylastfirst = $secondarylast + ', ' + $secondaryfirstname
    #format sponsor name
    $sponsorsplit = $sponsorname.split()
    $sponsorlast = $sponsorsplit[-1]
    $sponsorfirst = $sponsorsplit[0..($sponsorsplit.length - 2)]
    $sponsorname = $sponsorlast + ', ' + $sponsorfirst
    #format owner account to include two '\'
    $accountinfo = $accountinfo.Split('\') -join('\\')
    $sponsorlogin = $sponsorlogin.Split('\') -join('\\')
    $secondarylogin = $secondarylogin.Split('\') -join('\\')


    #stringbuilder for people pbags
    $firstpart = '[{"email":"'
    $secondpart = '","loginName":"'
    $thirdpart = '","name":"'
    $lastpart = '"}]'
    $tmpsiteownervalue = $firstpart + $owneremail + $secondpart + $accountinfo + $thirdpart + $lastfirst + $lastpart
    $tmpsitesponsorvalue = $firstpart + $sponsoremail + $secondpart + $sponsorlogin + $thirdpart + $sponsorname + $lastpart
    $tmpsecondaryownervalue = $firstpart + $secondaryemail + $secondpart + $secondarylogin + $thirdpart + $secondarylastfirst + $lastpart

    #Get site collection relative URL
    $scsplit = $sitecollectionurl.split('/')
    $screlative = '/' + ($scsplit[-3,-2] -join '/')
    $mpserverrelativeurl = $screlative + '/_catalogs/masterpage/Teamworks_System.master'

    #to get site relative of new site !WARNING site collection needs to have ending '/'
    $newurlsplit = ($sitecollectionurl + $newsiteurlname).split('/')
    $siterelative = '/' + ($newurlsplit[-3,-2,-1] -join '/')
    $siterelativehomepage = $siterelative + "/SitePages/Home.aspx"

    #get full new site url
    $newsitefullurl = 'http://teamsites.teamworks.wellsfargo.net' + $siterelative

    #connect to parent site
    Connect-PnPOnline -Url $sitecollectionurl -CurrentCredentials

    #create new site command, enable Edit this site feature, create permsetup groups
    New-PnPWeb -Title $newsitetitle -Url $newsiteurlname -Description $newsitedescription -Locale 1033 -Template "STS#0" -BreakInheritance
    Enable-PnPFeature -Identity 73cc8611-9ec0-4cf0-92ea-2f16eb808a86 -Web $siterelative
    New-PnPGroup -Title $ownersgroupname -Web $siterelative
    New-PnPGroup -Title $membersgroupname -Web $siterelative
    New-PnPGroup -Title $visitorsgroupname -Web $siterelative

    Set-PnPGroup -Identity $ownersgroupname -SetAssociatedGroup Owners -AddRole "Full Control" -Owner $ownersgroupname -Web $siterelative
    Set-PnPGroup -Identity $membersgroupname -SetAssociatedGroup Members -AddRole "Contribute" -Owner $ownersgroupname -Web $siterelative
    Set-PnPGroup -Identity $visitorsgroupname -SetAssociatedGroup Visitors -AddRole "Read" -Owner $ownersgroupname -Web $siterelative

    Add-PnPUserToGroup -LoginName $owneremail -Identity $ownersgroupname -Web $siterelative
    Add-PnPUserToGroup -LoginName $secondaryemail -Identity $ownersgroupname -Web $siterelative


    #set property bag values given from list
    Set-PnPPropertyBagValue -Key FollowLinkValue -Value TRUE -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_siteurl -Value $newsiteurlname -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_sitetitle -Value $newsitetitle -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_localsitesearch -Value TRUE -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_siteowner -Value $tmpsiteownervalue -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_sitesponsor -Value $tmpsitesponsorvalue -Web $siterelative 
    Set-PnPPropertyBagValue -Key tmp_siteurlfull -Value $newsitefullurl -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_overridebrowsertitle -Value $newsitetitle -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_additionalsiteowners -Value $tmpsecondaryownervalue -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_siteau -Value $aunumber -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_sitefriendlyname -Value $newsitetitle -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_toplinkfromparent -Value false -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_sitekeywords -Value '[{"name":"SharePoint","id":"bf8653cc-a0ab-47b4-9677-0d05581fed88"}]' -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_sitelob -Value $sitelob -Web $siterelative
    #wordmark is important - set with value of site title in workflow.
    Set-PnPPropertyBagValue -Key tmp_wordmarktextsecondline -Value $newsitetitle -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_topnavigationintoparent -Value false -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_sitedescription -Value $newsitedescription -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_userpermissions -Value true -Web $siterelative
    Set-PnPPropertyBagValue -Key vti_mastercssfilecache -Value 'corev15app.css' -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_leftnavigationintoparent -Value false -Web $siterelative
    Set-PnPPropertyBagValue -Key tmp_sitetemplateid -Value 2 -Web $siterelative


    #set master page on new site
    Set-PnPMasterPage -MasterPageServerRelativeUrl $mpserverrelativeurl -Web $siterelative
    Remove-PnPWebPart -ServerRelativePageUrl $siterelativehomepage -Title "Get started with your site"
    Set-PnPWebPermission -User "CA02180_UTIL_T_TST01" -RemoveRole 'Full Control' -Web $siterelative
    Write-Host $row["Title"] " is finished."
    Connect-PnPOnline -Url $newsitefullurl -CurrentCredentials
    $web = get-pnpweb
    $web.RequestAccessEmail = $owneremail
    $web.Update()
    $web.Context.ExecuteQuery()

    if($owneremail -And !$error){
        $body1 = @'
        <HTML><HEAD><TITLE>User Completed</TITLE> <META name=GENERATOR content="MSHTML 11.00.10570.1001">
        </HEAD> <BODY> <DIV style="WIDTH: 100%"> <TABLE style="HEIGHT: 35px; WIDTH: 100%"> <TBODY> <TR> 
        <TD style="HEIGHT: 35px; WIDTH: 100%; TEXT-ALIGN: left; PADDING-LEFT: 10px; BACKGROUND-COLOR: #00698c"> 
        <P style="FONT-SIZE: 16pt; FONT-FAMILY: georgia; COLOR: white">New SharePoint 2013 Site Request Completed</P>
        </TD></TR></TBODY></TABLE> <DIV style="MARGIN-LEFT: 20px"> <P style="FONT-FAMILY: verdana; COLOR: #44464a">
'@
        $body2 = @'
        </P> 
        <P style="FONT-FAMILY: verdana; COLOR: #44464a">This message is to inform you that your request for a new SharePoint 2013 
        site has been completed based on the information you provided. Your new site is available at: 
'@
        $body3 = @'
        </P> 
        <P style="FONT-FAMILY: verdana; COLOR: #44464a">Training resources and how-to guides are available on the 
        <A href="http://portal.teamworks.wellsfargo.com/Teamworks/TeamSites/Pages/default.aspx">Team Sites Learning Resources</A> 
        page or the&nbsp;<A href="https://solutions.sp.wellsfargo.net/sites/spcop/Communities/SPCoP">Community of Practice</A> site.
        </P> <P style="FONT-FAMILY: verdana; COLOR: #44464a">Follow the options below to check the status of your tickets or submit a 
        new ticket. If you have questions regarding your new site or the request process, please contact us at 
        <A href="mailto:eit.sps@wellsfargo.com">eit.sps@wellsfargo.com</A></P> 
        <TABLE style="CURSOR: pointer; HEIGHT: 45px"> <TBODY> <TR> <TD style="OVERFLOW: hidden; CURSOR: pointer; HEIGHT: 45px; 
        BORDER-RIGHT: white 20px solid; WIDTH: 160px; VERTICAL-ALIGN: middle; TEXT-ALIGN: center; BACKGROUND-COLOR: rgb(0,115,55)">
        <A style="FONT-SIZE: 16pt; TEXT-DECORATION: none; FONT-FAMILY: verdana; COLOR: white" 
        href="http://solutions.entshpt.wellsfargo.net/sites/wftrc/001/Lists/autositerequests/NewForm.aspx?Source=http://solutions.entshpt.wellsfargo.net/sites/wftrc/001/SitePages/dashboard.aspx">
        <STRONG style="FONT-WEIGHT: normal">New Ticket</STRONG></A> </TD> 
        <TD style="OVERFLOW: hidden; CURSOR: pointer; HEIGHT: 45px; WIDTH: 160px; VERTICAL-ALIGN: middle; TEXT-ALIGN: center; BACKGROUND-COLOR: rgb(0,105,140)">
        <A style="FONT-SIZE: 16pt; TEXT-DECORATION: none; FONT-FAMILY: verdana; COLOR: white" href="http://solutions.entshpt.wellsfargo.net/sites/wftrc/001/SitePages/dashboard.aspx">
        <STRONG style="FONT-WEIGHT: normal">Dashboard</STRONG></A> </TD></TR></TBODY></TABLE></DIV></DIV></BODY></HTML>
'@
$body = $body1 + $FullName + $body2 + $newsitefullurl + $body3
$eitmailbox = 'EIT SPS <eit.sps@wellsfargo.com>'

Send-MailMessage -From $eitmailbox -To $owneremail -Subject 'New Site Request Completed' -Body $body -BodyAsHtml -SmtpServer 'SMTP.AZURE.WELLSFARGO.NET'
    }
}


<#############################
    
Change Status of list items - if no error, In progress to Done

##############################>


if(!$error){
    Connect-PnPOnline -Url $ListSite -CurrentCredentials
    $items = Get-PnPListItem -Web "/sites/wftrc/001" -List "Auto New Site Requests" -Query "<View>
        <Query>
            <Where>
                <Eq>
                    <FieldRef Name = 'Status'/>
                        <Value Type='Text'>Assigned</Value>
                </Eq>
            </Where>
        </Query>
    </View>"

    foreach($row in $items){
    $fix = Set-PnPListItem  -Web "/sites/wftrc/001" -List "Auto New Site Requests" -Identity $row -Values @{
        "NewSiteURL" = $newsitefullurl ; "Status" = "New Site Request Completed" ; "VariableHold" = "Done"
        }
     
    }
    Write-Host "All Statuses have been updated."
}

<#############################
    
If error, log error present to list.

##############################>

else{
    Write-Host "There has been an error - sites may have been created but list status was not changed."
    Connect-PnPOnline -Url $ListSite -CurrentCredentials
    $items = Get-PnPListItem -Web "/sites/wftrc/001" -List "Auto New Site Requests" -Query "<View>
        <Query>
            <Where>
                <Eq>
                    <FieldRef Name = 'Status'/>
                        <Value Type='Text'>Assigned</Value>
                </Eq>
            </Where>
        </Query>
    </View>"

    foreach($row in $items){
    $fix = Set-PnPListItem  -Web "/sites/wftrc/001" -List "Auto New Site Requests" -Identity $row -Values @{
        "Error" = "There has been an error. Check log for details."
        }
     
    }
}