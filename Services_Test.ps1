$servers = Get-ADComputer -filter {OperatingSystem -Like "Windows Server*"}  -Property * | ? {$_.DistinguishedName -eq "CN=MP*"} 
foreach ($server in $servers.DistinguishedName)
{
    

    $status = Get-Service -computername $server | ? {$_.DisplayName -eq "Symantec Management Agent"}  
    
    if ($status.Status -eq "Stopped") 
    {
        get-service -name $status.Name -computername $server | set-service -Status Running
        #write-host "Service was Started on $server"
        out-file -filepath d:\scripts\Services_Output.txt -append -inputobject "$($status.Name) was Started on $server"

        # Get-Service | ? {$_.DisplayName -eq "Symantec Management Agent"}

    }  
    else 
    {
        #write-host ""$status.Name" is already Running on $server"
        #out-file -filepath d:\scripts\Services_Output.txt -append -InputObject  "$($status.Name) is already Running on $server"
    }

}