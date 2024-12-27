#ACL cutover after migration 
Get-Date
$shares = Get-Content "C:\Users\User1\Documents\Sharelist.txt"
#$shares = @("\\companydomain.com\Folder1\Folder2")

$account = "Domain\ADGroup"
$account2 = "BUILTIN\Administrators"
$out_noFormat = @()
$out_noValid = @()

foreach ($share in $shares){
if ($share -like "\\*"){
    $share
    if (Test-Path $share){
        #Disable inheritance
        $acl = Get-Acl $share
        $acl.SetAccessRuleProtection($true, $true)
        (Get-Item $share).SetAccessControl($acl)
        #Set-Acl $share $acl

        #Check and add DFSadm-GlobalAdmins account
        $acl = Get-Acl $share
        $accountExists = $acl.Access | Where-Object {$_.IdentityReference -eq $account}
        if ($accountExists -eq $null){
            Write-Host $account "Adding to ACL"
            $permission  = $account,"FullControl","ContainerInherit, ObjectInherit","None","Allow"
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
            $acl.AddAccessRule($accessrule)
            (Get-Item $share).SetAccessControl($acl)
            #Set-Acl $share $acl
            Write-Host $account "added to ACL"
            }
    
        #Modify ACL to ReadAndExecute
        $acl = Get-Acl $share
        $users = $acl.Access | Where-Object {$_.IdentityReference -ne $account -and $_.IdentityReference -ne $account2 -and $_.FileSystemRights -ne "ReadAndExecute, Synchronize"}
        if ($users -ne $null){
            foreach ($user in $users){
                $user.IdentityReference
                $permission  = $user.IdentityReference,"ReadAndExecute","ContainerInherit, ObjectInherit","None","Allow"
                $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
                $acl.SetAccessRule($accessrule)
            }
            (Get-Item $share).SetAccessControl($acl)
            #Set-Acl $share $acl
        }

        #Folder rename
        $newname = $share + "_DONOT_USE__GoTo_NewLocation"
        Rename-Item -Path $share -NewName $newname
        }
        else{
            Write-Host "Folder doesnt exist: "$share
            $out_noValid += $share
            Start-Sleep -Seconds 5
        }
}
else{
    Write-Host "Not valid path: "$share
    $out_noFormat += $share
    Start-Sleep -Seconds 5
    }
#break
}
Get-Date 
