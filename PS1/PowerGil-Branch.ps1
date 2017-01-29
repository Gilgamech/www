function Unzip-File
{
Param(
[String]$Filename,
[Switch]$AllFilesInDirectory

)
$shell=new-object -com shell.application
$CurrentLocation=get-location
$CurrentPath=$CurrentLocation.path
$Location=$shell.namespace($CurrentPath)

"All files " + $AllFilesInDirectory
"Filename " + $Filename
if ($AllFilesInDirectory -eq $false) {
if ($Filename -eq $null) {

"All files " + $AllFilesInDirectory
"Filename " + $Filename

Write-host "Please specify a file or use the -AllFilesInDirectory switch"
break

} else {
$ZipFiles = get-childitem $Filename
} #end inner if 
} else {

$ZipFiles = get-childitem *.zip
} #end outer if

$ZipFiles.count | out-default #Files to process
foreach ($ZipFile in $ZipFiles) {
$ZipFile.fullname | out-default
$ZipFolder = $shell.namespace($ZipFile.fullname)

#Handle errors on non-zip files (FLAG)
$Location.Copyhere($ZipFolder.items())

} #end foreach

} #end Unzip-File


#get-variable -scope local
#get-variable -scope global


#How to split binary into words. Picked up from here during Codejam2016:
#https://codegolf.stackexchange.com/questions/35096/convert-a-string-of-binary-characters-to-the-ascii-equivalents
#-join(-split$s|%{[char][convert]::toint32($_,2)})


#New-SelfSignedCertificate -CertStoreLocation cert:\LocalMachine\My -DnsName "gilgamech.com"
#PS Cert:\> $retsin = ls -Recurse | select friendlyname, pschildname | group friendlyname
#$retsin.group | sort friendlyname
#15 % 3

function Get-ModulatorMutilation
{
Param(
[Parameter(Mandatory=$True,Position=1)]
[int]$j
)

foreach ($i in 1..$j) {$j % $i }

}


#Param(
#   [Parameter(Mandatory=$True,Position=1)]
#   [object]$Message#,
#   [Parameter(Mandatory=$True,Position=2)]
#   [string]$file
#)

filter FlipTo-Text
{
#output file
[array]$objection = @{} ; 
$textlen = $g.Length/8

for ($i=0; $i -le ($textlen -1) ;$i++){
#[int]$n = Read-Host -prompt "N$i"
#pass data
$objection += "" | select Letter #, SheepN #, Type ; 

#Math out the index of the new line
$arrayspot = ( $objection.length -1 )
#Populate Name
$objection[ $arrayspot ].Letter = $g
#$objection[ $arrayspot ].SheepN = $n

} #end for


%{ 
[System.Text.Encoding]::UTF8.GetString([System.Convert]::ToInt32($_,2)) 
}

#output
for ($i=1; $i -le $T ;$i++){
Write-Host "Case #$($objection[ $i ].case): $($objection[ $i ].SheepN)"
} #end for

} #end FlipTo-Text

Filter Flip-TextToBinary
{
$bytes = [System.Text.Encoding]::Unicode.GetBytes($string)
([System.Text.Encoding]::Unicode.GetString($bytes))
[System.Text.Encoding]::UTF8.GetBytes($_) | %{  [System.Convert]::ToString($_,2).PadLeft(8,'0') }
} #end FlipTo-Binary

Filter Flip-BinaryToText
{
%{ 
#$Bytes = [System.Text.Encoding]::UTF8.GetString($_) 
#$Bytes = [System.Text.Encoding]::Unicode.GetBytes($_)
$EncodedText =[System.Convert]::ToInt32($_,2)
#$EncodedText =[Convert]::ToBase64String($Bytes)
$EncodedText
}
} #end FlipTo-Text

Filter Flip-TextToHex
{
$_.ToCharArray() | FOREACH {
 ([CONVERT]::tostring([BYTE][CHAR]$_,16))
} #end foreach
} #end Flip-HexToText


Filter Flip-BinaryToHex
{
$_.ToCharArray() | FOREACH {
 ([CONVERT]::tostring($_,16))
} #end foreach
} #end Flip-HexToText




filter FileSizeBelow($size) { if ($_.length -le $size) { $_ } }

#Found here:
#https://social.technet.microsoft.com/Forums/windowsserver/en-US/ae97c5d7-b9ad-4d8e-9f78-dccfc6a937fe/how-to-execute-powershell-commmand-stored-inside-variable?forum=winserverpowershell
function Unzip-Stuff
{
$shell=new-object -com shell.application
$CurrentLocation=get-location
$CurrentPath=$CurrentLocation.path
$Location=$shell.namespace($CurrentPath)
$ZipFiles = get-childitem *.zip
$ZipFiles.count | out-default
foreach ($ZipFile in $ZipFiles)
{
$ZipFile.fullname | out-default
$ZipFolder = $shell.namespace($ZipFile.fullname)
$Location.Copyhere($ZipFolder.items())
}
}



function Get-SteamServers
{
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ipaddress]$serveraddr,
   [Parameter(Mandatory=$True,Position=2)]
   [int]$serverport,
   [switch]$Info,
   [switch]$Player,
   [switch]$Rules
)

#Build message - Info, Player, Rules
if ($Info){
#$bytes = "FF FF FF FF 54 53 6F 75 72 63 65 20 45 6E 67 69 6E 65 20 51 75 65 72 79 00"
$bytes =  "ÿÿÿÿTSource Engine Query" | Flip-TextToBytes -a 
$bytes += "00"
}

if ($Player){
#$bytes = "FF FF FF FF 55 FF FF FF FF"
$bytes =  'ÿÿÿÿUÿÿÿÿ' | Flip-TextToBytes -a 
}

if ($Rules){
#$bytes = "FF FF FF FF 55 FF FF FF FF"
$bytes =  'ÿÿÿÿUÿÿÿÿ' | Flip-TextToBytes -a 
}

#Build endpoint
    $endpoint = New-Object System.Net.IPEndPoint ($serveraddr,$serverport)
#I found this online, I don't really know what it does lol
    $udpclient= New-Object System.Net.Sockets.UdpClient
#Timeout in ms
	$udpclient.client.receiveTimeout = 3000
#Convert the request
#	$bytes =  $Message | Flip-TextToBytes -a 
#Not sure what we're doing with BytesSent here.
    $bytesSent=$udpclient.Send($bytes,$bytes.length,$endpoint)

Write-Host -fore green "Querying server at: $($endpoint.address.ToString()):$($endpoint.Port.ToString())"
$atime = get-date
#Listen for the challenge response
$content=try {	
$udpclient.Receive([ref]$endpoint)  
} catch {
Write-Host -fore red "Connection timed out."
} #finally {}

#If the challenge isn't empty, print as Bytes then print as ASCII
if ($content) {
$btime = get-date
Write-Host -fore green "Challenge response received, took $([int]($btime-$atime).totalmilliseconds) ms."
	$content
	$contxt = Flip-BytesToText $content -a
	-join $contxt
	
#Modify challenge to be response	
	$content[4] = "U" | Flip-TextToBytes -a
Write-Host -fore green "Challenge response created:"
	$content
	$conrsp = Flip-BytesToText $content -a
	-join $conrsp
Write-Host -fore green "Sending  challenge response, awaiting payload."
#Send the challenge response back as a handshake
    $payload = $udpclient.Send($content,$content.length,$endpoint)

#If the payload isn't empty, print as Bytes then print as ASCII
if ($payload) {
$ctime = get-date
Write-Host -fore green "Payload received, took $([int]($ctime-$btime).totalmilliseconds) ms. Total time $([int]($ctime-$atime).totalmilliseconds) ms."
	$payload
	$paytxt = Flip-BytesToText $payload -a
	$paytxt
} else {
Write-Host -fore red "No payload received."
} #if payload

} #if context

#Close the UDP client
$udpclient.Close()
} #end Get-SteamServers
#Get-SteamServers 10.0.0.5 27015 -Info
#Get-SteamServers 72.251.237.140 27015 -Info






