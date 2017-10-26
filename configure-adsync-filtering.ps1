# https://docs.microsoft.com/en-us/azure/active-directory/connect/active-directory-aadconnectsync-configure-filtering

# first, disable the scheduler
Set-ADSyncScheduler -SyncCycleEnabled $False

### make changes in Synchronization Service Manager ###

### run a Full Import and Delta Synchronization on the On-Prem AD connector ###

### run an Export on the Azure AD connector ###

# finally, re-enable the scheduler
Set-ADSyncScheduler -SyncCycleEnabled $True
