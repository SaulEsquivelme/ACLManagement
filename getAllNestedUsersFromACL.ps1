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
