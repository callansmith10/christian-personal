$sitestoread = Import-Csv "C:Users\u753693\Desktop\fastadminread.csv"
foreach ($site in $sitestoread){
    Connect-PnPOnline -Url $site.url -CurrentCredentials
    $subs = Get-PnPSubWebs -Includes HasUniqueRoleAssignments, RequestAccessEmail
    if ($subs){

        foreach ($sub in $subs){
            if ($sub.HasUniqueRoleAssignments){
                write-host $sub.ServerRelativeUrl " has unique role assignments - not set to read"
            }
            else{
                $fullSubUrl = "REDACTED" + $sub.ServerRelativeUrl
                Write-Host $fullSubUrl " is inheriting permissions"
                Connect-PnPOnline -Url $fullSubUrl -CurrentCredentials
                $subconnection = Get-PnPWeb -Includes HasUniqueRoleAssignments, RequestAccessEmail
                $AccessRequestEmail = $subconnection.RequestAccessEmail
                #stop sub from inheriting
                $subconnection.BreakRoleInheritance($true, $true)
                $subconnection.Update()
                $subconnection.context.Load($subconnection)
                $subconnection.context.ExecuteQuery()
                #sets sub accessreq
                $subconnection.RequestAccessEmail = $AccessRequestEmail
                $subconnection.Update()
                $subconnection.Context.ExecuteQuery()
                Write-Host $fullSubUrl "is no longer inheriting permissions. AR from" $AccessRequestEmail "to" $subconnection.RequestAccessEmail
            }
        }
        Connect-PnPOnline -Url $site.url -CurrentCredentials
    }
    #delete unique permissions
    Connect-PnPOnline -Url $site.url -CurrentCredentials
    $connection = get-pnpweb -Includes HasUniqueRoleAssignments,RequestAccessEmail
    $connection.ResetRoleInheritance()
    $connection.Update()
    $connection.context.Load($connection)
    $connection.context.ExecuteQuery()
    #stop inheriting
    $connection.BreakRoleInheritance($false, $true)
    $connection.Update()
    $connection.context.Load($connection)
    $connection.context.ExecuteQuery()
    #this could work to only get associated permsetup groups in perms
    $ownergroup = Get-PnPGroup -AssociatedOwnerGroup
    $membergroup = Get-PnPGroup -AssociatedMemberGroup
    $visitorgroup = Get-PnPGroup -AssociatedVisitorGroup

    Set-PnPGroup -Identity $ownergroup -AddRole 'Read'
    Set-PnPGroup -Identity $membergroup -AddRole 'Read'
    Set-PnPGroup -Identity $visitorgroup -AddRole 'Read'

    $connection.RequestAccessEmail = 'eit.sps@wellsfargo.com'
    $connection.Update()
    $connection.Context.ExecuteQuery()

    Set-PnPWebPermission -User "redacted" -RemoveRole 'Full Control'

    Write-Host $site.url " has been set to read."
}
