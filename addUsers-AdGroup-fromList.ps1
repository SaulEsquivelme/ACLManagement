$names = Get-Content -Path "C:\Users\User1\Documents\Add users to a group\UserList.txt"
$servers = @("companydomain.com", "server1.companydomain.com", "server2.companydomain.com")
$AdGroup = Get-AdGroup ADGroup
foreach ($name in $names){
    foreach ($server in $servers){
        $user = Get-AdUser $name -Server $server
        if ($user){
        $user.Name
        Add-AdGroupMember -Identity $AdGroup -Members $user
        break
        }
    }
} 
