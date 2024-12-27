# Define the shared drive path
$sharedDrivePath = "\\companydomain.com\Folder1\Folder2"

# Get the ACL from the shared drive
$acl = Get-Acl -Path $sharedDrivePath

$regex = "OU=([^,]+)"

# Function to get members of a group
function Get-GroupMembers {
    param (
        [string]$groupName
    )
    try {
        $group = Get-ADGroup -Identity $groupName
        $members = Get-ADGroupMember -Identity $groupName
        return $members
    } catch {
        $members = Get-ADGroup -identity $groupName -Properties Members | Select-Object -ExpandProperty Members | Get-ADObject
        return $members
    }
}

function Is-Group {
    param (
        [string]$identity
    )
    try {
        $group = Get-ADGroup -Identity $identity -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}


# Iterate through the ACL entries
foreach ($access in $acl.Access) {
    $identityReference = $access.IdentityReference
    $identityName = $identityReference.Value.Substring(6)
    if (Is-group -identity $identityName){
        Write-Host "Group: $identityReference"
        $members = Get-GroupMembers -groupName $identityName
        foreach ($member in $members) {
            if ($member -match $regex){
                $ou = $matches[1]
            }
            Write-Host "MemberName: $($member.Name), OU:$($ou)"
        }
    } else {
        Write-Host "User: $identityReference"
    }
} 
