#Build: 120 : Copyright 2016 Gilgamech Technologies

#To run this, put these in your profile, and set them correctly: 
# 
# $ProgramsPath = "C:\Program Files (x86)" #Program files root folder.
# $DocsPath = "C:\User\MyNameHere\Documents" #Documents root folder.
# $UtilPath = "C:\utilities" #Where you keep your utilities.
# $modulesFolder = $ProgramsPath + "\Projects\Powershell" #Powershell Modules
# $PowerGIL = $modulesFolder + "\PowerGIL.ps1" #PowerGIL location, usually in the Modules folder.
# $VIMPATH = $UtilPath + "\vim74\vim.exe" #Assumes you have Vim for Win64.
# $NppPath = $ProgramsPath + "\N++\notepad++.exe" #Assumes you have Notepad++
# 
# Import-Module $PowerGIL
# 
# 
# 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 
#++++ DON'T TOUCH ANYTHING DOWN HERE OR YOU MIGHT BREAK IT +++ 


$PowerGILWebAddr = "http://Gilgamech.com/PS1/PowerGIL.ps1"

#Download the current one to get the web version. Maybe should ask to update here?
$PowerGILWebPS1 = try {
Invoke-WebRequest $PowerGILWebAddr
}catch{
0
} #end try

#Get the build version from the header of your $PowerGIL
[int]$PowerGILBuildVersion = ([int](gc $PowerGIL)[0].split(":")[1])
#If you could get the web version, dig out its build number. Else return 0.
if ($PowerGILWebPS1 -eq 0){
$PowerGILWebVersion = 0
} else {
[int]$PowerGILWebVersion = ($PowerGILWebPS1.Content.split(":")[1])
} #end if




#Hate VIM
Function Edit-Vimrc
{
    vim $home\_vimrc
}
Function Vim-PowerGIL
{
    vim $PowerGIL
}


#Love Notepad++
Set-Alias note  $NppPATH
Function Note-Profile
{
    note $profile
}
Function Note-PowerGIL
{
    note $PowerGIL
}


function New-Powershell([switch] $Elevated)
{
if ($Elevated) {
start-process powershell -verb runas
} else {
Start-Process powershell #-verb runas
} #end if
} #end function


function Restart-Powershell([switch] $Elevated)
{
if ($Elevated) {
start-process powershell -verb runas
} else {
Start-Process powershell #-verb runas
} #end if
#start-process powershell
exit
} #end function



Function Get-PowerGILVersion([switch] $notes)
{
if  ($PowerGILWebVersion -eq $PowerGILBuildVersion) {
write-host -foregroundcolor "Green" "PowerGIL Build:" $PowerGILBuildVersion
}else{
write-host -foregroundcolor "Yellow" "Installed PowerGIL Build: " -nonewline; Write-Host -f "Red" $PowerGILBuildVersion 
write-host -foregroundcolor "Yellow" "Website PowerGIL Build: " -nonewline; Write-Host -f "Green" $PowerGILWebVersion 
Write-Host "You should run " -nonewline; Write-Host -f "Red" "Update-PowerGIL " ;
}#end if

if ($notes){
Write-host -foregroundcolor "Yellow" "
Latest changes: 
Added Get-PowerGILVersion
Fixed build numbers too!
" 
} #end if
} #end function Get-PowerGILVersion
Get-PowerGILVersion #Leave this here - it's so we can run this just after we create it, when loading the module.


function Update-PowerGIL
{
Write-host "" #Blank line
Copy-Item $PowerGIL "$PowerGIL.bak"
Write-host "$PowerGIL.bak created." -foregroundcolor "Yellow"
$diffpct = 0.25 #How much larger of update should we accept? 
#Get PowerGIL from web
#get web Build length, math it out
$PowerGILWebPS1.content > $home\webgil2.txt
$gcon = gc $home\webgil2.txt | select -Skip 1 

$PowerGILVer = "#Build: "  + $PowerGILWebVersion + " : Copyright 2016 Gilgamech Technologies"
$PowerGILVer > $home\webgil2.txt

$gcon[0..($gcon.Length - 6)] >> $home\webgil2.txt
$gcon[-5..-1] | where { $_ -ne "" } >> $home\webgil2.txt

#Write-host "" #Blank line
$webfinal = gc -raw $home\webgil2.txt
remove-item $home\webgil2.txt
$weblen = $webfinal.Length
write-host "Length of $PowerGILWebAddr is" $weblen "bytes and has Build" $PowerGILWebVersion

#get local Build length
$loclen = (cat -raw $PowerGIL).Length
write-host "Length of $PowerGIL is" $loclen "bytes and has Build" $PowerGILBuildVersion

#If the new one is within 50% of the file size of the new one, update.
$diffouput = ( $diffpct *  100  )  

if ((($weblen / $loclen) -gt $diffpct) -and (($loclen / $weblen) -gt $diffpct)){
write-host "File lengths are within $diffouput`%, procesing update. :D" -foregroundcolor "Green"
$webfinal   | Out-File -Encoding "UTF8" $PowerGIL
#$Firstline | Out-File -Encoding "UTF8" $PowerGIL
#$PowerGILWebPS1.Content | select -skip 1 | Out-File -Encoding "UTF8" -Append $PowerGIL
} else {
write-host "File length differences are greater than $diffouput`%, aborting update. D:" -foregroundcolor "Red"
} #end if
Write-host "" #Blank line
} #end function



<# if ($updatePowerGIL.length - $null){
$Firstline = "#Stuff.net.says"
$Firstline > $PowerGIL
($updatePowerGIL.Content | select -skip 1) >> $PowerGIL
write-host "PowerGIL update successful. :D "
#If we downloaded something, write it. 
}else {
write-host "No update for PowerGIL D:"
} #end if 
} #end function
 #>


function Output-DevNewBuild
{
$filename = (get-date -format MM-dd-HH-mm)
md .\Builds\$filename
ls -File | foreach {Copy-Item $_ .\Builds\$filename }
}



function Get-DevFlags
{
foreach ($file in (ls -file)) {
write-host $file ; 
write-host "has changes:"; 
gc $file | select-string "(FLAG)" 

} #end foreach
} #end function



function Leet-H4x0r
{
$leet = @'
............................................________ 
....................................,.-'"...................``~., 
.............................,.-"..................................."-., 
.........................,/...............................................":, 
.....................,?......................................................, 
.................../...........................................................,} 
................./......................................................,:`^`..} 
.............../...................................................,:"........./ 
..............?.....__.........................................:`.........../ 
............./__.(....."~-,_..............................,:`........../ 
.........../(_...."~,_........"~,_....................,:`........_/ 
..........{.._$;_......"=,_......."-,_.......,.-~-,},.~";/....} 
...........((.....*~_......."=-._......";,,./`..../"............../ 
...,,,___.`~,......"~.,....................`.....}............../ 
............(....`=-,,.......`........................(......;_,,-" 
............/.`~,......`-...................................../ 
.............`~.*-,.....................................|,./.....,__ 
,,_..........}.>-._...................................|..............`=~-, 
.....`=~-,__......`,................................. 
...................`=~-,,.,............................... 
................................`:,,...........................`..............__ 
.....................................`=-,...................,%`>--==`` 
........................................_..........._,-%.......` 
..................................., 
'@
$leet
}



function Test-PingJob
{
start-job { 
ping -t 8.8.8.8 
} ; 
$pingjob = (get-job).id[-1] ; 
while ((get-job $pingjob ).hasmoredata) {
receive-job $pingjob 
} #end while 
} #end function



function Get-Clipboard([switch] $raw) {
#https://www.bgreco.net/powershell/get-clipboard/
	if($raw) {
		$cmd = {
			Add-Type -Assembly PresentationCore
			[Windows.Clipboard]::GetText()
		}
	} else {
		$cmd = {
			Add-Type -Assembly PresentationCore
			[Windows.Clipboard]::GetText() -replace "`r", '' -split "`n"
		}
	}
	if([threading.thread]::CurrentThread.GetApartmentState() -eq 'MTA') {
		& powershell -Sta -Command $cmd
	} else {
		& $cmd
	}
} #end function


function Stop-Explorer
{
get-process explorer | foreach { stop-process $_.id }
} #end function


function Receive-AllJobs
{
foreach ($job in (get-job).id ) { 
while ((get-job $job ).hasmoredata) { 
receive-job $job 
} #end while
} #end foreach
} #end function




function Stop-AllJobs
{
foreach ($job in (get-job).id ) {
stop-job $job
} #end foreach
} #end function



function Watch-Clipboard
{
$cbclip = "test"
while (Get-Clipboard -ne "") { 
if ( (diff (Get-Clipboard) $cbclip ) -ne $null) { 
$cbclip = Get-Clipboard 
$cbclip 
sleep .1
} #end if 
} #end while
} #end function


function Get-WMIDisk ([string]$Drive) {
if ($drive.length -eq 1) {
$filter = ("DeviceID='" + $Drive + ":'")
Get-WmiObject Win32_LogicalDisk -Filter $filter
} else {
Get-WmiObject Win32_LogicalDisk
} #end if 
} #end function



#function Test-NetRange ([ipaddress] )
#{
#$network = "10.250.49."
#$range = 231..249
#foreach ($i in $range) { $testout = test-connection ( $network + $i ) -quiet -count 1 ; write-host ($network + $i) $tes tout}
#foreach ($i in $range) { $testout = test-connection ( $network + $i ) -quiet -count 1 ; write-host ($network + $i) $tes tout}



#}


#Don't leave empty lines at the bottom. Update-PowerGIL is a line eater. 
#Don't leave empty lines at the bottom. Update-PowerGIL is a line eater. 
#Don't leave empty lines at the bottom. Update-PowerGIL is a line eater. 
#Don't leave empty lines at the bottom. Update-PowerGIL is a line eater. 
#Don't leave empty lines at the bottom. Update-PowerGIL is a line eater. 
#Don't leave empty lines at the bottom. Update-PowerGIL is a line eater. 

