#Credentials and site variables used in connect-pnponline command
$Credentials = Get-Credential
$Site= "REDACTED"
Connect-PnPOnline -Url $Site -Credentials $credentials

#ImportList
$ListData = Import-CSV "C:\Users\u753693\Desktop\SiteCollectionReport3.6.csv"
 
#Function for List Import
function ImportList{
    foreach ($Row in $ListData){
        #Specify the list here using the list's display name
        Add-PnPListItem -List "PowerShell" -Values @{
        #put SP Field Internal Name on left, csv column name on right
        "Title"= $Row.'Title';
        "SiteAddress"= $Row.'Site Address';
        "PeoplePicker"= $Row.'People Picker';
        "Choice"= $Row.'Choice'
        }
    }
}

#Run the function
ImportList
