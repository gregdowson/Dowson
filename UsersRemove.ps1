$members= gc "C:\scripts\members.txt"
Foreach ($member in $members){
Remove-ADGroupMember -Identity "Student Activities" -Members $member}
