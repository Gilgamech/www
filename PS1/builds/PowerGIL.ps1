# C:\Dropbox\Public\html5\PS1\PowerGIL.ps1 Build: 260 2016-05-22T08:11:30 Copyright Gilgamech Technologies  
# Update Path: http://Gilgamech.com/PS1/PowerGIL.ps1
# Update Notes:
# 256 : 		#txt2
# 257 : 		[string]$UpdatePath = "http://Gilgamech.com/PS1/PowerGIL.ps1",
# 258 : #Mouse goes roar.
# 259 : #New-If needs -Not flag
# 260 : #Get-Git?

#region FLAG
#Get-Git?
#New-If needs -Not flag
#Need to add Flag-Function 
#Make something that grabs the last thing in your Powershell buffer and clips it. 
#add -Param flags that auto-add a param.  New-ForeachStatement
#need find-subroutine to find stuff inside functions... or a -subroutine flag. 
#need Remove-LinesFromFile 
#New-TryCatchElse 
#New-BeginProcessEnd 
#New-Module shoud make PSD1 and PSM1 
#Have Get-ModuleVersion check Github 
#Need to make like "PowerShiriAdmin" module that runs as admin and beats up the other functions 
#For ($var in (scriptblock)) New-ForStatement
#Unify all New-FunctionStatement functions into one.

#endregion

#region header
#	To run this, put these in your profile, and set them appropriately: 
# 
# $ProgramsPath = "C:\Program Files (x86)" #Program files root folder.
# $DocsPath = "C:\User\MyNameHere\Documents" #Documents root folder.
# $UtilPath = "C:\utilities" #Where you keep your utilities.
# $modulesFolder = $ProgramsPath + "\Projects\Powershell" #Powershell Modules
# $PowerGIL = $modulesFolder + "\PowerGIL.ps1" #PowerGIL location, usually in the Modules folder.
# $VIMPATH = $UtilPath + "\vim74\vim.exe" #Assumes you have Vim for Win64.
# $NppPath = $ProgramsPath + "\N++\notepad++.exe" #Assumes you have Notepad++
# $LynxW32Path = $UtilPath + "\lynx_w32\lynx.exe" #Assumes you have LYNX
# $BuildPath = $ProgramsPath + "\PowerGILVersion"
#
# Import-Module $PowerGIL
# 
#$DontShowPSVersionOnStartup = $true # to turn off Powershell Version display.
# 
# 
#endregion

#region Backup\Update\Restore


Function Update-Module {
	Param(
		[Parameter(Position=1)]
		[string]$FileName = $PowerGIL,
		[string]$Filecontents = (Get-ModuleVersion -ModuleName $FileName -Content)
	) #end Param

<#
		$FilePath = resolve-path $FileName
		$BuildPath = "$(split-path $FilePath)\builds"
		if (!(test-path $BuildPath)) {md $BuildPath}
		copy $FilePath $BuildPath\$FileName.$build
#>

	if ($Filecontents -ne $null) {
	#Try backing it up cuz that soft-fails so we can catch and break there.
	try {
		#Copy-Item $FileName ((split-path $FileName) + "\Builds\$FileName.bak")
		Copy-Item $FileName "$FileName.bak"
	} catch {
		Write-Verbose "File Not Found.";
		1;
		break;
	}; #end try
	Write-Host -f y "$FileName.bak created." -nonewline; Write-Host -f green " Downloading update."
		Insert-TextIntoFile -Filecontents $Filecontents -FileName $FileName
		#ipmo $FileName -force
	} else {
		Write-Host -f red 'Update was empty.'
	}; #end if Filecontents
		
}; #end Update-Module


Function Get-ModuleVersion {
	<#
		.SYNOPSIS
			Returns PowerGIL version number, notes, and Function list.
		.DESCRIPTION
			Author   : Stephen Gillie
			Last edit: 5/17/2016
		.EXAMPLE
			Get-ModuleVersion - Notes
	#>
	Param(
		[string]$ModuleName = $PowerGIL,
		[string]$UpdatePath = ((gc $ModuleName)[1].split(" ")[3]),
		[int]$build = ([int](gc $ModuleName)[0].split(" ")[3]),
		[switch]$notes,
		[switch]$Functions,
		[switch]$Content
	) #end Param
	

		#If the Update Path starts with HTTP, treat as web request, else treat as file path.
		if (((gc $ModuleName)[1].split(":")[1] -match "http*")) {
			$ModuleNameRemotePS1 = try {
				Invoke-WebRequest $UpdatePath
			}catch{
				Write-Verbose "404: File Not Found."
				404
				break
			}; #end try
			#$ModuleNameRemotePS1 = $ModuleNameRemotePS1.content
		} else {
		Write-Host -f red "Can't handle file sources yet, sry."
		break
			#$ModuleNameRemotePS1 = (gc $UpdatePath)
		}; #end if gc ModuleName

		
	if ($Content) {
		return $ModuleNameRemotePS1.Content
	}; #end if Content
	
	
	#If you could get the web version, dig out its build number. Else return 0.
	if ($ModuleNameRemotePS1 -eq 0){
		$ModuleNameWebVersion = 0
	} else {
		[int]$ModuleNameWebVersion = ($ModuleNameRemotePS1.Content.split(" ")[3])
	}; #end if
	
	if  ($ModuleNameWebVersion -eq $build) {
		#If vesions match, show green.
		Write-Host -f green "$ModuleName Build:" $build

	}elseif ($ModuleNameWebVersion -gt  $build){
		#If the web is newer, suggest update.
		Write-Host -f y "Installed $ModuleName Build: " -nonewline; Write-Host -f "Red" $build 
		Write-Host -f y "Website $ModuleName Build: " -nonewline; Write-Host -f green $ModuleNameWebVersion 
		Write-Host "You should run " -nonewline; Write-Host -f "Red" "Restart-Powershell " ;

	}else{
		#if web is older/not found, just show green instead of reporting an error. 
		Write-Host -f green "$ModuleName Build:" $build
	}#end if versions

	#Move $UpdateNotes to Header
	if ($notes){
		Write-Host -f y "Build : Change notes." 
		(gc $ModuleName)[3..7]
	}; #end if

	if ($Functions){
		Write-Host "Functions available:" -f y
		(cat $PowerGIL | where {$_ -like "Function *-*"}).split(" `{") | select -u
	}; #end if

	
}; #end Get-ModuleVersion


Function Insert-TextIntoFile {
<#
.SYNOPSIS
    Inserts the supplied text into the target module at the listed line number.
.DESCRIPTION
    Author   : Gilgamech
    Last edit: 5/20/2016
.EXAMPLE
    Insert-TextIntoFile (New-ForStatement Bees -top -bot ) .\New-Module.ps1 289 
#>
	[CmdletBinding()]
	Param(
		[Parameter(Position=1)]
		$InsertText,
		[Parameter(Position=2)]
		[string]$FileName = "New-Module.ps1",
		[Parameter(Position=3)]
		[ValidateRange(3,65535)]
		[int]$InsertAtLineNumber = 3,
		[array]$Filecontents = (gc $FileName),
		[array]$filesplit = ($Filecontents[0].split(" ") | select -Unique),
		[string]$Copyright = ($filesplit[5] + " " + $filesplit[6] + " " + $filesplit[7] + " " + $filesplit[8] + " " + $filesplit[9]),
		[array]$FileOutput = $Filecontents[0.. ($InsertAtLineNumber -1)],
		[int]$build = $filesplit[3],
		[string]$dtstamp = (get-date -f s)
	) #end Param
	
	#Finish adding text to FileOutput
	if ($InsertText) {
		$build += 1
		Write-Host -f green "$FileName build incremented to $build."

		#3. Rewrite top line.
		$FileOutput[0] = "# $FileName Build: $build $dtstamp $Copyright"
		
		#Move changes up
		$FileOutput[3] = $FileOutput[4]
		$FileOutput[4] = $FileOutput[5]
		$FileOutput[5] = $FileOutput[6]
		$FileOutput[6] = $FileOutput[7]
		
		$FileOutput[7] = "# $build : $InsertText"
		$FileOutput += $InsertText 

		
		#Add build number with comment being last line inserted. (FLAG)
	}; #end if InsertText
	
	$FileOutput += $Filecontents[($InsertAtLineNumber) ..($Filecontents.length)] 
	#Write to file
	[IO.File]::WriteAllLines((Resolve-Path $FileName), $FileOutput) 
	
	#Every time it writes a file, first push a backup. 
	#Backup-Module $FileName
	#Sleep 1
	#Import-Module $FileName -Force
	
}; #end Insert-TextIntoFile


Function Backup-Module {
	[CmdletBinding()]
	Param(
		[Parameter(Position=1)]
		[string]$ModuleName = $PowerGIL,
		[Parameter(Position=2)]
		[string]$FilePath = (resolve-path $ModuleName)
		#$Content = (Get-ModuleVersion $FileName -Content)
	) #end Param
	
	$BuildPath = "$(split-path $FilePath)\builds"
	if (!(test-path $BuildPath)) {md $BuildPath}
	Copy-Item $FilePath ($BuildPath + "\" + $FileName.bak)
	Write-Verbose "$ModuleName backed up." 
}; #end Backup-Module


Function Restore-Module {
	Param(
		[Parameter(Position=1)]
		[string]$ModuleName,
		[Parameter(Position=2)]
		[int]$build = (Get-ModuleVersion $ModuleName).split(" ")[1],
		[int]$RestoreVersion = ($build - 1),
		[string]$FilePath =(resolve-path $ModuleName),
		[string]$BuildPath = "$(split-path $FilePath)\builds"
	) #end Param
	Copy-Item "$BuildPath\$ModuleName.$RestoreVersion" $ModuleName
	Write-Host -f green "$ModuleName restored from backup." 
} #Restore-Module


#endregion 

#region ModuleBuilding
#New-Module
#Compare-Module
#Compare-DevBuilds
#Get-DevFlags


<#
$fg = Get-ModuleVersion -Functions
#New-ForeachStatement fg -top -bot -one -clip -ScriptLines 'Get-CommandsFromFunction $f'
foreach ($f in $fg) {Get-CommandsFromFunction (Find-Function $f)}; #end foreach fg

#Mouse goes roar.

$gg = Get-CommandsFromFunction
$hh = $gg.split("._,$") | select -u #| where {$_ -ne $null}
$hh = $hh[2..($hh.Length)]
#New-ForeachStatement hh -top -bot -one -clip -ScriptLines 'New-Parameter $h'
New-Parameter Top -top; foreach ($h in $hh) {New-Parameter $h}; New-Parameter Last -bot

#>

Function Get-CommandsFromFunction {
#Get-CommandsFromFunction to reverse a function back out into Get-Function and Get-Params etc.
	Param(
		[array]$Function = (Find-Function "Get-CommandsFromFunction"),
		[array]$Prams = ($Function | where {$_ -like '*Param`(*'})
	) #end Param
	if ($Prams) {
		$Prams += "Code to foreach params goes here" 
	} #end if Prams
	
	#Gets all strings from the selection. Need to do for all vars.
	$Strings = $function | foreach {if ($_.gettype().name -eq "string") {$_.split(","" `(`)`[`]") | where { $_ -like "`$*"} | select -Unique}}
	#$Strings = $Function.split(", `)`[`]") | where { $_ -like "`$*"} | select -Unique 
	
	$Prams
	$Strings
	#Write-Host "Parameters: $Prams" 
	#Write-Host "Strings: $Strings" 
	
}; #end Get-CommandsFromFunction


Function New-Module {
#Have it take a line number as input (FLAG)
	Param(
		[string]$FileName = "New-Module.ps1",
		[string]$Copyright =" Copyright Gilgamech Technologies", #Default to GT ;)
		[int]$build = 0,
		[string]$UpdatePath = "http://Gilgamech.com/PS1/PowerGIL.ps1",
		[string]$dtstamp = (get-date -f s),
		[string]$filecontents = "# $FileName Build: $build $dtstamp $Copyright
#Update Path: $UpdatePath
",
		[int]$LineNumber = 3
	)
	
	#$filecontents > $FileName
	#[IO.File]::WriteAllLines((Resolve-Path $FileName), $filecontents) 
	Insert-TextIntoFile -InsertAtLineNumber $LineNumber -FileName $FileName -InsertText (New-Function)
#	Insert-TextIntoFile -InsertAtLineNumber ($LineNumber + 1) -FileName $FileName -InsertText (New-Parameter string1 string 1 -top -bottom)
	
	Write-Host -f green "$FileName build $build created."
	
	#Copy to builds folder with build number appended as extension.
	#Replace with Out-DevBuild (FLAG)
	if (!(test-path .\builds)) {md .\Builds}
	copy $FileName .\builds\$FileName.$build

}; #end New-Module

		
Function New-Function {
<#
.SYNOPSIS
    Writes a new function to a file.
.DESCRIPTION
    Author   : Gilgamech
    Last edit: 5/8/2016
.EXAMPLE
    New-Function .\PowerShiriAdmin.ps1 289 -nos
#>
	Param(
		[string]$FunctionName = "New-Function"
	) #end Param
	$FunctionHeader = @"
<#
.SYNOPSIS
    Inserts the supplied text into the target module at the listed line number.
.DESCRIPTION
    Author   : Gilgamech
    Last edit: 5/9/2016
.EXAMPLE
    New-IfStatement .\PowerShiriAdmin.ps1 289 -nos
#>
"@
	#$functioncontents2 = Find-Function -FunctionName $FunctionName		
	$FunctionContents = "Function $FunctionName {
	
	
}; #end $FunctionName"
	return $FunctionContents
	#Insert-TextIntoFile -InsertAtLineNumber $LineNumber -FileName $FileName -InsertText $FunctionContents
	
}; #end New-Function


Function New-Parameter {
	Param(
		[Parameter(Mandatory=$true,Position=1)]
		[array]$ParameterName = "Parm",
		[Parameter(Position=2)]
		[ValidateSet("string","char","byte","int","long","bool","decimal","single","double","DateTime","xml","array","hashtable","object","switch")]
		[string]$ParameterType,
		[Parameter(Position=3)]
		[int]$PositionValue,
		[array]$ValidateSetList,
		[switch]$SetMandatory,
		[string]$DefaultValue, # = 'DefaultValue',
		[string]$SetValueFromPipelineByPropertyName,
		[switch]$SetValueFromPipeline,
		[switch]$OneLiner,
		[switch]$CmdletBind,
		[switch]$TopHeader,
		[switch]$BottomHeader,
		[switch]$Clipboard,
		[switch]$NoComma
	) #end Param
	$CommaVar = ","
	
	if (!($OneLiner)) {
		$NewLineVar = "`r`n"
		$TabVar = "`t"
	}; #end if OneLiner

	if ($TopHeader) {
	
		if ($CmdletBind) {
			$P2 += $TabVar + "[CmdletBinding()]" + $NewLineVar;
		}; #end if OneLiner
	
		$P2 += $TabVar + "Param(" + $NewLineVar
		
		
if ($PositionValue) {
			$PositionValue = 1
		}; #end if $PositionValue
		
	} else {
		$P2 += ""
	}; #end if TopHeader
	
	foreach ($ParameterNam in $ParameterName) {

		if (($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)  ) {
			$P2 += $TabVar + $TabVar + "[Parameter("
		}; #end if ($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)
			
		if ($SetMandatory) {
			$P2 += "Mandatory=`$$SetMandatory" 
			if (($PositionValue) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)  ) {
				$P2 += $CommaVar
			}; #end if (($PositionValue) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)
			}; #end if $SetMandatory

		if ($PositionValue) {
			$P2 += "Position=$PositionValue" 
			$PositionValue++
			if (($SetMandatory) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)  ) {
				$P2 += $CommaVar
			}; #end if ($SetMandatory) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)
		}; #end if $PositionValue

		if ($SetValueFromPipeline) {
			$P2 += "ValueFromPipeline=`$$SetValueFromPipeline" 
			if (($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipelineByPropertyName)  ) {
				$P2 += $CommaVar
			}; #end if ($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipelineByPropertyName)
		}; #end if $SetValueFromPipeline

		if ($SetValueFromPipelineByPropertyName) {
			$P2 += "ValueFromPipelineByPropertyName=$SetValueFromPipelineByPropertyName" 
			if (($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipeline)) {
				$P2 += $CommaVar
			}; #end if ($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipeline)
		}; #end if $SetValueFromPipelineByPropertyName

		if ($($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)  ) {
			$P2 += ")]" + $NewLineVar
		}; #end if ($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)

		if ($ValidateSetList) {
			$P2 += $TabVar + $TabVar + "[ValidateSet($ValidateSetList)]" + $NewLineVar
		}; #end if ValidateSetList

		$P2 += $TabVar + $TabVar 

		if ($ParameterType) {
			$P2 += "[$ParameterType]"
		}; #end if $ParameterType

		$P2 += "`$$ParameterNam" 

		if ($DefaultValue) {
			$P2 += " = ""$DefaultValue"""
		}; #end if DefaultValue
		
		if ($ParameterName[-1] -notmatch $ParameterNam) {
			$P2 += $CommaVar + $NewLinevar
		}; #end if ParameterName[-1]
		
		
	}; #end foreach ParameterName
		
	if ($BottomHeader) {
		$P2 += $NewLineVar + $TabVar +") #end Param"
	} else {
		
		if (!($NoComma)) {
			$P2 += $CommaVar
		}; #end if NoComma
		
	}; #end if BottomHeader
	
	if ($Clipboard) {
		$P2 | clip
	} else {
		return $P2
	}; #end if Clipboard
}; #end New-Parameter


Function New-Header {
	
$HeaderStamp = @"
<#
.SYNOPSIS
    Converts between CPU summation and CPU % ready values
.DESCRIPTION
    Author   : Stephen Gillie
    Last edit: 5/7/2016
.PARAMETER Frequency
    Required.
    VMWare Performance Graph from which the CPU Ready value was taken.
.PARAMETER CPUReadyValue
    Required.
    CPU Ready value from the VMWare Performance Graph. 
.EXAMPLE
    Math-CPUReady -Frequency PastMonth -CPUReadyValue 244332
.INPUTS
    [string]
    [int]
    [switch]
.OUTPUTS
    [string]
[int]
.LINK
    https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2002181
#>
"@
	
}; #end New-Header


Function New-IfStatement {
<#
.SYNOPSIS
    Writes a new IfStatement to a file.
.DESCRIPTION
    Author   : Gilgamech
    Last edit: 5/9/2016
.EXAMPLE
    New-IfStatement -Else
#>
	Param(
		[string]$EqualityVariable = "EqualityVariable",
		[ValidateSet("Equal","NotEqual","GreaterThanOrEqual","GreaterThan","LessThan","LessThanOrEqual","Like","NotLike","Match","NotMatch","Contains","NotContains","Or","And","Not","In","NotIn","Is","IsNot","As","BinaryAnd","BinaryOr")]
		[string]$ComparisonOperator,
		[string]$ReferenceVariable,
		[string]$ScriptLines ="Write-Host -f green 'The variable $EqualityVariable is True'",
		[switch]$Else,
		[string]$ElseScriptLines ="Write-Host -f red 'The variable $EqualityVariable is False'",
		[switch]$OneLiner,
		[switch]$TopHeader,
		[switch]$BottomHeader,
		[switch]$Clipboard,
		[switch]$NoComma
	) #end Param
	if ($ReferenceVariable) {$ReferenceVariable = ("`$" + $ReferenceVariable)}

	if (!($OneLiner)) {
		$NewLineVar = "`r`n"
		$TabVar = "`t"
	}; #end if OneLiner
	
	$r = @{
		"Equal" = "-eq"
		"NotEqual" = "-ne"
		"GreaterThanOrEqual" = "-ge"
		"GreaterThan" = "-gt"
		"LessThan" = "-lt"
		"LessThanOrEqual" = "-le"
		"Like" = "-like"
		"NotLike" = "-notlike"
		"Match" = "-match"
		"NotMatch" = "-notmatch"
		"Contains" = "-contains"
		"NotContains" = "-notcontains"
		"Or" = "-or"
		"And" = "-and"
		"Not" = "-not"
		"In" = "-in"
		"NotIn" = "-notin"
		"Is" = "-is"
		"IsNot" = "-isnot"
		"As" = "-as"
		"BinaryAnd" = "-band"
		"BinaryOr" = "-bor"
	} #end list of comparison operators
	
	$CompOp = $r[$ComparisonOperator]
	
	if ($TopHeader) {
		if ($CompOp -AND $ReferenceVariable) {
			$P2 = $TabVar + "if (`$$EqualityVariable $CompOp $ReferenceVariable) `{" + $NewLineVar;
		} else {
			$P2 = $TabVar + "if (`$$EqualityVariable) `{" + $NewLineVar;
		}; #end if CompOp
	}; #end if TopHeader

	if ($CompOp -AND $ReferenceVariable) {
		$ScriptLines = $ScriptLines.replace("True","$ComparisonOperator to the variable $ReferenceVariable");
		$ElseScriptLines = $ElseScriptLines.replace("False","not $ComparisonOperator to the variable $ReferenceVariable");
	}; #end if CompOp

	foreach ($ScriptLine in $ScriptLines) {
		$P2 += $TabVar + $TabVar + $ScriptLine;
	}; #end foreach ScriptLines
	
	if ($Else) {
		$P2 += $NewLineVar + $TabVar +"} else `{" + $NewLineVar;
		foreach ($ScriptLine in $ScriptLines) {
			$P2 += $TabVar + $TabVar + $ElseScriptLines;
		}; #end foreach ScriptLines
	}; #end if Else
	
	
	if ($BottomHeader) {
		$P2 += $NewLineVar + $TabVar +"}; #end if $EqualityVariable"
	} else {
		
		if (!($NoComma)) {
			$P2 += ","
		}; #end if NoComma
		
	}; #end if BottomHeader

	if ($Clipboard) {
		$P2 | clip
	} else {
		return $P2
	}; #end if Clipboard
	
}; #end New-IfStatement


Function New-ForeachStatement {
<#
.SYNOPSIS
    Writes a new ForeachStatement to a file.
.DESCRIPTION
    Author   : Gilgamech
    Last edit: 5/9/2016
.EXAMPLE
    New-ForeachStatement Operations
#>
	Param(
		[Parameter(Position=1)]
		[string]$ForeachVariable = "ForeachVariables",
		[array]$ScriptLines = "Write-Host -f y ""This is $ForeachVariable `$$($ForeachVariable.substring(0,(($ForeachVariable.Length)-1)))""",
		[switch]$OneLiner,
		[switch]$TopHeader,
		[switch]$BottomHeader,
		[switch]$Clipboard,
		[switch]$NoComma
	) #end Param
	if (!($OneLiner)) {
		$NewLineVar = "`r`n"
		$TabVar = "`t"
	}; #end if OneLiner

	if ($TopHeader) {
		$P2 += $TabVar + "foreach (`$$($ForeachVariable.substring(0,(($ForeachVariable.Length)-1))) in `$$ForeachVariable) `{" + $NewLineVar;
	}; #end if TopHeader

	foreach ($ScriptLine in $ScriptLines) {
		$P2 += $TabVar + $TabVar + $ScriptLine;
	}; #end foreach ScriptLines

	if ($BottomHeader) {
		$P2 += $NewLineVar + $TabVar + "}; #end foreach $ForeachVariable"
	} else {
		
		if (!($NoComma)) {
			$P2 += ",";
		}; #end if NoComma
		
	}; #end if BottomHeader

	if ($Clipboard) {
		$P2 | clip
	} else {
		return $P2
	}; #end if Clipboard

}; #end New-ForeachStatement


Function New-ForStatement {
	Param( 
		[Parameter(Position=1)]
		[string]$ForVariable = "ForVariable",
		[ValidateSet("Equal","NotEqual","GreaterThanOrEqual","GreaterThan","LessThan","LessThanOrEqual","Like","NotLike","Match","NotMatch","Contains","NotContains","Or","And","Not","In","NotIn","Is","IsNot","As","BinaryAnd","BinaryOr")]
		[string]$ComparisonOperator = "LessThanOrEqual",
		[string]$ReferenceVariable = "i",
		[string]$StartValue = 1,
		[array]$ScriptLines ="Write-Host -f y ""Number `$i""",
		[switch]$OneLiner,
		[switch]$TopHeader,
		[switch]$BottomHeader,
		[switch]$Clipboard,
		[switch]$NoComma
		) #end Param

		$r = @{
			"Equal" = "-eq"
			"NotEqual" = "-ne"
			"GreaterThanOrEqual" = "-ge"
			"GreaterThan" = "-gt"
			"LessThan" = "-lt"
			"LessThanOrEqual" = "-le"
			"Like" = "-like"
			"NotLike" = "-notlike"
			"Match" = "-match"
			"NotMatch" = "-notmatch"
			"Contains" = "-contains"
			"NotContains" = "-notcontains"
			"Or" = "-or"
			"And" = "-and"
			"Not" = "-not"
			"In" = "-in"
			"NotIn" = "-notin"
			"Is" = "-is"
			"IsNot" = "-isnot"
			"As" = "-as"
			"BinaryAnd" = "-band"
			"BinaryOr" = "-bor"
		} #end list of comparison operators
	
	$CompOp = $r[$ComparisonOperator]

		
		
	if (!($OneLiner)) {
		$NewLineVar = "`r`n"
		$TabVar = "`t"
	}; #end if OneLiner

	if ($TopHeader) {
		$P2 += $TabVar + "for `(`$$ReferenceVariable = $StartValue `; `$$ReferenceVariable $CompOp `$$ForVariable`; `$$ReferenceVariable`+`+`) `{" + $NewLineVar;
	}; #end if TopHeader
	
	foreach ($ScriptLine in $ScriptLines) {
		$P2 += $TabVar + $TabVar + $ScriptLine;
	}; #end foreach ScriptLines

	if ($BottomHeader) {
		$P2 += $NewLineVar + $TabVar + "}; #end for $ForVariable"
	} else {
		
		if (!($NoComma)) {
			$P2 += ","
		}; #end if NoComma
		
	}; #end if BottomHeader
	if ($Clipboard) {
		$P2 | clip
	} else {
		return $P2
	}; #end if Clipboard
}; #end New-ForStatement


Function Find-Function {
	Param(
		[Parameter(Position=1)]
		[string]$FunctionName = "Find-Function",
		[Parameter(Position=2)]
		[string]$FileName = $PowerGIL,
		[switch]$NoLineNumbers,
		[switch]$NoFunctionShow
	) #end Param
	$FileContents = gc $FileName
	
	#How to handle if string not found?
	#if -1 break?
	$startline = ((($FileContents | select-string "Function $FunctionName").LineNumber) - 1)
	$endline = ((($FileContents | select-string "}; #end $FunctionName").LineNumber) - 1)
    $NewFileContents = $FileContents[($startline)..($endline)]

	if	(!($NoLineNumbers)) {
		$startline
	}; #end if NoLineNumbers
	if (!($NoFunctionShow)) {
		$NewFileContents
	}; #end if NoFunctionShow
	if	(!($NoLineNumbers)) {
		$endline
	}; #end if NoLineNumbers
}; #end Find-Function


<#
#		[switch]$Import
	if ($import) { #Doesn't work
		$jqqhgpgse = "$home\jqqhgpgse.ps1"
		$pgse > $jqqhgpgse
		ipmo $jqqhgpgse -force
#		rm $jqqhgpgse
	}; #end if import
#>


Function Get-DevFlags {
#Make this take a file/directory as input. (FLAG)
foreach ($file in (ls -file)) {
Write-Host $file ; 
Write-Host "has changes:"; 
gc $file | select-string "(FLAG)" 

}; #end foreach
}; #end Get-DevFlags


Function Compare-DevBuilds { 
Param(
	[string]$FileName,
	[int]$FirstBuild,
	[int]$SecondBuild
); #end Param
diff (gc .\Builds\$FileName.$FirstBuild) (gc .\Builds\$FileName.$SecondBuild);
}; #end Compare-DevBuilds

#endregion 

#region MiscSystemUtilities


#Open here in Explorer.
Function Open-Explorer {
	Param(
		[string]$Location
	) #end Param
	if ($Location){
		explorer.exe $Location
	} else {
		explorer.exe (Get-Location)
	}; #end if else
}; #end Open-Explorer


Function New-Powershell {
	Param(
		[switch]$Elevated
	) #end Param
	if ($Elevated) {
		start-process powershell -verb runas
	} else {
		Start-Process powershell 
	}; #end if
}; #end New-Powershell


Function Restart-Powershell {
	Param(
		[switch]$Elevated
	) #end Param
	if ($Elevated) {
		New-Powershell -Elevated
	} else {
		New-Powershell 
	}; #end if
	exit
}; #end Restart-Powershell



Function Get-PSVersion {
	if ($PSVersionTable.psversion.major -ge 4) {
		Write-Host "PowerShell Version: $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Build).$($PSVersionTable.PSVersion.Revision)" -f Yellow 
	} else {
		Write-Host "PowerShell Version: $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" -f Yellow 
	}; #end if
}; #end Get-PSVersion


Function Set-PSWindowSize {
	[CmdletBinding()]
	Param(
	   [int]$Rows = 0,
	   [int]$Columns = 0
	)
	#from http://www.powershellserver.com/support/articles/powershell-server-changing-terminal-width/
	$pshost = Get-Host              # Get the PowerShell Host.
	$pswindow = $pshost.UI.RawUI    # Get the PowerShell Host's UI.

	$maxWindowSize = $pswindow.MaxPhysicalWindowSize # Get the max window size. 
	$newBufferSize = $pswindow.BufferSize # Get the UI's current Buffer Size.
	$newWindowSize = $pswindow.windowsize # Get the UI's current Window Size.

	if ($Rows -gt $maxWindowSize.height) {
		Write-Verbose "Max height $($maxWindowSize.height) rows tall."
		$Rows = $maxWindowSize.height
	}; #end if rows check 

	if ($Columns -gt $maxWindowSize.width) {
		Write-Verbose "Max width $($maxWindowSize.width) columns wide."
		$Columns = $maxWindowSize.width
	}; #end if columns check

	$oldBufferSize = $newBufferSize             # Save the oldsize.
	$oldWindowSize = $newWindowSize

	if ($Rows -gt 0 ) {
		$newWindowSize.height = $Rows
	} if ($oldWindowSize.height -eq $Rows) {
		Write-Verbose "Window is already $($newWindowSize.height) rows tall."
	} else {
		$pswindow.windowsize = $newWindowSize # Set the new Window Size as active.
	}; #end if Rows exists.


	if ($Columns -gt 0) {
	$newWindowSize.width = $Columns            # Set the new buffer's width to 150 columns.
	$newBufferSize.width = $Columns

	if ($newWindowSize.width -gt $oldWindowSize.width) {
		$pswindow.buffersize = $newBufferSize # Set the new Buffer Size as active.
		$pswindow.windowsize = $newWindowSize # Set the new Window Size as active.
	} elseif ($oldWindowSize.width -gt $newWindowSize.width) { #Order is important, buffer must always be wider.
		$pswindow.windowsize = $newWindowSize # Set the new Window Size as active.
		$pswindow.buffersize = $newBufferSize # Set the new Buffer Size as active.
	} elseif ($oldWindowSize.width -eq $newWindowSize.width) {
		Write-Verbose "Window is already $($newWindowSize.width) columns wide."
		}; #end if -gt
	}; #end if WindowWidth exists.
}; #end Set-PSWindowSize
if ((Get-Alias spsz -ErrorAction SilentlyContinue) -eq $null) {
New-Alias -name spsz -value Set-PSWindowSize
} #end if Get-Alias spsz


Function Set-PSWindowStyle {
param(
    [Parameter()]
    [ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE',
                 'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED',
                 'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
    $Style = 'MINIMIZE',

    [Parameter()]
    $MainWindowHandle = (Get-Process -id $pid).MainWindowHandle
)
    $WindowStates = @{
        'FORCEMINIMIZE'   = 11
        'HIDE'            = 0
        'MAXIMIZE'        = 3
        'MINIMIZE'        = 6
        'RESTORE'         = 9
        'SHOW'            = 5
        'SHOWDEFAULT'     = 10
        'SHOWMAXIMIZED'   = 3
        'SHOWMINIMIZED'   = 2
        'SHOWMINNOACTIVE' = 7
        'SHOWNA'          = 8
        'SHOWNOACTIVATE'  = 4
        'SHOWNORMAL'      = 1
    }

$memberDefintion = @"
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@

    $Win32ShowWindowAsync = Add-Type -memberDefinition $memberDefintion -name "Win32ShowWindowAsync" -namespace Win32Functions -passThru

    $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$Style]) | Out-Null
    Write-Verbose ("Set Window Style '{1} on '{0}'" -f $MainWindowHandle, $Style)

}; #end Set-PSWindowStyle
if ((Get-Alias spsy -ErrorAction SilentlyContinue) -eq $null) {
New-Alias -name spsy -value Set-PSWindowStyle
} #end if Get-Alias spsy


#System WMI stuffs
Function Invoke-WMIInstaller {
Param(
[String]$Uninstall
)
$IsElevated = (whoami /all | select-string S-1-16-12288) -ne $null

#It takes a long time to run, so I'll just repeat myself down there. That way I can check if this is in admin without making the user wait for the list to load.
Write-Host "This may take a minute or two..."
if ($Uninstall) {
if ($IsElevated) {
$app = Get-WmiObject -Class Win32_Product
$uninstallapp = $app | Where-Object { $_.Name -match $Uninstall }
$uninstallapp.uninstall()
} else {

Write-Host -f red "Please run in Administrator Powershell"
break
}; #end if iselevated

} else { #if not uninstall, display a list of stuff to uninstall.

$app = Get-WmiObject -Class Win32_Product
$app.name | sort
Write-Host -f yellow "Please copy one of the items in the list above, and re-run with -Uninstall option."

}; #end if uninstall
}; #end Invoke-WMIInstaller


Function Get-WMIDisk {
	Param(
		[String]$Drive,
		[Switch]$Raw
	) #end Param
	if ($drive.length -eq 1) {
		$Filter = ("DeviceID='" + $Drive + ":'")
		$GWD = Get-WmiObject Win32_LogicalDisk -Filter $Filter
	} else {
		[object]$GWD = Get-WmiObject Win32_LogicalDisk
	}; #end if Drive
	if ($Raw) {
		$GWD
	} else {
		foreach ($drive in $GWD) {
			$drive = [object]$drive
			$drive
			$drive.DeviceID
			$drive.size
			if ($drive.size -gt 0) {
				[math]::Round((($drive.FreeSpace / $drive.Size) * 100)).tostring() + "% free in drive" + $drive.DeviceID
			}; #end if drivesize gt 0
		}; #end foreach drive
	}; #end if Raw
}; #end Get-WMIDisk 


Function Export-PuTTY {
	Write-Host "Exports your PuTTY profiles to $home\Desktop\putty.reg"
	reg export HKCU\Software\SimonTatham $home\Desktop\putty.reg
}; #end Export-PuTTY


#Github
Function Get-GithubStatus {
$r = Invoke-RestMethod -Uri "https://status.github.com/api/status.json?callback=apiStatus"
$s = ConvertFrom-Json $r.substring(10,($r.Length - 11))
$s.last_updated = get-date ($s.last_updated)
$s
}; #end Get-GithubStatus


Function Leet-H4x0r {
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
} #Leet-H4x0r


Function Test-PingJob {
start-job { 
ping -t 8.8.8.8 
} ; 
$pingjob = (get-job).id[-1] ; 
while ((get-job $pingjob ).hasmoredata) {
receive-job $pingjob 
}; #end while 
}; #end Test-PingJob


Function Stop-Explorer {
get-process explorer | foreach { stop-process $_.id }
}; #end Stop-Explorer


Function Receive-AllJobs {
foreach ($job in (get-job).id ) { 
while ((get-job $job ).hasmoredata) { 
receive-job $job
}; #end while
}; #end foreach
}; #end Receive-AllJobs



Function Stop-AllJobs {
foreach ($job in (get-job).id ) {
stop-job $job
}; #end foreach
}; #end Stop-AllJobs


Function Get-Clipboard {
#https://www.bgreco.net/powershell/get-clipboard/
Param(
    [switch]$JSON,
	[switch]$raw
) 
	Add-Type -Assembly PresentationCore
	if($raw) {
		$cmd = {
			[Windows.Clipboard]::GetText()
		}
	} else {
		$cmd = {
			[Windows.Clipboard]::GetText() -replace "`r", '' -split "`r`n"
		}
	}; #end if
	
	if ($JSON) {
		$cmd = $cmd | ConvertFrom-JSON
	}
	
	if([threading.thread]::CurrentThread.GetApartmentState() -eq 'MTA') {
		& powershell -Sta -Command $cmd
	} else {
		& $cmd
	}; #end if
}; #end Get-Clipboard


Function Watch-Clipboard {
$cbclip = "test"
while (Get-Clipboard -ne "") { 
if ( (diff (Get-Clipboard -raw) $cbclip ) -ne $null) { 
$cbclip = Get-Clipboard -raw
$cbclip 
sleep .5
}; #end if 
}; #end while
}; #end Watch-Clipboard


Function Send-Clipboard {
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ipaddress]$serveraddr,
   [Parameter(Mandatory=$True,Position=2)]
   [int]$serverport,
#   [switch]$PSObject,
   [switch]$echo
)
$cbclip = "test"
while (Get-Clipboard -ne "") { 
if ( (diff (Get-Clipboard -raw) $cbclip ) -ne $null) { 
$cbclip = Get-Clipboard -raw
Send-Text -serveraddr $serveraddr -serverport $serverport -message $cbclip #-PSObject $PSObject
if ($echo){
$cbclip 
}; #end if 
sleep .2
}; #end if 
}; #end while
}; #end Send-Clipboard


Function Get-UsGovWeather {
#https://blogs.technet.microsoft.com/heyscriptingguy/2010/11/07/use-powershell-to-retrieve-a-weather-forecast/
 Param([string]$zip = 98104,
       [int]$numberDays = 4,
      [switch]$Fahrenheit
	 )
$URI = "http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl"
$Proxy = New-WebServiceProxy -uri $URI -namespace WebServiceProxy
[xml]$latlon=$proxy.LatLonListZipCode($zip)
foreach($l in $latlon)
{
 $a = $l.dwml.latlonlist -split ",";
 $lat = $a[0]
 $lon = $a[1]
 $sDate = get-date -UFormat %Y-%m-%d
 $format = "Item24hourly"
if ($Fahrenheit) { $unit = "e" }else { $unit = "m" } 
 [xml]$weather = $Proxy.NDFDgenByDay($lat,$lon,$sDate,$numberDays,$unit,$format)
 For($i = 0 ; $i -le $numberDays -1 ; $i ++)
 {
  New-Object psObject -Property @{
  "Date" = ((Get-Date).addDays($i)).tostring("MM/dd/yyyy") ;
  "maxTemp" = $weather.dwml.data.parameters.temperature[0].value[$i] ;
  "minTemp" = $weather.dwml.data.parameters.temperature[1].value[$i] ;
  "Summary" = $weather.dwml.data.parameters.weather."weather-conditions"[$i]."Weather-summary"}
 }
}
}; #end Get-UsGovWeather


Function Test-PortConnection {
[CmdletBinding()]
Param(
    [Parameter(Position=1)]
    [IPAddress]$IPAddress = "127.0.0.1",
    [Parameter(Position=2)]
    [int]$Port = 443
)
try {
(new-object Net.Sockets.TcpClient).Connect("$($IPAddress.IPAddressToString)", $Port)
} catch {
return $false
Write-Verbose -Message "Connection failed.";
break
} 
return $true
Write-Verbose -Message "Connection succeeded.";

}; #end Test-PortConnection

#endregion

#region init
#Set TLS 1.2:
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

#Set UTF8 Encoding
$OutputEncoding = New-Object -typename System.Text.UTF8Encoding
#[Console]::OutputEncoding = New-Object -typename System.Text.UTF8Encoding #This setting messes up VI.

#Need this for ConvertImage-ToASCIIArt.
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | out-null

#Move to Profile?
[ipaddress]$localhost = "127.0.0.1"
$ProfileFolder = (split-path $PROFILE)

#For the audio player 
Add-Type -AssemblyName presentationCore
$wmplayer = New-Object System.Windows.Media.MediaPlayer

#Hate VIM
if ($VIMPATH) {
Set-Alias vi   $VIMPATH
Set-Alias vim  $VIMPATH
} else {
Write-Host -f red "VIM not found, disabling alias." 
}; #end if VI

#Love Notepad++i
if ($NppPATH) {
Set-Alias note  $NppPATH
} else {
Write-Host -f red "Notepad++ not found, disabling alias."
}; #end if N++

#Fight with LYNX
if ($LynxW32Path) {
Set-Alias LYNX  $LynxW32Path
} else {
Write-Host -f red "LYNX not found, disabling alias."
}; #end if LYNX

#$DontShowPSVersionOnStartup = $false # to turn off Powershell Version display.
if (($ShowPSVersionOnStartup)){
Get-PSVersion
}

#$DontShowPoweGILVersionOnStartup = $false # to turn off PowerGIL Build display.
if (!($DontShowPoweGILVersionOnStartup)){
Get-ModuleVersion
}
#endregion

#region PowerShiri
Function Start-PowerShiri {
Import-Module "C:\Dropbox\PowerShiri\PowerShiri.ps1" -Force
}; #end Start-PowerShiri
#Speech

Function Read-Webpage ($URL) {
$ycom = iwr $URL
$yih = ($ycom.ParsedHtml.getElementsByTagName("p") | select innerhtml ).innerhtml
return $yih
}; #end Read-Webpage


Function Say-This {
#Rename to Out-Speech?
Param(
   [string]$saythis = "Type something for me to say"
)
Add-Type -AssemblyName System.Speech
$synthesizer = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
$synthesizer.Speak($saythis)
}
#endregion

#region Time
Function Convert-Time
{
	#If there's more than 1 option, have it loop. (FLAG)
	param(
		[Parameter(Mandatory=$false,Position=1)]
		[string]$time = (get-date),
		[validateset("AST","BST","CST","China","DST","EST","FST","GST","HST","IST","JST","Japan","KST","LST","MST","NST","PST","RST","Russia","SST","TST","UST","UTC","VST","YST")]
		[string]$ToTZ = "PST",
		[validateset("AST","BST","CST","China","DST","EST","FST","GST","HST","IST","JST","Japan","KST","LST","MST","NST","PST","RST","Russia","SST","TST","UST","UTC","VST","YST")]
		[string]$FromTZ = "PST",
		[string]$FromTimeZoneFullName = $null, 
		[string]$ToTimeZoneFullName = $null,
		[switch]$UTCtoo,
		[switch]$ListTZones
	)
	#1. Funnel the TLAs into the fromtimezone
	#2. Set the partnames to be a foreach loop. 


	$SystemTZones = ([System.TimeZoneInfo]::GetSystemTimeZones()).id
	if ($ListTZones) {
		#ListTZones will just dump the system time zones.
		$SystemTZones
		Write-Host -f y "This system knows about the above time zones. Please use these with '-FromTimeZoneFullName' and '-ToTimeZoneFullName' parameters."
		break
	} else {
		#Otherwise run the full script.
		$TLATZ = @{
			'AST' = "Alaskan Standard Time"
			'BST' = "Bangladesh Standard Time"
			'CST' = "Central Standard Time"
			'China' = "China Standard Time"
			'DST' = "Dateline Standard Time"
			'EST' = "Eastern Standard Time"
			'FST' = "Fiji Standard Time"
			'GST' = "Greenwich Standard Time"
			'HST' = "Hawaiian Standard Time"
			'IST' = "India Standard Time"
			'JST' = "Jordan Standard Time"
			'Japan' = "Tokyo Standard Time"
			'KST' = "Korea Standard Time"
			'LST' = "Libya Standard Time"
			'MST' = "Mountain Standard Time"
			'NST' = "Newfoundland Standard Time"
			'PST' = "Pacific Standard Time"
			'RST' = "Russian Standard Time"
			'Russia' = "Russian Standard Time"
			'SST' = "Singapore Standard Time"
			'TST' = "Tokyo Standard Time"
			'UST' = "Ulaanbaatar Standard Time"
			'UTC' = "UTC"
			'VST' = "Venezuela Standard Time"
			'YST' = "Yakutsk Standard Time"
		}
		
		$fromtzone ="PST"
		if ($FromTimeZoneFullName) {
			$fromtzone = $SystemTZones |  where {$_ -like "*$FromTimeZoneFullName*"}
#			$fromtzone = $FromTimeZoneFullName
		} elseif ($FromTZ) {
			$fromtzone = $TLATZ[$FromTZ]
		} else {
			Write-Host -f red "No 'From' time zone entered. Use -FromTZ or -FromTimeZoneFullName"
			break
		}; #end if fromTimeZone

		
		$oFromTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($fromtzone)
		Write-Verbose "Converting from $oFromTimeZone"
<#
		$oFromTimeZone = foreach ($tz in $fromtzone) {
		$tzz  = [System.TimeZoneInfo]::FindSystemTimeZoneById($tz); 
		return ($tz + ": " + $tzz) 
		}; #end foreach
#>

		
		

		$totzone = "PST"
		if ($ToTimeZoneFullName) {
#			$totzone = $ToTimeZoneFullName
			$totzone = $SystemTZones |  where {$_ -like "*$ToTimeZoneFullName*"}
		} elseif ($ToTZ) {
			$totzone = $TLATZ[$ToTZ]
		} else {
			Write-Host -f red "No 'To' time zone entered. Use -ToTZ or -ToTimeZoneFullName"
			break
		}; #end if toTimeZone
		
		
		$oToTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($totzone)
		Write-Verbose "Converting to $oToTimeZone"
<#
		$oToTimeZone = foreach ($tz in $totzone) {
		$tzz  = [System.TimeZoneInfo]::FindSystemTimeZoneById($tz); 
		return ($tz + ": " + $tzz) 
		}; #end foreach
#>


		$utc = [System.TimeZoneInfo]::ConvertTimeToUtc($time, $oFromTimeZone)
		$newTime = [System.TimeZoneInfo]::ConvertTime($utc, $oToTimeZone)
		  
		$newtime
		
		if ($UTCtoo){
			$utc
		}; #end if UTC
	}; #end if ListTZones

}; #end Convert-Time

#List of TLAs
#$r = foreach ($name in (([System.TimeZoneInfo]::GetSystemTimeZones()).standardname)) {-join (($name).split(" ") | foreach {$_[0]})} ; 
#$r | select -Unique | where {$_.length -eq 3} | sort

#endregion

#region Music!

Function Start-Music {
#http://www.adminarsenal.com/admin-arsenal-blog/powershell-music-remotely/
param(
   [Parameter(Mandatory=$True,Position=1)]
   [uri]$FileName
)
#Add-Type -AssemblyName presentationCore
#$FileName = [uri] "C:\temp\Futurama - Christmas Elves song.mp3"
#$wmplayer = New-Object System.Windows.Media.MediaPlayer
$wmplayer.Open($FileName)
Start-Sleep 2 # This allows the $wmplayer time to load the audio file
#$duration = $wmplayer.NaturalDuration.TimeSpan.TotalSeconds
$wmplayer.Play()
}

Function Stop-Music {
$wmplayer.Stop()
$wmplayer.Close()
}

#endregion

#region Conversions
Filter Flip-TextToBinary {
[System.Text.Encoding]::UTF8.GetBytes($_) | %{ 
[System.Convert]::ToString($_,2).PadLeft(8,'0')
}
#[System.Text.Encoding]::UTF8.GetBytes([System.Convert]::ToString($_,2).PadLeft(8,'0'))
}

Filter Flip-BinaryToText {
Param(
   [switch]$ASCII
)
if ($ASCII) {
#[System.Text.Encoding]::ASCII.GetBytes($_)
%{ 
[System.Text.Encoding]::ASCII.GetString([System.Convert]::ToInt32($_,2)) 
}; #end foreach
} else {
%{ 
[System.Text.Encoding]::UTF8.GetString([System.Convert]::ToInt32($_,2)) 
}; #end foreach
}; #end if
}; #end Filter

Filter Flip-TextToBytes {
Param(
   [switch]$ASCII
)
if ($ASCII) {
[System.Text.Encoding]::ASCII.GetBytes($_)
} else {
[System.Text.Encoding]::Unicode.GetBytes($_)
}; #end if
}; #end Filter

<# Filter Flip-TextToHex {
Param(
   [switch]$ASCII
)
if ($ASCII) {
$ab = [System.Text.Encoding]::ASCII.GetBytes($_);
} else {
$ab = [System.Text.Encoding]::UTF8.GetBytes($_);
}; #end if
$ac = [System.BitConverter]::ToString($ab);
$ac.split("-")
}; #end Filter
 #>

Function Flip-BytesToText {
Param(
   [Parameter(Mandatory=$True,Position=3)]
   [object]$B,
   [switch]$ASCII
)
if ($ASCII) {
[System.Text.Encoding]::ASCII.GetString($B)
} else {
[System.Text.Encoding]::Unicode.GetString($B)
}
}; #end Flip-BytesToText

Filter Flip-TextToBase64 {
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($_)
$EncodedText =[Convert]::ToBase64String($Bytes)
$EncodedText
}; #end Filter

Filter Flip-Base64ToText {
$DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($_))
$DecodedText
}; #end Filter

Filter Flip-HexToText {
$_.Split(" ") | FOREACH {
 [CHAR][BYTE]([CONVERT]::toint16($_,16))
}; #end foreach
}; #end Flip-HexToText

Filter Flip-TextToHex {
$_.ToCharArray() | FOREACH {
 ([CONVERT]::tostring([BYTE][CHAR]$_,16))
}; #end foreach
}; #end Flip-HexToText

Filter Flip-HexToBinary {
$_.Split(" ") | FOREACH {
 ([CONVERT]::toint16($_,16))
}; #end foreach
}; #end Flip-HexToText

#endregion

#region Encryption
#Run in Elevated: New-SelfSignedCertificate -CertStoreLocation cert:\LocalMachine\My -DnsName "gilgamech.com"

Function Get-Encrypted {
#http://powershell.org/wp/2014/02/01/revisited-powershell-and-encryption/
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [object]$Message,
   [Parameter(Mandatory=$True,Position=2)]
   [string]$file
)
Write-Host "Encrypting to $file..." -f y
try
{
  Write-Host "Encrypting input..." -f y
  $secureString = $Message | ConvertTo-SecureString -AsPlainText -Force
#    $secureString = 'This is my password.  There are many like it, but this one is mine.' | 
#                    ConvertTo-SecureString -AsPlainText -Force

# Generate our new 32-byte AES key.  I don't recommend using Get-Random for this; the System.Security.Cryptography namespace offers a much more secure random number generator.

    $key = New-Object byte[](32)
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
Write-Host "Creating key..." -f y
    $rng.GetBytes($key)

Write-Host "Encrypting input..." -f y
    $encryptedString = ConvertFrom-SecureString -SecureString $secureString -Key $key
Write-Host "Input encrypted." -f green

    # This is the thumbprint of a certificate on my test system where I have the private key installed.

    $thumbprint = (ls  -Path Cert:\CurrentUser\My\).Thumbprint
    $cert = Get-Item -Path Cert:\CurrentUser\My\$thumbprint -ErrorAction Stop

    $encryptedKey = $cert.PublicKey.Key.Encrypt($key, $true)
Write-Host "Key encrypted." -f green

    $object = New-Object psobject -Property @{
        Key = $encryptedKey
        Payload = $encryptedString
    }

Write-Host "Encryption complete, writing $file." -f green
    $object | Export-Clixml $file

}
finally
{
    if ($null -ne $key) { [array]::Clear($key, 0, $key.Length) }
Write-Host "Key cleared." -f green
#    if ($null -ne $secureString) { [array]::Clear($secureString, 0, $secureString.Length) }
#    if ($null -ne $rng) { [array]::Clear($rng, 0, $rng.Length) }
#    if ($null -ne $encryptedString) { [array]::Clear($encryptedString, 0, $encryptedString.Length) }
#    if ($null -ne $thumbprint) { [array]::Clear($thumbprint, 0, $thumbprint.Length) }
#    if ($null -ne $cert) { [array]::Clear($cert, 0, $cert.Length) }
#    if ($null -ne $encryptedKey) { [array]::Clear($encryptedKey, 0, $encryptedKey.Length) }
#    if ($null -ne $object) { [array]::Clear($object, 0, $object.Length) }

}
}; #end Get-Encrypted 



Function Get-Decrypted {
#http://powershell.org/wp/2014/02/01/revisited-powershell-and-encryption/
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$file
)
Write-Host "Decrypting $file..." -f y
try
{
Write-Host "Reading file $file" -f green
    $object = Import-Clixml -Path $file
Write-Host "Removing $file" -f y
	rm $file

    $thumbprint = (ls  -Path Cert:\CurrentUser\My\).Thumbprint
    $cert = Get-Item -Path Cert:\CurrentUser\My\$thumbprint -ErrorAction Stop

    $key = $cert.PrivateKey.Decrypt($object.Key, $true)
Write-Host "Key decrypted." -f green
Write-Host "Decrypting payload, this may take a while..." -f y
    #$secureString = $object.Payload | ConvertTo-SecureString -Key $key
	$secureString = $object.Payload | ConvertTo-SecureString -Key $key
Write-Host "Input decrypted." -f green
	ConvertFrom-SecureToPlain $secureString
Write-Host "Decryption complete. Hope you wrote this to a variable!" -f green
}
finally
{
    if ($null -ne $key) { [array]::Clear($key, 0, $key.Length) }
Write-Host "Key cleared." -f green
} 
}; #end Get-Decrypted

#endregion

#region Images

Function Invoke-PowerGilImage {
# load the appropriate assemblies 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

# create chart object 
$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 
$Chart.Width = 500 
$Chart.Height = 400 
$Chart.Left = 40 
$Chart.Top = 30

# create a chartarea to draw on and add to chart 
$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea 
$Chart.ChartAreas.Add($ChartArea)

# add data to chart 
$Cities = @{London=7556900; Berlin=3429900; Madrid=3213271; Rome=2726539; 
            Paris=2188500} 
[void]$Chart.Series.Add("Data") 
$Chart.Series["Data"].Points.DataBindXY($Cities.Keys, $Cities.Values)

# display the chart on a form 
$Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
                [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left 
$Form = New-Object Windows.Forms.Form 
$Form.Text = "PowerShell Chart" 
$Form.Width = 600 
$Form.Height = 600 
$Form.controls.add($Chart) 
$Form.Add_Shown({$Form.Activate()}) 
$Form.ShowDialog()
}; #end Invoke-PowerGilImage


Function Display-Image {
# Loosely based on http://www.vistax64.com/powershell/202216-display-image-powershell.html
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$FileName
)
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")

$file = (get-item $FileName)
#$file = (get-item "c:\image.jpg")

$img = [System.Drawing.Image]::Fromfile($file);

# This tip from http://stackoverflow.com/questions/3358372/windows-forms-look-different-in-powershell-and-powershell-ise-why/3359274#3359274
[System.Windows.Forms.Application]::EnableVisualStyles();
$form = new-object Windows.Forms.Form
$form.Text = "Image Viewer"
$form.Width = $img.Size.Width;
$form.Height =  $img.Size.Height;
$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Width =  $img.Size.Width;
$pictureBox.Height =  $img.Size.Height;

$pictureBox.Image = $img;
$form.controls.add($pictureBox)
$form.Add_Shown( { $form.Activate() } )
$form.ShowDialog()
#$form.Show();
}; #end Display-Image


Function ConvertImage-ToASCIIArt {
#------------------------------------------------------------------------------ 
# Copyright 2006 Adrian Milliner (ps1 at soapyfrog dot com) 
# http://ps1.soapyfrog.com 
# 
# This work is licenced under the Creative Commons  
# Attribution-NonCommercial-ShareAlike 2.5 License.  
# To view a copy of this licence, visit  
# http://creativecommons.org/licenses/by-nc-sa/2.5/  
# or send a letter to  
# Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA. 
#------------------------------------------------------------------------------ 
 
#------------------------------------------------------------------------------ 
# This script loads the specified image and outputs an ascii version to the 
# pipe, line by line. 
# 
param( 
  [Parameter(Mandatory=$True,Position=1)]
  [string]$path, #= $(throw "Supply an image path"), 
  [int]$maxwidth,            # default is width of console 
  [string]$palette="ascii",  # choose a palette, "ascii" or "shade" 
  [float]$ratio = 1.5        # 1.5 means char height is 1.5 x width 
) 
 
 
#------------------------------------------------------------------------------ 
# here we go 
 
$palettes = @{ 
  "ascii" = " .,:;=|iI+hHOE#`$" 
  "shade" = " " + [char]0x2591 + [char]0x2592 + [char]0x2593 + [char]0x2588 
  "bw"    = " " + [char]0x2588 
} 
$c = $palettes[$palette] 
if (-not $c) { 
  write-warning "palette should be one of:  $($palettes.keys.GetEnumerator())" 
  write-warning "defaulting to ascii" 
  $c = $palettes.ascii 
} 
[char[]]$charpalette = $c.ToCharArray() 
 
# We load the drawing assembly at the top of PowerGIL

$path = (Resolve-Path $path)

# load the image
$image = [Drawing.Image]::FromFile($path)  
if ($maxwidth -le 0) { [int]$maxwidth = $host.ui.rawui.WindowSize.Width - 1} 
[int]$imgwidth = $image.Width 
[int]$maxheight = $image.Height / ($imgwidth / $maxwidth) / $ratio 
$bitmap = new-object Drawing.Bitmap ($image,$maxwidth,$maxheight) 
[int]$bwidth = $bitmap.Width; [int]$bheight = $bitmap.Height 
# draw it! 
$cplen = $charpalette.count 
for ([int]$y=0; $y -lt $bheight; $y++) { 
  $line = "" 
  for ([int]$x=0; $x -lt $bwidth; $x++) { 
    $colour = $bitmap.GetPixel($x,$y) 
    $bright = $colour.GetBrightness() 
    [int]$offset = [Math]::Floor($bright*$cplen) 
    $ch = $charpalette[$offset] 
    if (-not $ch) { $ch = $charpalette[-1] } #overflow 
    $line += $ch 
  } 
  $line 
} 

}; #end ConvertImage-ToASCIIArt
if ((Get-Alias ciai -ErrorAction SilentlyContinue) -eq $null) {
new-alias -name ciai -value ConvertImage-ToASCIIArt
} #end if Get-Alias ciai

#endregion

#region UDP

Function Send-UDPText {
#http://powershell.com/cs/blogs/tips/archive/2012/05/09/communicating-between-multiple-powershells-via-udp.aspx
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		[ipaddress]$serveraddr,
		[Parameter(Mandatory=$True,Position=2)]
		[int]$serverport,
		[Parameter(Mandatory=$True,Position=3)]
		[object]$Message,
		[switch]$JSON,
		[switch]$Secure
	)

	#Basic protection, at least it's not plaintext. Doesn't work with JSON IIRC.
	if ($Secure) {
		Write-Host "Converting to SecureString..." -f y
		$Message = ConvertTo-SecureString -AsPlainText $Message.ToString() -Force
		Write-Host "Conversion complete, sending." -f green
	}; #end if
	
	#Send Objects with JSON flag set on both sender and listener, otherwise they'll just be the useless output strings.
	if ($JSON) {
		$Message = ConvertTo-JSON $Message
	}; #end if
		
		#Create endpoint & UDP client
		$endpoint = New-Object System.Net.IPEndPoint ($serveraddr,$serverport)
		$udpclient= New-Object System.Net.Sockets.UdpClient
		
		#Swaps the message from ASCII to bytes. Should change for like Flip-TextToBytes (FLAG)
		$bytes=[Text.Encoding]::ASCII.GetBytes($Message)
		$bytesSent=$udpclient.Send($bytes,$bytes.length,$endpoint)
		$udpclient.Close()
}; #end Send-Text 


Function Start-UDPListen {
#http://powershell.com/cs/blogs/tips/archive/2012/05/09/communicating-between-multiple-powershells-via-udp.aspx
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		[int]$ServerPort,
		[Parameter(Position=2)]
		[switch]$Continuous,
		[Parameter(Position=3)]
		[switch]$JSON,
		[switch]$Secure
	) #end Param
	#If there's no endpoint, create one - this tries to avoid errors that the endpoint already exists.
	#Swap [IPAddress]::Any for an address (or range?) to limit who can send to this.
	if ($endpoint.port -eq $null) {
		$endpoint = New-Object System.Net.IPEndPoint ([IPAddress]::Any,$serverport)
	}; #end if

	Write-Host "Now listening on port" $serverport -f green
	if (($Continuous)) {
		Write-Host "Continuous mode" -f "Red"
	}; #end if
	
	#Create the socket
	$udpclient = New-Object System.Net.Sockets.UdpClient $serverport

	#Quick and dirty way to loop when iterate is set to true. 
	$iterate = $true
	while ($iterate) {
		#Open socket, store 
		$content = $udpclient.Receive([ref]$endpoint)
		#Swaps the message from bytes to ASCII. Should change for like Flip-BytesToText (FLAG)
		$content = [Text.Encoding]::ASCII.GetString($content)

		#If you're receiving Objects, expect them to be sent as JSON strings, so convert them back to Objects.
		if ($JSON) {
			$content = ConvertFrom-JSON $content
		} else {	}; #end if - Not sure what was going there.
		if ($Secure) {
			$content = ConvertFrom-SecureToPlain $content
		}; #end if

		#If Continuous flag wasn't set, dump us from the loop.
		if (!($Continuous)) {
			$iterate = $false
		}; #end if
		
		#Unsure of output format, this way just works. 
		$content

	} # end while

}; #end Start-Listen

# endregion

#region Enables the [Audio] stuffs. 
#https://stackoverflow.com/questions/255419/how-can-i-mute-unmute-my-sound-from-powershell
Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;

[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume {
  // f(), g(), ... are unused COM method slots. Define these if you care
  int f(); int g(); int h(); int i();
  int SetMasterVolumeLevelScalar(float fLevel, System.Guid pguidEventContext);
  int j();
  int GetMasterVolumeLevelScalar(out float pfLevel);
  int k(); int l(); int m(); int n();
  int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, System.Guid pguidEventContext);
  int GetMute(out bool pbMute);
}
[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice {
  int Activate(ref System.Guid id, int clsCtx, int activationParams, out IAudioEndpointVolume aev);
}
[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator {
  int f(); // Unused
  int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);
}
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }

public class Audio {
  static IAudioEndpointVolume Vol() {
    var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;
    IMMDevice dev = null;
    Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(/*eRender*/ 0, /*eMultimedia*/ 1, out dev));
    IAudioEndpointVolume epv = null;
    var epvid = typeof(IAudioEndpointVolume).GUID;
    Marshal.ThrowExceptionForHR(dev.Activate(ref epvid, /*CLSCTX_ALL*/ 23, 0, out epv));
    return epv;
  }
  public static float Volume {
    get {float v = -1; Marshal.ThrowExceptionForHR(Vol().GetMasterVolumeLevelScalar(out v)); return v;}
    set {Marshal.ThrowExceptionForHR(Vol().SetMasterVolumeLevelScalar(value, System.Guid.Empty));}
  }
  public static bool Mute {
    get { bool mute; Marshal.ThrowExceptionForHR(Vol().GetMute(out mute)); return mute; }
    set { Marshal.ThrowExceptionForHR(Vol().SetMute(value, System.Guid.Empty)); }
  }
}
'@


#endregion 

#region footer


#endregion








