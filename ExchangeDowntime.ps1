#### Version #0.1
###This is a script to assist in the Exchange bi-monthly downtime###
##You will need to download the RU and place it in the correct folder in order to properly use this script##
##Created by Orrin Dabney
write-host " "
write-host "Welcome to my downtime script. This will assist you in any exchange downtime by running the needed steps for you." -foregroundcolor blue
start-sleep -Seconds 2
write-host " "
write-host "Below is a list of each Exchange server with its IP." -foregroundcolor blue
start-sleep -Seconds 2
write-host " "
#$IP_Array = import-csv "C:\temp\scripts\ip.txt"
# foreach ($IP in $IP_Array){
#if ($IP.IP -eq "xx.xxx.xxx.xxx")
# {write-host "SERVERNAME"$IP.IP}
#Elseif ($IP.IP -eq "xx.xxx.xxx.xxx")
# {write-host "SERVERNAME" $IP.IP}
#elseif ($IP.IP -eq "xx.xxx.xxx.xxx")
# {write-host "SERVERNAME" $IP.IP
# }
#}
write-host " "
write-host " "
$mounted = Get-Mailboxdatabase |select-object server
#$mountedserver=$mounted.server#
write-host "The databases are on:"$mounted""
#We will need to move databases if they are on the server you need to patch.This next command will assist in that process.#
write-host "If the databases are mounted on the server which you are planning your downtime, you must move them to another server in the environment." -ForegroundColor red -BackgroundColor yellow
write-host "THIS WILL CAUSE A TEMPORARY CONNECTION BLIP FOR ANYONE CONNECTED TO THEIR MAILBOXES WHILE MOVING OCCURS!" -ForegroundColor red -BackgroundColor yellow
start-sleep -seconds 3
#$from = read-host "Where are the databases mounted? Example: SERVERNAME"#
# $to = read-host "Where are you moving the databases to?"
#do {Write-host "You must pick a valid server!"} -foregroundcolor red
#until ($to -ne $mounted)
do {
$to = (Read-Host "Type "ready" when you want to continue.")
if ($to -ne '$mounted') {}
}
move-activemailboxdatabase -server $mounted.server -activateonserver $to
write-host "Before we proceed, now is a good time to set the Exchange server to maintenance mode in SCOM. I will wait here..."
write-host " "
write-host " "
do {
$input = (Read-Host "Type "ready" when you want to continue.")
if ($input -ne '') {}
}
until ($input -eq 'ready')
#Write-host "Block database activation? Type blocked if yes." -foregroundcolor blue
write-host " "
write-host " "
$exit = exit
do {
$blocked = (Read-Host "Type "blocked" when you want to continue ("exit" to quit).")
if ($blocked -ne '') {}
}
until (($blocked -eq 'blocked') -or ($blocked -eq 'exit'))
set-mailboxserver $mounted.server -databasecopyautoactivationpolicy $blocked
#Once the replication is blocked, begin server maintenance mode.#
cd $exscripts
write-host "Warning, the following script will place the server you specify into maintenance mode!" -foregroundcolor red -backgroundcolor yellow
# The script will automatically do the following tasks for you:#
#Calls Suspend-MailboxDatabaseCopy on the database copies.#
#Pauses the node in Failover Clustering so that it cannot become the Primary Active Manager. (not necessarily the server hosting databases. The script moves this if it is the PAM)#
#Suspends database activation on each mailbox database.#
#Sets the DatabaseCopyAutoActivationPolicy to Blocked on the server.#
#Moves databases and cluster group off of the designated server.#
.\Startdagservermaintenance.ps1 -servername $mounted.server
Write-host "Stopping ForeFront"
stop-service fsccontroller -force
cd "C:\Program Files (x86)\Microsoft Forefront Protection for Exchange Server"
fscutility.exe /disable
write-host "Stopping RightFax service"
stop-service rfexchconn
#Now it is time to install the RU#
#cd "D:\temp\"
#$RU = read-host "What RU file would you like to run? Type the full"
#$ru.msp
#End of Script