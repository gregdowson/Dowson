$servers= gc servers.txt
Foreach ($server in $servers)
{Invoke-Command -ComputerName $server -FilePath .\AdminGroupAdd.ps1}