#ACL data collection
$shares = Get-Content "\\companydomain.com\Folder1\Folder2"
$out_arr = @()

foreach ($share in $shares){
    if ($share -like "\\*"){
        $share
        if (Test-Path $share){
            $shareString = $share.Split("\")
            $shareFolder = $shareString[-2] + "_" + $shareString[-1] + ".csv"
            $acl = Get-Acl $share
            $acl.Access | Export-Csv $shareFolder
        }
        else{
            $out_arr += $share
        }
    }
    else{
        Write-Host "No valid path: "$share
    }
}
$out_arr 

#account_deletion

$computerName = $env:computername
$user = "ONTAPUser"
$securestring = Get-Content -Path "C:\Users\User1\Documents\ONTAPUser.txt" | ConvertTo-SecureString
$credential = new-object management.automation.pscredential $user, $securestring
$clusters = Get-Content "C:\Users\User1\Documents\ClusterList.txt"
$results = "$env:TMP\"
$results_arr = @()

$usertoDelete = "*userName*"

foreach ($cluster in $clusters) {
	Connect-NcController $cluster -Credential $credential
	$results_arr += Get-NcUser -Vserver $cluster | Where-Object {$_.UserName -like $usertoDelete} | Select-Object UserName,Application,RoleName,AuthenticationMethod,SecondAuthenticationMethod,Vserver
	#Get-NcUser -Vserver $cluster | Where-Object {$_.UserName -like $usertoDelete} | Remove-NcUser -Confirm:$false
}

if ($results -ne $null){
    $file = "DeletedAccounts.csv"
    $results_arr | Export-Csv -Path $file
	$emailTo = "user.lastname@companydomain.com"
    $subject = $usertoDelete + " User accounts deleted"
    $body = "Please find attached csv report with user account deleted."
	$file
	Function-HtmlEmail $subject $emailTo $body $file
}


