<#
.NOTES
Author: Katy Millard
ID: 011055280

.SYNOPSIS

.DESCRIPTION

.INPUTS

.OUTPUTS

.EXAMPLE
./Restore.ps1
#>
   
#Create AD OU 
$ADRoot = (Get-ADDomain).DistinguishedName
$DnsRoot = (Get-ADDomain).$DnsRoot
$OUCanonicalName = "Finance"
$OUDisplayName = "Finance"
$ADPath = "OU=$($OUCanonicalName),$($ADRoot)"

if (-Not([ADSI]::Exists("LDAP://$($ADPath)"))) {
    New-ADOrganizationalUnit -Path $ADRoot -Name $OUCanonicalName -DisplayName $OUDisplayName -ProtectedFromAccidentalDeletion $false
    Write-Host -ForegroundColor Cyan "[AD]: $($OUCanonicalName) OU Created"
}
else {
    Write-Host "$($OUCanonicalName) Already exists"
}

# Read CSV File into a table
$NewADUsers = Import-Csv $PSScriptRoot\financePersonnel.csv

$numberNewUsers = $NewADUsers.Count
$count = 1

# Iterate over each row in the table
ForEach ($ADUser in $NewADUsers)
{
    # Assign variables to column labels
    $First = $ADUser.First_Name 
    $Last = $ADUser.Last_Name 
    $Name = $First + " " + $Last
    $SamAcct = $ADUser.samAccount
    $UPN = "3$($SamAcct)@$($DnsRoot)"
    $Postal = $ADUser.Postalcode
    $Office = $ADUser.OfficePhone
    $Mobile = $ADUser.MobilePhone
    
    $status = "[AD]: Adding AD Users: $($Name) ($($count) of $($numberNewUsers))"
    Write-Progress -Activity 'C411 Task 2 - Restore' -Status $status -PercentComplete (($count/$numberNewUsers) * 100)

    # Create AD User with given values
    New-ADUser -GivenName $First -Surname $Last -Name $Name -SamAccountName $SamAcct -UserPrincipalName $UPN -DisplayName $Name -PostalCode $Postal -OfficePhone $Office -MobilePhone $Mobile -Path $ADPath
    
    # Increment counter
    $count++
}

Get-ADUser -Filter * -SearchBase "ou=Finance,dc=consultingfirm,dc=com" -Properties DisplayName, Postalcode, OfficePhone, MobilePhone > .\ADResults.txt

Write-Host -ForegroundColor Cyan "[AD]: Active Directory Tasks Complete" 

