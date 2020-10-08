$sites = Import-Csv "C:Users\u753693\Desktop\sites.csv"
$exportto = "C:\Users\u753693\Desktop\owners.csv"
$result = @()
foreach($site in $sites){
    connect-pnponline -Url $site.Url -CurrentCredentials
    $ctx = get-pnpweb -Includes RequestAccessEmail, LastItemModifiedDate

    $spoctx = Get-PnPContext
    $LastItemModifiedDate = $ctx.LastItemModifiedDate

    $spoctx.Load($spoctx.web.RoleAssignments.Groups)
    Invoke-PnPQuery -ErrorAction Stop
    $webGroups = $spoctx.web.RoleAssignments.Groups

    $FullControl = $webGroups.Title -match 'owner'
    if(!$FullControl){
        $result += $site.url + ',' + ' ' + ',' + ' ' + ',' + ' ' + ',' + $ctx.RequestAccessEmail + ',' + $LastItemModifiedDate | Out-file $exportto -Append
    }
    else{
    foreach($name in $FullControl){
        $members = get-pnpgroupmembers -Identity $name
        foreach($member in $members){
            $result += $site.url + ',' + $member.Title + ',' + $member.Email + ',' + $member.LoginName + ',' + $ctx.RequestAccessEmail + ',' + $LastItemModifiedDate | Out-file $exportto -Append
        }
    }
}
}