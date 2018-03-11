# powershell
################
The senario in this script is this, we have a atalanssian stack Jira, Confluence,Service desk running on separate VMs, while all of them saving data to a postgres database server, which is on another VM.
So we need to shut down the 
#################
This two powershell script can help Windows VM admin to automate the vm backup and upload them to a backup centre via FTP protocol.

Step1. create a folder which has same name as the file, eg Add-VmBackup in the c:\Program Files\WindowsPowerShell\Modules\ folder. copy the module file to this folder.
Fire up powershell, test it by command "Get-module -ListAvailable", you should find the Add-Vmbackup in the list.
Step2. Then Change 5 line, which is line passing machine names to the variable vms, add multiple vm names separated by comma.
Step3(optional).
