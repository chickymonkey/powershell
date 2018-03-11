
##don't change this script, it is been tested working perfectly!!!###
#change the vm names in the line 4, the script will loop in the order

$vms="monitoring","servicedesk","confluence","jira software"
#shutdown service-desk
#shutdown smtp-relay
#shutdown confluence
#shutdown jira
#shutdown database

$continueLoop = $true

#$stoppedVm = @{}

foreach ($vm in $vms)
{
    try
    {
        if( $continueLoop ) 
        {
        stop-vm $vm 
        $continueLoop = !$LASTEXITCODE 
        #$stoppedVm += $vm
        }  
    }
    catch
    {    
        throw $_
    }
}

# backup smtp-relay first then start it
#try
#{
#    stop-vm smtp-relay

#    Add-VmBackup -vm smtp-relay -backupLocation C:\tmp\VMs -ftpBackupServer "ftp://path.to.your.ftp.server" -ftpUsername hypervbackup -ftpPassword your password -ftpBackupPath '/machines/'
#}
#catch
#{
#}
#finally
#{
#    start-vm smtp-relay
#}

#Then we do the following
#backup database
#backup jira
#backup confluence
#backup service desk

#start database
#start jira
#start confluence
#start service desk


#reverse the array
[array]::Reverse($vms)

##strat all the VMs

$continueLoop = $true

foreach ($vm in $vms)
{
    try
    {
        if( $continueLoop )
        {
            Add-VmBackup -vm $vm -backupLocation C:\tmp\VMs -ftpBackupServer "ftp://path.to.your.ftp.server" -ftpUsername hypervbackup -ftpPassword your password -ftpBackupPath '/machines/'
            start-vm $vm
            $continueLoop = !$LASTEXITCODE
        }
    }
    catch
    {
        throw $_
    }
}



