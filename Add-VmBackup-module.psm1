Function Add-VmBackup
{
    param(
        [String]$vm = $null, 
        [String]$backupLocation = $null, 
        [String]$ftpBackupServer = $null, 
        [Int32]$ftpBackupServerPort = 21, 
        [String]$ftpUsername = $null, 
        [String]$ftpPassword = $null, 
        [String]$ftpBackupPath = ""
        )

    function Archive($sourcedir, $zipFileName )
    {
	    Add-Type -Assembly System.IO.Compression.FileSystem;

	    $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal;

	    [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir, $zipfilename, $compressionLevel, $false);
    }

    function Ftp($filePath, $ftpServer, $ftpPort, $ftpUsername, $ftpPassword, $ftpPath, $destinationFileName)
    {
	    $ftpPath = $ftpPath.Trim('/')
	    $ftpFullPath = $ftpServer + ":" + $ftpPort + "/" + $ftpPath + "/"

	    $webClient = (new-object System.Net.WebClient);
		
	    try
	    {
		    $webClient.Credentials = (new-object System.Net.NetworkCredential($ftpUsername, $ftpPassword))
		    $webClient.UploadFile($ftpFullPath + $destinationFileName, "STOR", $filePath);
	    }
	    finally
	    {
		    if($webClient -ne $null ) { $webClient.Dispose() }
	    }
    }

    #local variables

    $ftpBackupServer = $ftpBackupServer.ToLower()

    if( -not $ftpBackupServer.StartsWith("ftp://") ) { $ftpBackupServer = "ftp://" + $ftpBackupServer.trim('/') }


    set ftpBackupPath ("/" + $ftpBackupPath.Trim('/') + "/" + $vm);


    set-location $backupLocation
    $backupDate = ([System.DateTime]::Now.ToString("yyyyMMdd"))
    $snapshotName = ("bu_" + $backupDate)

    set snapshotArchiveFilePath ([System.IO.Path]::Combine($backupLocation, ($vm + "-" + $backupDate + ".zip")))

    set backupLocation ([System.IO.Path]::Combine($backupLocation, $vm + "-" + $backupDate))

    try
    {
	    if( test-path $backupLocation ) { remove-item -recurse -force $backupLocation }

	    New-item $backupLocation -type Directory | out-null
	    checkpoint-vm $vm -SnapshotName $snapshotName -Passthru | Export-VMSnapshot -path $backupLocation
	   
	    if( test-path $snapshotArchiveFilePath ) { del $snapshotArchiveFilePath }

	    Archive $backupLocation $snapshotArchiveFilePath

	    remove-item -Recurse -Force $backupLocation

	    Ftp $snapshotArchiveFilePath $ftpBackupServer $ftpBackupServerPort $ftpUsername $ftpPassword $ftpBackupPath ($backupDate + ".zip")

	    remove-item $snapshotArchiveFilePath

        Get-VMSnapshot -vmname $vm | where {$_.Name -like "bu_*" -and $_.creationTime -lt ([System.DateTime]::Today).Subtract((new-object System.TimeSpan(7, 0, 0, 0)))} | Remove-VMSnapshot
    }
    catch
    {
	    echo $_.Exception.Message;
	    # handle error here
    }

}



