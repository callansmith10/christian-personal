$sussite = "http://solutions.entshpt.wellsfargo.net/sites/wftrc/"

Connect-PnPOnline -Url $sussite -CurrentCredentials

$item = Get-PnPListItem -Web "/sites/wftrc/RemDev" -List "Site Usage Survey" -Query "<View>
<Query>
   <Where>
      <And>
         <Eq>
            <FieldRef Name='SiteDeleted' />
            <Value Type='Choice'>Live</Value>
         </Eq>
         <Eq>
            <FieldRef Name='CertificationStatus' />
            <Value Type='Choice'>Certification Completed</Value>
         </Eq>
      </And>
   </Where>
</Query>
        </View>"

foreach($row in $item){
    Write-Host $row["Title"] "is in progress"
    #full name slot column populated by workflow
    $owneremail = $row["PrimarySOEmail"]
    $fullname = $row["PrimarySOName"]
    $accountinfo = $row["PrimarySOLogin"]
    #placeholder for specific sus site connection
    $siteurl = $row["Title"]
    $siteau = $row["AU"]
    #full name slot column populated by workflow
    $secondaryemail = $row["SecondarySOEmail"]
    $secondarylogin = $row["SecondarySOLogin"]
    $secondaryname = $row["SecondarySOName"]

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

    #string builder for people bags
    $firstpart = '[{"email":"'
    $secondpart = '","loginName":"'
    $thirdpart = '","name":"'
    $lastpart = '"}]'
    $accountinfo = $accountinfo.Split('\') -join('\\')
    $secondarylogin = $secondarylogin.Split('\') -join('\\')
    $tmpsiteownervalue = $firstpart + $owneremail + $secondpart + $accountinfo + $thirdpart + $lastfirst + $lastpart
    $tmpsecondaryownervalue = $firstpart + $secondaryemail + $secondpart + $secondarylogin + $thirdpart + $secondarylastfirst + $lastpart

    Connect-PnPOnline -Url $siteurl -CurrentCredentials
    Set-PnPPropertyBagValue -Key tmp_siteowner -Value $tmpsiteownervalue
    Set-PnPPropertyBagValue -Key tmp_siteau -Value $siteau
    Set-PnPPropertyBagValue -Key tmp_additionalsiteowners -Value $tmpsecondaryownervalue
    Connect-PnPOnline -Url $sussite -Credentials $credentials
}
$keyword = '[{"name":"Teamsite","id":"1a477740-660c-4486-b386-8b8ce38587e5"}]'