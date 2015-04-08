Add-PSSnapin microsoft.exchange.management.powershell.e2010
$group = Get-DistributionGroupMember partners-all |where-object{$_.RecipientType -eq "MailUniversalSecurityGroup"}

Foreach ($user in $group.Name) {
    Get-DistributionGroupMember $user |ft Name, StateorProvince
    }
    