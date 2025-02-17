 
<#
   .\NestedGroups_Extract.ps1  -groupname "Ad-Group-Name" `
                                -Domain "corp.us.com" `
                                -Properties "SamAccountName,CanonicalName,mail,UserPrincipalName" `
                                -filepath "C:\temp\ADgroup-extract.csv"


#>   
   Param (
    [Parameter(Mandatory=$true)]
    [string]$groupname,

    [Parameter(Mandatory=$true)]
    [string]$domain,

    [Parameter(Mandatory=$true)]
    [string]$Properties,
    
    [Parameter(Mandatory=$true)]
    [string]$filepath
)

#---------------Start of Script----------------------------------------------
    
If(!(Test-Path $Filepath)){ 
    if($filepath.Split("/")[-1] -like "*.CSV"){
        Try{
                New-Item -Path $filepath -ItemType File
        }
        Catch{
                Write-host "Error: $($Error[0].exception.message)" -ForegroundColor Red
                exit
        }
    }
    Else{
            Write-host "Please enter file name of .CSV format" -ForegroundColor Red
            exit
    }
}
#---------------Start of Script----------------------------------------------

    $group0s = (Get-ADGroup -Identity $groupname -Server $Domain).DistinguishedName
    $listUsers = @()
    $refGroups = @()
    $loop = 10
    $ctr = 0
    do {
        $ctr += 1
        $group1s = @()
        foreach ($group0 in $group0s) {
            $Domain0  = $group0.Substring("$group0".IndexOf("DC=")).Replace("DC=","").Replace(",",".")
            $members = (Get-ADGroup $group0 -Properties members -Server $Domain0 | select -ExpandProperty members)
            #$members
 #           pause
            foreach ($member in $members)
             {#$member
             #PAUSE
                $Domain  = $member.Substring("$member".IndexOf("DC=")).Replace("DC=","").Replace(",",".")
                $ObjectClass = (Get-ADObject $member -Server $Domain).ObjectClass
                Switch ($ObjectClass) {
                    "user" {
                            $listUsers += $member
                    }
                    "group" {
                        if ($refGroups -notcontains $member) {
                            $refGroups += $member
                            $group1s += $member
                        }
                     }
                }
            }
            if ($Group1s.count -eq 0) {
                $loop = 0
            }
            else {
                $group0s = $group1s
                $loop = $loop - 1
            }
        }
    }
    while ($loop -gt 0)
    $listUsers = ($listUsers | Sort-Object -Unique)
    If(($listUsers | Measure-object).count -gt "0"){
        $GC = (Get-ADDomainController -Filter {IsGlobalCatalog -eq $true} | Select-Object -ExpandProperty hostname)[0] + ":3268"
        $Propertiesarray = $Properties.split(",")
        $listUsers |  ForEach-Object { 
            Get-ADUser -Identity $_ -Properties $Propertiesarray -Server $GC  | Select-Object $Propertiesarray |
                    Export-Csv $filepath -Append -NoTypeInformation
        }
    }
    else{
            Write-Host "the group has Zero Users" -ForegroundColor Yellow
    }
PAUSE


