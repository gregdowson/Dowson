$GrouptoAdd = "LCL-Admins ServiceNow Discovery"
$GroupObj = [ADSI]"WinNT://localhost/Administrators"
$GroupObj.Add("WinNT://ds.usfca.edu/$GrouptoAdd")