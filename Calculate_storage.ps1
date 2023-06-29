# Connect to Microsoft 365 tenant
Connect-MsolService

# Get all licensed users in the tenant
$licensedUsers = Get-MsolUser -All | Where-Object {$_.isLicensed -eq $true}

# Initialize variables to track storage usage
$totalOneDriveUsage = 0
$totalSharePointUsage = 0
$totalMailboxUsage = 0

# Iterate through each licensed user
foreach ($user in $licensedUsers) {
    # Get OneDrive storage usage for the user
    $oneDriveUsage = (Get-SPOSite -Identity $user.UserPrincipalName -Limit All).StorageUsageCurrent
    $totalOneDriveUsage += $oneDriveUsage

    # Get SharePoint storage usage for the user
    $sharePointUsage = (Get-SPOSite -Identity $user.UserPrincipalName -Limit All | Where-Object {$_.Template -eq "STS#0"}).StorageUsageCurrent
    $totalSharePointUsage += $sharePointUsage

    # Get Exchange mailbox storage usage for the user
    $mailboxUsage = (Get-MailboxStatistics -Identity $user.UserPrincipalName).TotalItemSize.Value.ToBytes()
    $totalMailboxUsage += $mailboxUsage
}

# Convert storage values to human-readable format
$totalOneDriveUsageGB = $totalOneDriveUsage / 1GB
$totalSharePointUsageGB = $totalSharePointUsage / 1GB
$totalMailboxUsageGB = $totalMailboxUsage / 1GB

# Output the results using Write-Host
Write-Host "Total OneDrive storage usage: $($totalOneDriveUsageGB.ToString("N2")) GB"
Write-Host "Total SharePoint storage usage: $($totalSharePointUsageGB.ToString("N2")) GB"
Write-Host "Total Exchange mailbox storage usage: $($totalMailboxUsageGB.ToString("N2")) GB"
