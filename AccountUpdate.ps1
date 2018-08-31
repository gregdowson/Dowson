Import-Module ActiveDirectory  

$users = Import-Csv "C:\Scripts\LCLAdmin Groups\ADusers.csv"
foreach ($user in $users) {
Get-ADUser -Filter "samaccountname -eq '$($user.samaccountname)'" -Properties * -SearchBase "DC=ds,DC=usfca,DC=edu"|
Set-ADUser -givenname $($user.firstname) -surname $($user.surname)}