# C:\Dropbox\Public\html5\PS1\PowerGIL.ps1 Build: 532 2016-07-04T19:59:43 Copyright Gilgamech Technologies  
# Update Path: http://Gilgamech.com/PS1/PowerGIL.ps1
# Build : LineNo : Update Notes
# 528 : 2544 : if _$Char _eq $NewCipherKey[_1]_ _  $DelimVar = ';' _ else _  $DelimVar = ',' _; #end if Char
# 529 : 2063 : Filter Flip_SymbolToWord _      _; #end Flip_SymbolToWord
# 530 : 2066 : If _$FunctionVariable__ _  $_ = $_.replace_","," comma "_ _; #end If FunctionVariable
# 531 : 2098 : foreach _$Symbol in $SymbolText_ _  $WordText = $Symbol.replace__$Hash.name_,_$Hash.value__ _; #end foreach Symbol
# 532 : 2000 : if _$RetStr_ _  return $RetStr _; #end if RetStr

#region To run this, put these in your profile, and set them appropriately: 
# 
#$BasePath = "C:\Dropbox"
#$ProgramsPath = $BasePath + "\Programs"
#$ReposPath = $BasePath + "\repos"
#$DocsPath = $BasePath + "\Docs"
#$UtilPath = $ProgramsPath + "\util"
#$VIMPATH = $UtilPath + "\vim74\vim.exe"
#$LynxW32Path = $UtilPath + "\lynx_w32\lynx.exe"
#$GITPath = $ProgramsPath + "\Git\bin\git.exe"
#$modulesFolder = $BasePath + "\Public\html5\PS1"
#$PowerGIL = $modulesFolder + "\PowerGIL.ps1"
#$NppPath = $ProgramsPath + "\N++\notepad++.exe"
#
# Import-Module $PowerGIL
# 
#$DontShowPSVersionOnStartup = $true # to turn off Powershell Version display.
# 
# 
#endregion

#region Features
#Param-Protection prevents duplicate Parameters!
#FunctionGuard keeps you In The Zone!
#Auto-Tab to keep formatting consistent and easy-to-read!
#Auto-Verbose! 
#Auto-Debug with EnGuard (Separate module in Beta!)
#Easy to understand GilFile language
#Dynamic Parameter rebuilder (Beta!)
#Auto-Update when 100+ builds behind!
#New-Module adds the module to your Profile for auto-loading!
#Secure communications with easy-to-generate Cipher key!
#Streamline screenshot taking! - Take-Screenshot's Bound parameter directly accepts Get-Window's new Rectangle output type.
#
#endregion

#region Backup\Update\Restore


Function Update-Module {
	Param(
		[Parameter(Position=1)]
		[string]$FileName = $PowerGIL,
		[string]$FileContents = (Get-ModuleVersion -ModuleName $FileName -Content)
	); #end Param

	if ($FileContents -ne $null) {
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
		Insert-TextIntoFile -FileContents $FileContents -FileName $FileName
		#ipmo $FileName -force
	} else {
		Write-Host -f red 'Update was empty.'
	}; #end if FileContents
		
}; #end Update-Module


Function Get-ModuleVersion {
	<#
		.SYNOPSIS
			Returns PowerGIL version number, notes, and Function list.
		.DESCRIPTION
			Author	: Stephen Gillie
			Last edit: 5/17/2016
		.EXAMPLE
			Get-ModuleVersion - Notes
	#>
	Param(
		[string]$ModuleName = $PowerGIL,
		[string]$UpdatePath = ((Get-Content $ModuleName -ErrorAction SilentlyContinue)[1].split(" ")[3]),
		[int]$build = ([int](Get-Content $ModuleName)[0].split(" ")[3]),
		[switch]$notes,
		[switch]$Functions,
		[switch]$Content
	); #end Param
	
		#If the Update Path starts with HTTP, treat as web request, else treat as file path.
		if (((gc $ModuleName)[1].split(":")[1] -match "http*")) {
			$ModuleNameRemotePS1 = try {
				(Invoke-WebRequest $UpdatePath).content
			}catch{
				Write-Verbose "404: File Not Found."
				return 404
			}; #end try
			#$ModuleNameRemotePS1 = $ModuleNameRemotePS1.content
		} else {
			$ModuleNameRemotePS1 = try {
				(Get-Content $ModuleName -ErrorAction SilentlyContinue)
			} Catch {
				Write-Verbose "404: File Not Found."
				404
			}; #end try FunctionVariable
		}; #end if Get-Content ModuleName
	
	if ($Content) {
		return $ModuleNameRemotePS1
	}; #end if Content
	
	#If you could get the web version, dig out its build number. Else return 0.
	if ($ModuleNameRemotePS1 -eq 0){
		$ModuleNameWebVersion = 0
	} else {
		[int]$ModuleNameWebVersion = ($ModuleNameRemotePS1.split(" ")[3])
	}; #end if ModuleNameRemotePS1
	
	#Auto-update on startup when module is 100+ out of date. 
	if ($ModuleNameWebVersion -ge ($build + 100)) {
		Write-Host -f y "Installed $ModuleName Build: " -nonewline; Write-Host -f Red $build 
		Write-Host -f y "Remote $UpdatePath Build: " -nonewline; Write-Host -f green $ModuleNameWebVersion 
		Write-Host "$($ModuleNameWebVersion - $build) versions behind, " -nonewline; Write-Host -f red "Force-updating.";
		Update-Module
		Restart-Powershell
	}elseif ($ModuleNameWebVersion -gt  $build){
		#If the web is newer, suggest update.
		Write-Host -f y "Installed $ModuleName Build: " -nonewline; Write-Host -f "Red" $build 
		Write-Host -f y "Remote $UpdatePath Build: " -nonewline; Write-Host -f green $ModuleNameWebVersion 
		Write-Host "You should run " -nonewline; Write-Host -f Red "Update-Module " ;

	}elseif  ($ModuleNameWebVersion -eq $build) {
		#If versions match, show green.
		Write-Host -f green "$UpdatePath Build:" $build
	}else{
		#if web is older/not found, just show green instead of reporting an error. 
		Write-Host -f green "$ModuleName Build:" $build
		Write-Verbose "Web Source Unavailable."
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


New-Alias -Name instxt -Value Insert-TextIntoFile -Force
Function Insert-TextIntoFile {
<#
.SYNOPSIS
	Inserts the supplied text into the target module at the listed line number.
.DESCRIPTION
	Author	: Gilgamech
	Last edit: 5/29/2016
.EXAMPLE
	Insert-TextIntoFile (New-ForStatement Bees -top -bot ) .\New-Module.ps1 289 
#>
	[CmdletBinding()]
	Param(
		[array]$InsertText,
		[string]$FileName = "NewModule.ps1",
		[ValidateRange(9,65535)]
		[int]$InsertAtLineNumber = 9, #Forces anti-clobber, leaves an empty line below the update log.
		[array]$FileContents = (gc $FileName),
		[array]$filesplit = ($FileContents[0].split(" ") | select -Unique),
		[string]$Copyright = ($filesplit[5] + " " + $filesplit[6] + " " + $filesplit[7] + " " + $filesplit[8] + " " + $filesplit[9]),
		[array]$FileOutput = $FileContents[0.. ($InsertAtLineNumber -1)],
		[int]$build = $filesplit[3],
		[string]$dtstamp = (get-date -f s)
	); #end Param
	
	#Finish adding text to FileOutput.
	if ($InsertText) {
		$build += 1
		Write-Host -f green "$FileName build incremented to $build."
		
		#3. Rewrite top line.
		$FileOutput[0] = "# $FileName Build: $build $dtstamp $Copyright"
		
		#Rotate lines 4-7 up one line.
		for ($i = 4 ; $i -le 7 ; $i++) {
			$FileOutput[($i-1)] = $FileOutput[$i]
		}; #end for i
		
		#Add this change as a new line 7.
		$FileOutput[7] = "# $build : $InsertAtLineNumber : $($inserttext -replace('-','_') -replace('\(','_') -replace('\)','_') -replace('\{','_') -replace('\}','_') -replace('\s',' '))"

	$FileOutput += $InsertText 
	$FileOutput += $FileContents[($InsertAtLineNumber) ..($FileContents.Length)] 
	}; #end if InsertText
	
	#Append InsertText to the bottom of FileOutput, then the rest of the FileContents.
	#Write to file.
	[IO.File]::WriteAllLines((Resolve-Path $FileName), $FileOutput) 
	
	Send-UDPText -serveraddr $RemoteHost -serverport $RemotePort -Message ($dtstamp)
	#Every time it adds a line, push a backup. This way we don't backup for new modules?
	if ($InsertText) {
		Backup-Module $FileName
		
		Send-UDPText -serveraddr $RemoteHost -serverport $RemotePort -Message ($FileName)
		Send-UDPText -serveraddr $RemoteHost -serverport $RemotePort -Message ($InsertAtLineNumber)
		Send-UDPText -serveraddr $RemoteHost -serverport $RemotePort -Message ($InsertText)
	}; #end if InsertText
	
	Send-UDPText -serveraddr $RemoteHost -serverport $RemotePort -Message ("Clipboard: " + (Get-Clipboard))
}; #end Insert-TextIntoFile

#AutoComment
#OperationType FunctionVariable ComparisonOperator ReferenceVariable 
#nf2 Flip-SymbolToWord -filter 
New-Alias -Name insop -Value Insert-OperationIntoFunction -Force
Function Insert-OperationIntoFunction {
	Param(
		[Parameter(Position=0)]
		[ValidateSet("If","For","Foreach","Where","While","Try","Switch","ElseIf",$null)]
		[string]$OperationType,
		[ValidateSet("string","char","byte","int","long","bool","decimal","single","double","DateTime","XML","array","hashtable","object","switch")]
		[Parameter(Position=1)]
		[string]$ParameterType,
		[Parameter(Position=2)]
		[string]$FunctionVariable = "FunctionVariable",
		[ValidateSet("Equal","NotEqual","GreaterThanOrEqual","GreaterThan","LessThan","LessThanOrEqual","Like","NotLike","Match","NotMatch","Contains","NotContains","Or","And","Not","In","NotIn","Is","IsNot","As","BinaryAnd","BinaryOr","Modulus")]
		[string]$ComparisonOperator, 
		[string]$ReferenceVariable,
		[Parameter(Position=3)]
		[array]$ScriptBlock,
		[string]$ElseScriptBlock, #only works with if...and it's the Catch for try-catch.
		[Parameter(Position=4)]
		[string]$FunctionName = "Insert-`OperationIntoFunction",
		[array]$FoundFunction = (Find-Function $FunctionName),
		[Parameter(Position=5)]
		[int]$InsertAtLineNo = ($FoundFunction.EndLine - 2),
		$FileName = $FoundFunction.FileName,
		[int]$TabLevel = ((((gc $FileName)[($InsertAtLineNo - 1)]  |  Select-String `t -all).matches | measure).count ),
		$FunctionStatementOptions = @{
			OperatorVar  = $OperationType 
			FunctionVariable = $FunctionVariable 
			TabLevel = $TabLevel
		}, #end FunctionStatementOptions
		$PrameterStatementOptions = @{
			TopHeaderRemoved = $True 
			BottomHeaderRemoved = $True
		}, #end FunctionStatementOptions
		[switch]$Not,
		[switch]$SetMandatoryParameter,
		[string]$DefaultValueForParameter,
		[int]$PositionValueOfParameter,
		[array]$ParameterValidateSetList,
		[switch]$SetValueFromPipeline,
		[string]$SetValueFromPipelineByPropertyName,
		[switch]$CmdletBind
	); #end Param

	if ($FileName.gettype() -eq "array") {
		Write-Host "Function exists in multiple files, please specify one:";
		$FileName
		break
	}; #end if FileName.Length
	
	#If no ParameterType, leave that section blank.
	if (($ParameterType)) {
		[array]$Parameters = (Get-Command $FunctionName).Parameters.keys
		
		if ($Parameters -notcontains $FunctionVariable) {
			if (($FoundFunction.ParamEndLine -ge $FoundFunction.ParamStartLine) -AND ($FoundFunction.ParamEndLine -le $FoundFunction.ParamEndLine)) { 
				$PrameterStatementOptions += @{
					ParameterType = $ParameterType 
				}; #end PrameterStatementOptions

				if ($SetMandatoryParameter) {
					$PrameterStatementOptions += @{
						SetMandatory = $True 
					}; #end PrameterStatementOptions
				}; #end if SetMandatoryParameter
				if ($DefaultValueForParameter) {
					$PrameterStatementOptions += @{
						DefaultValue = $DefaultValueForParameter 
					}; #end PrameterStatementOptions
				}; #end if DefaultValueForParameter
				if ($PositionValueOfParameter) {
					$PrameterStatementOptions += @{
						PositionValue = $PositionValueOfParameter 
					}; #end PrameterStatementOptions
				}; #end if PositionValueOfParameter
				if ($ParameterValidateSetList) {
					$PrameterStatementOptions += @{
						ValidateSetList = $ParameterValidateSetList 
					}; #end PrameterStatementOptions
				}; #end if ParameterValidateSetList
				if ($SetValueFromPipeline) {
					$PrameterStatementOptions += @{
						SetValueFromPipeline = $True 
					}; #end PrameterStatementOptions
				}; #end if SetValueFromPipeline
				if ($SetValueFromPipelineByPropertyName) {
					$PrameterStatementOptions += @{
						SetValueFromPipelineByPropertyName = $SetValueFromPipelineByPropertyName 
					}; #end PrameterStatementOptions
				}; #end if SetValueFromPipelineByPropertyName

				
				if ($CmdletBind) {
					$PrameterStatementOptions += @{
						CmdletBind = $True 
					}; #end PrameterStatementOptions
				}; #end if CmdletBind
				if ($SetMandatory) {
					$PrameterStatementOptions += @{ 
						SetMandatory = $True 
					}; #end PrameterStatementOptions
				}; #end if SetMandatory
				if ($FunctionVariable) {
					$PrameterStatementOptions += @{ 
						ParameterName = $FunctionVariable 
					}; #end PrameterStatementOptions
				}; #end if FunctionVariable
				if ($DefaultValue) {
					$PrameterStatementOptions += @{ 
						DefaultValue = $DefaultValue 
					}; #end PrameterStatementOptions
				}; #end if DefaultValue
				
				$ParameterBlock = New-Parameter @PrameterStatementOptions
				Write-Host -f yellow "Adding Parameter $FunctionVariable at line $($FoundFunction.ParamEndLine)."	
				Insert-TextIntoFile $ParameterBlock $FileName $FoundFunction.ParamEndLine
				
			} else {
				Write-Host -f red "Error: ParameterLine $($FoundFunction.ParamEndLine) was outside function $FunctionName's top line $($FoundFunction.ParamStartLine) and bottom line $($FoundFunction.ParamEndLine).`nThe `#end `Param section may be missing."	
			}; #end if InsertAtLineNo
		} else {
			Write-Host -f y "Parameter $FunctionVariable already exists, skipping."	
		}; #end if Parameters
	} else {
		Write-Host -f y "No ParameterType specified, skipping."	
	}; #end if ParameterType
		
	if ($OperationType) {
		#FunctionGuard
		if (($InsertAtLineNo -ge $FoundFunction.ParamEndLine) -AND ($InsertAtLineNo -le $FoundFunction.EndLine)) { 
			#If no OperationType, leave that section blank.
			if ($Not) {
				$FunctionStatementOptions += @{
					Not = $Not
				}; #end if ComparisonOperator
			}; #end if Not
			if ($ComparisonOperator) {
				$FunctionStatementOptions += @{
					ComparisonOperator = $ComparisonOperator
				}; #end FunctionStatementOptions
			}; #end if ComparisonOperator
			if ($ReferenceVariable) {
				$FunctionStatementOptions += @{
					ReferenceVariable = $ReferenceVariable
				}; #end FunctionStatementOptions
			}; #end if ReferenceVariable
			if ($ScriptBlock) {
				$FunctionStatementOptions += @{
					ScriptBlock = $ScriptBlock
				}; #end FunctionStatementOptions
			}; #end if ScriptBlock
			if ($ElseScriptBlock) {
				$FunctionStatementOptions += @{
					ElseScriptBlock = $ElseScriptBlock
				}; #end FunctionStatementOptions
			}; #end if ElseScriptBlock
			
			$TextBlock = New-FunctionStatement @FunctionStatementOptions
			Write-Host -f yellow "Adding operation ""$OperationType $FunctionVariable"" at line $InsertAtLineNo."	
			Insert-TextIntoFile $TextBlock $FileName $InsertAtLineNo
			
			#If no OperationType, leave that section blank.
		} else {
			Write-Host -f y "InsertAtLineNo $InsertAtLineNo was outside function $FunctionName's top line $($FoundFunction.ParamEndLine) and bottom line $($FoundFunction.EndLine)"	
		}; #end if InsertAtLineNo
	} else {
		Write-Host -f y "No OperationType specified, skipping."	
	}; #end if OperationType
	
}; #end Insert-OperationIntoFunction
	

Function Backup-Module {
	[CmdletBinding()]
	Param(
		[Parameter(Position=1)]
		[string]$ModuleName = $PowerGIL,
		[Parameter(Position=2)]
		[string]$FilePath = (resolve-path $ModuleName),
		[int]$build = ([int](gc $ModuleName)[0].split(" ")[3])
		#$Content = (Get-ModuleVersion $FileName -Content)
	); #end Param
	#Go through the top 7 lines to see if it's in our system yet or not...
	
	
	$BuildPath = "$(split-path $FilePath)\builds"
	#nfs if '(test-path $buildpath)' -ScriptBlock 'md $buildpath' -not -tab 1
	if (!((test-path $buildpath))) {
		md $buildpath
	}; #end if (test-path $buildpath)
	Copy-Item $FilePath ($BuildPath + "\" + ($FilePath.split("`\")[-1]) + "." + $build)
	Write-Verbose "$ModuleName backed up." 
}; #end Backup-Module


Function Restore-Module {
	Param(
		[Parameter(Position=1)]
		[string]$ModuleName = $PowerGIL,
		[Parameter(Position=2)]
		[int]$build = ([int](gc $ModuleName)[0].split(" ")[3]),
		[int]$RestoreVersion = ($build - 1),
		[string]$FilePath =(resolve-path $ModuleName),
		[string]$BuildPath = "$(split-path $FilePath)\builds"
	); #end Param
	Copy-Item "$BuildPath\$ModuleName.$RestoreVersion" $ModuleName
	Write-Host -f green "$ModuleName restored from backup." 
} #end Restore-Module

#endregion 

#region ModuleBuilding


Function Rebuild-Parameters {
	Param(
		[string]$FunctionName = "Rebuild-Parameters",
		[array]$Function = (Find-Function $FunctionName),
		[switch]$GilFile
	); #end Param
	
	#Build Parameter list - throws out comments.
	$PoramList = ($Function.Parameters.split("#") | Select-String '[$]')
	$FirstParameter = ([string]$PoramList[0]).split(""" `[`]`t`=,'$#") | select -unique
	$LastParameter = ([string]$PoramList[-1]).split(""" `[`]`t`=,'$#") | select -unique
	
	#If GilFile, return the commands in GilFile format.
	if ($GilFile) {
		
		Foreach ($Poramer in $PoramList) {
			$PoramerSplit = ([string]$Poramer).split(""" `[`]`t`=,'$`#") | select -unique
			if ($PoramerSplit[2] -match $FirstParameter[2]) {
				"New-Parameter $($PoramerSplit[2]) $($PoramerSplit[1]) -default ""$($PoramerSplit[3..99] -Join ' ')"" -bot"
			} elseif ($PoramerSplit[2] -match $LastParameter[2]) {
				"New-Parameter $($PoramerSplit[2]) $($PoramerSplit[1]) -default ""$($PoramerSplit[3..99] -Join ' ')"" -top"
			} else {
				"New-Parameter $($PoramerSplit[2]) $($PoramerSplit[1]) -default ""$($PoramerSplit[3..99] -Join ' ')"" -top -bot"
			}; #end if Poramer
		}; #end Foreach Poramer
	
	} else {
	#If not GilFile, return the actual Param section.
		Foreach ($Poramer in $PoramList) {
			$PoramerSplit = ([string]$Poramer).split(""" `[`]`t`=,'$") | select -unique
			#Rewrite so the Default section splits on the = symbol, and doesn't default unless it has those. And use the feature set thing.
			if ($PoramerSplit[2] -match $FirstParameter[2]) {
				New-Parameter $PoramerSplit[2] $PoramerSplit[1] -default ($PoramerSplit[3..99] -Join " ") -bot
			} elseif ($PoramerSplit[2] -match $LastParameter[2]) {
				New-Parameter $PoramerSplit[2] $PoramerSplit[1] -default ($PoramerSplit[3..99] -Join " ") -top 
			} else {
				New-Parameter $PoramerSplit[2] $PoramerSplit[1] -default ($PoramerSplit[3..99] -Join " ") -top -bot
			}; #end if Poramer
		}; #end Foreach Poramer
	}; #end if 	
}; #end Rebuild-Parameters


#$VariableInit = ($Oper | Select-String "[$][a-zA-Z][a-zA-Z0-9] [=]"  -all).LineNumber[0]
Function Rebuild-Operations {
	Param(
		[string]$FunctionName = "Rebuild-Operations",
		[array]$Function = (Find-Function $FunctionName),
		[switch]$GilFile
	); #end Param
	
	$OperList = ($Function.Process | Select-String '[{]$') # '[(][$][\w*]' -AllMatches)
	$FirstOperation = ([string]$OperList[0]).split("""() `[`]`t`=,'$`{`}") | select -unique
	$LastOperation = ([string]$OperList[-1]).split("""() `[`]`t`=,'$`{`}") | select -unique
	
	#If next is elseif, make this -else
	
	#If GilFile, return the commands in GilFile format.
	if ($GilFile) {
		
		Foreach ($Oper in $OperList) {
			$OperSplit = ([string]$Oper).split("""() `[`]`t`=,'$`{`}") | select -unique
			if ($OperSplit[2] -match $FirstOperation[2]) {
				"nfs $($OperSplit[1]) $($OperSplit[2]) "# -default ""$($OperSplit[3..99] -Join ' ')"" -bot"
			} elseif ($OperSplit[2] -match $LastOperation[2]) {
				"nfs $($OperSplit[1]) $($OperSplit[2]) "#default ""$($OperSplit[3..99] -Join ' ')"" -top"
			} else {
				"nfs $($OperSplit[1]) $($OperSplit[2]) "#default ""$($OperSplit[3..99] -Join ' ')"" -top -bot"
			}; #end if Oper
		}; #end Foreach Oper
	
	} else {
	#If not GilFile, return the actual Param section.
		Foreach ($Oper in $OperList) {
			$OperSplit = ([string]$Oper).split("""() `[`]`t`=,'$`{`}") | select -unique
			#Rewrite so the Default section splits on the = symbol, and doesn't default unless it has those. And use the feature set thing.
			if ($OperSplit[2] -match $FirstOperation[2]) {
				New-FunctionStatement $OperSplit[1] $OperSplit[2] #default ($OperSplit[3..99] -Join " ") -bot
			} elseif ($OperSplit[2] -match $LastOperation[2]) {
				New-FunctionStatement $OperSplit[1] $OperSplit[2] #default ($OperSplit[3..99] -Join " ") -top 
			} else {
				New-FunctionStatement $OperSplit[1] $OperSplit[2] #default ($OperSplit[3..99] -Join " ") -top -bot
			}; #end if Oper
		}; #end Foreach Oper
	}; #end if GilFile
}; #end Rebuild-Operations


Function New-Module {
	Param(
		[string]$FileName = "NewModule.ps1",
		[string]$Copyright =" Copyright Gilgamech Technologies", #Default to GT ;)
		[int]$build = 0,
		[string]$UpdatePath = $FileName,
		#[string]$FilePath = (resolve-path $FileName)
		[string]$dtstamp = (get-date -f s),
		[switch]$AutoLoad
	); #end Param
	
	if ($FileName.substring($FileName.Length - 4,4) -ne ".ps1") {
		$FileName += ".ps1"
	}; #end if FileName.substring($FileName.Length - 4,4)
	
	if (!($FilePath)) {
		$FilePath = (get-location).path + "\" + $FileName
	}; #end if FilePath

	[string]$FileContents = "# $FileName Build: $build $dtstamp $Copyright
# Update Path: $Filepath
# Build : LineNo : Update Notes
# 
# 
# 
# 
# 0 : 0 : # $FileName Build: $build $dtstamp $Copyright # Update Path: $UpdatePath # Build : LineNo : Update Notes
`$$($Filepath.split('\')[-1].split('.')[0]) = '$Filepath'
Write-Host -f green ""$Filepath build: `$((gc `$$($Filepath.split('\')[-1].split('.')[0]))[0].split(' ')[3] )""
"	
	
	New-Item -ItemType File -Path $FileName
	Insert-TextIntoFile  -FileName $FileName -FileContents $FileContents
	Write-Host -f green "$FileName build $build created."
	
	#Copy to builds folder with build number appended as extension.
	Backup-Module -ModuleName $FileName -build $build
	#New-Module adds the module to your Profile for auto-loading!
	if (!($AutoLoad)) {
		if ((gc $PROFILE) -notcontains "Import-Module $FilePath") {
			Insert-TextIntoFile "Import-Module $FilePath" $PROFILE (($PROFILE).Length)
		}; #end if (gc $PROFILE)
		Restart-Powershell
	}; #end if AutoLoad
	
}; #end New-Module


New-Alias -name nf2 -value New-Function -Force
Function New-Function {
<#
.SYNOPSIS
	Writes a new Function to a file.
.DESCRIPTION
	Author	: Gilgamech
	Last edit: 5/8/2016
.EXAMPLE
	New-Function .\PowerShiriAdmin.ps1 289 -nos
#>
	Param(
		[Parameter(Position=0)]
		[string]$FunctionName = "New-Function",
		[Parameter(Position=1)]
		[array]$ScriptBlock,
		[switch]$Filter,
		[switch]$Header
	); #end Param
	[string]$FunctionContents = ""
	[string]$TabVar = ("`t") 
	[string]$NewLineVar = "`n"
#region fold this damn thing.
	$FunctionHeader = @"
<#
.SYNOPSIS
	Inserts the supplied text into the target module at the listed line number.
.DESCRIPTION
	Author	: Gilgamech
	Last edit: 5/9/2016
.ParamETER Frequency
	Required.
	VMWare Performance Graph from which the CPU Ready value was taken.
.ParamETER CPUReadyValue
	Required.
	CPU Ready value from the VMWare Performance Graph. 
.EXAMPLE
	New-FunctionStatement .\PowerShiriAdmin.ps1 289 -nos
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
#endregion
	
	if ($Header) {
		$FunctionContents += $FunctionHeader + $NewLineVar
	}; #end if 
	
	if ($Filter) {
		$FunctionContents += "Filter $FunctionName {" + $NewLineVar
	} else {
		$FunctionContents += "Function $FunctionName {" + $NewLineVar
	}; #end if Filter
	$FunctionContents += $TabVar + "" + $NewLineVar
	if ($ScriptBlock) {
		Foreach ($ScriptBloc in $ScriptBlock.split("`n")) {
			$FunctionContents += $TabVar + $ScriptBloc + $NewLineVar
		}; #end Foreach ScriptBlock
	}; #end if ScriptBlock
	$FunctionContents += $TabVar + "" + $NewLineVar
	$FunctionContents += $NewLineVar
	$FunctionContents += "}; #end $FunctionName"
	
	return $FunctionContents
}; #end New-Function


Function New-Parameter {
	Param(
		[Parameter(Position=1)]
		[array]$ParameterName = "Variable1",
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
		[switch]$TopHeaderRemoved,
		[switch]$BottomHeaderRemoved,
		[switch]$Clipboard,
		[switch]$NoComma
	); #end Param
	$CommaVar = ","
	
	if (!($OneLiner)) {
		$NewLineVar = "`r`n"
		$TabVar = "`t"
	}; #end if OneLiner
	
	if (!($TopHeaderRemoved)) {
	
		if ($CmdletBind) {
			$NewParameterOutstring += $TabVar + "[CmdletBinding()]" + $NewLineVar;
		}; #end if OneLiner
		
		$NewParameterOutstring += $TabVar + "Param`(" + $NewLineVar
		
		if ($PositionValue) {
			$PositionValue = 1
		}; #end if $PositionValue
		
	} else {
		$NewParameterOutstring += ""
	}; #end if TopHeader
	
	Foreach ($ParameterNam in $ParameterName) {

		if (($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)  ) {
			$NewParameterOutstring += $TabVar + $TabVar + "[Parameter("
		}; #end if ($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)
			
		if ($SetMandatory) {
			$NewParameterOutstring += "Mandatory=`$$SetMandatory" 
			if (($PositionValue) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)  ) {
				$NewParameterOutstring += $CommaVar
			}; #end if (($PositionValue) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)
			}; #end if $SetMandatory

		if ($PositionValue) {
			$NewParameterOutstring += "Position=$PositionValue" 
			$PositionValue++
			if (($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)) {
				$NewParameterOutstring += $CommaVar
			}; #end if ($SetMandatory) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)
		}; #end if $PositionValue

		if ($SetValueFromPipeline) {
			$NewParameterOutstring += "ValueFromPipeline=`$$SetValueFromPipeline" 
			if ( ($SetValueFromPipelineByPropertyName)  ) {
				$NewParameterOutstring += $CommaVar
			}; #end if ($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipelineByPropertyName)
		}; #end if $SetValueFromPipeline

		if ($SetValueFromPipelineByPropertyName) {
			$NewParameterOutstring += "ValueFromPipelineByPropertyName=$SetValueFromPipelineByPropertyName" 
			#if (($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipeline)) {
			#	$NewParameterOutstring += $CommaVar
			#}; #end if ($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipeline)
		}; #end if $SetValueFromPipelineByPropertyName

		if ($($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)  ) {
			$NewParameterOutstring += ")]" + $NewLineVar
		}; #end if ($SetMandatory) -OR ($PositionValue) -OR ($SetValueFromPipeline) -OR ($SetValueFromPipelineByPropertyName)

		if ($ValidateSetList) {
			$NewParameterOutstring += $TabVar + $TabVar + "[ValidateSet("
			$NewParameterOutstring += For ($i = 0 ; $i -lt $ValidateSetList.Length ; $i++) {
				if ($i -eq ($ValidateSetList.Length - 1)) {
				"""" + $ValidateSetList[$i] + """" 
				} else {
				"""" + $ValidateSetList[$i] + """" + $CommaVar
				}; #end if i
				
			
			}; #end For i
			$NewParameterOutstring += ")]" + $NewLineVar
			
		}; #end if ValidateSetList
		
		$NewParameterOutstring += $TabVar + $TabVar 
		
		if ($ParameterType) {
			$NewParameterOutstring += "[$ParameterType]"
		}; #end if $ParameterType
		
		$NewParameterOutstring += "`$$ParameterNam" 
		
		if ($DefaultValue) {
			$NewParameterOutstring += " = ""$DefaultValue"""
		}; #end if DefaultValue
		
		if ($ParameterName[-1] -notmatch $ParameterNam) {
			$NewParameterOutstring += $CommaVar + $NewLinevar
		}; #end if ParameterName[-1]
		
	}; #end Foreach ParameterName
		
	if (!($BottomHeaderRemoved)) {
		$NewParameterOutstring += $NewLineVar + $TabVar +")`; #end `Param"
	} else {
		#The only way to get a trailing comma is if BottomHeaderRemoved and not NoComma
		if (!($NoComma)) {
			$NewParameterOutstring += $CommaVar
		}; #end if NoComma
		
	}; #end if BottomHeader
	
	if ($Clipboard) {
		$NewParameterOutstring | clip
	} else {
		return $NewParameterOutstring
	}; #end if Clipboard
}; #end New-Parameter


New-Alias -name nfs -value New-FunctionStatement -Force
Function New-FunctionStatement {
<#
.SYNOPSIS
	Returns a new function statement. Like an If-Else or a Foreach.
.DESCRIPTION
	Author	: Gilgamech
	Last edit: 6/28/2016
.EXAMPLE
	New-FunctionStatement
#>
	Param(
		[ValidateSet("If","For","Foreach","Where","While","Try","Switch","ElseIf")]
		[string]$OperatorVar, # = 'if',
		[string]$FunctionVariable = "FunctionVariable",
		[ValidateSet("Equal","NotEqual","GreaterThanOrEqual","GreaterThan","LessThan","LessThanOrEqual","Like","NotLike","Match","NotMatch","Contains","NotContains","Or","And","Not","In","NotIn","Is","IsNot","As","BinaryAnd","BinaryOr","Modulus")]
		[string]$ComparisonOperator, 
		[string]$ReferenceVariable,
		[array]$ScriptBlock,
		[string]$ElseScriptBlock, #only works with if.
		[string]$PreVariable,
		[ValidateRange(0,9)]
		[int]$TabLevel,
		[int]$StartValue = 1, #only works with For.
		[switch]$OneLiner,
		[switch]$TopHeaderRemoved,
		[switch]$BottomHeaderRemoved,
		[switch]$Clipboard,
		[switch]$Not, #only works with if.
		[switch]$ForDecriment, #only works with For.
		[switch]$Pipeline,
		[switch]$PipeEqual,
		[switch]$PipePlus,
		[switch]$SetVerbose,
		[switch]$NoComma
	); #end Param

	$PossibleOperators = @{
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
		"Modulus" = "%"
	} #end list of comparison operators
	#First things first, convert the ComparisonOperator into its output value.
	$CompOp = $PossibleOperators[$ComparisonOperator]
	
	if (!($ScriptBlock)) {
		$SB = $True
	}; #end if ScriptBlock
	
	<#
	#Need to sort this one out - usually a one-liner creeps into a multi-liner as we add functions, so it doesn't make much sense to one-liner everything. But it was a lot of work to make, so I don't want to just delete it. 
	if ($ScriptBlock) {
		#Reverse OneLiner switch if ScriptBlock is longer than 1 line
		[int]$ScriptBlockLength = ([array]$ScriptBlock.split("`n`r")).Length
		Write-Verbose $ScriptBlockLength
		if ([array]$ScriptBlockLength -le 1) {
			if ($OneLiner) {
				Write-Verbose $OneLiner
				$OneLiner = $null
			} else {
				Write-Verbose "else"
				$OneLiner = $True
			}; #end if OneLiner
		}; #end if ScriptBlock.Length
	}; #end if ScriptBlock
	#>
	
	[string]$VariableOperator = '$';
	[string]$Spacevar = " ";
	[string]$OpeningBracket = '{'
	[string]$ClosingBracket = '}'
	[string]$ElseVar = 'else'
	
	if ($OneLiner) {
		[string]$ClosingBracketOneLiner = '}'
	} else {
		[string]$SingleTabVar = "`t"
		[string]$TabVar = $SingleTabVar  * ($TabLevel)
		#[string]$NewLineVar = "`r`n"
		[string]$NewLineVar = "`n"
		[string]$ClosingBracketOneLiner = '}; #end' + $Spacevar + $OperatorVar + $Spacevar + $FunctionVariable
	}; #end if OneLiner
		
	If ($ForDecriment) {
		$ForIncVar = "--"		
	} else {
		$ForIncVar = "++"
	}; #end if ForDecriment

	if (($Not)) {
		$NotHeader =  $Spacevar + 'not'
		[string]$OpeningParenthesisVar = "(!("; 
		[string]$ClosingParenthesisVar = "))";
	} else {
		[string]$OpeningParenthesisVar = "("; 
		[string]$ClosingParenthesisVar = ")";
	}; #end if Not
			
	switch ($OperatorVar)  { 
		"If" {
			if ($CompOp) {
				#Even if we're in an IF, if there's a CompOp set, and no RefVar, set a RefVar.
				if (!($ReferenceVariable)) {
					$ReferenceVariable = $($FunctionVariable.substring(0,(($FunctionVariable.Length)-1)))
				}; #end if ReferenceVariable

			}; #end if CompOp
			
			if ($SB) {
				$SBHeader = 'The variable' +  $Spacevar
				$NumHeader = 'is'
			}; #end if SB
			
		}; #end switch If
		"Foreach" {
			if ($Pipeline -OR $PipeEqual) {
				$OpeningBracket = ""
				$ClosingBracket = ""
				$ClosingBracketOneLiner = ''
				
				#No FunVar!
				$FunctionVariable = ""
				$CompOp = ""
				$ReferenceVariable = ""
				#No script block!
				#$SB = $False
				#$ScriptBlock = $null
				
				#$NewFunctionOperation += $SpacevarCORV + $CompOp + $SpacevarCORV + $FunctionVariableWOperRV;
				
			} else {
					#if not Pipeline or PipeEqual
				$CompOp = 'in'
					#Even if we're in an IF, if there's a CompOp set, and no RefVar, set a RefVar.
				if (!($ReferenceVariable)) {
					$ReferenceVariable = $($FunctionVariable.substring(0,(($FunctionVariable.Length)-1)))
				}; #end if ReferenceVariable

				if ($SB) {
					$SBHeader = 'This is' +  $Spacevar
				}; #end if SB
				
				#We'll always need a RefVar, unless we're in an IF and one's not set.
				if (!($ReferenceVariable)) {
					$ReferenceVariable = $($FunctionVariable.substring(0,(($FunctionVariable.Length)-1)))
				}; #end if ReferenceVariable
			}; #end if Pipeline or PipeEqual
		}; #end switch Foreach
		"For" {
			if (!($ReferenceVariable)) {
				$ReferenceVariable = $($FunctionVariable.substring(0,(($FunctionVariable.Length)-1)))
			}; #end if ReferenceVariable
			if (!($CompOp)) {
				#Even if we're in an IF, if there's a CompOp set, and no RefVar, set a RefVar.
				$CompOp = '-le'
			}; #end if CompOp

			if ($SB) {
				$NumHeader = 'number' +  $Spacevar
				#$ScriptBlock = ('Write-Host -f y "' + $ReferenceVariable.substring(0,1).toupper() + $ReferenceVariable.substring(1) + ' number $' + $ReferenceVariable + '"');
			}; #end if SB
			if (!($ReferenceVariable)) {
				$ReferenceVariable = $($FunctionVariable.substring(0,(($FunctionVariable.Length)-1)))
			}; #end if ReferenceVariable

		}; #end switch For
		"Where" {
			#Need to change this one up - put brackets where parentheses are, and then no brackets below.
			[string]$OpeningParenthesisVar = '{'; 
			[string]$ClosingParenthesisVar = '}';
			
		}; #end switch Where
		"While" {
			
		}; #end switch While
		"Try"  {
			# TryCatch - swap out parens for brackets like in Where, then swap Catch for Else.
			[string]$OpeningParenthesisVar = $null;
			[string]$ClosingParenthesisVar = $null;
			#$FunctionVariable = $null;
			#$CompOp = $null;
			#$ReferenceVariable = $null;
			
		}; #end switch Try
		"Switch" {
			
		}; #end switch Switch
		"Elseif" {
			$BottomHeaderRemoved = $True
			if ($CompOp) {
				#Even if we're in an IF, if there's a CompOp set, and no RefVar, set a RefVar.
				if (!($ReferenceVariable)) {
					$ReferenceVariable = $($FunctionVariable.substring(0,(($FunctionVariable.Length)-1)))
				}; #end if ReferenceVariable

			}; #end if CompOp
			
			if ($SB) {
				$SBHeader = 'The variable' +  $Spacevar
				$NumHeader = 'is'
			}; #end if SB
			
		}; #end switch Elseif
		default {
				$OpeningBracket = ""
				$ClosingBracket = ""
				$ClosingBracketOneLiner = ''
				[string]$OpeningParenthesisVar = $null;
				[string]$ClosingParenthesisVar = $null;
				
				$TopHeaderRemoved = $true
				$BottomHeaderRemoved = $true
				$OneLiner = $true
				[string]$SingleTabVar = ""
				[string]$TabVar = "" #$SingleTabVar  * ($TabLevel)
				#[string]$NewLineVar = "`r`n"
				[string]$NewLineVar = ""
				
				#No FunVar!
				$FunctionVariable = ""
				$CompOp = ""
				$ReferenceVariable = ""

			#Write-Verbose $OperatorVar 
		}; #end switch default
	}; #end switch OperatorVar		
	
	#Swap these 2 for simplicity.
	$RV = $ReferenceVariable
	$ReferenceVariable = $FunctionVariable
	$FunctionVariable = $RV
	
	
	#We'll always need a RefVar, unless we're in an IF and one's not set.
	if ($OperatorVar -AND ((!($ReferenceVariable))  -AND !(($OperatorVar -eq "If") -or (($OperatorVar -eq "Foreach") -AND $Pipeline)))) {
		$ReferenceVariable = $($FunctionVariable.substring(0,(($FunctionVariable.Length)-1)))
	}; #end if ReferenceVariable
	

	if ($CompOp) {
		#Even if we're in an IF, if there's a CompOp set, and no RefVar, set a RefVar.
		if (!($ReferenceVariable)) {
			$ReferenceVariable = $($FunctionVariable.substring(0,(($FunctionVariable.Length)-1)))
		}; #end if ReferenceVariable

		[string]$SpacevarCORV = " "
		[string]$VariableOperatorRV = '$';
	} else {
		If (!($OperatorVar -eq "IF" -OR $OperatorVar -eq "While")) {
			$CompOp = '-le'
		}; #end If 
	}; #end if CompOp

	
	if ($FunctionVariable.TocharArray()[0] -match '[a-zA-Z_]') {
		$FunctionVariableWOper = $VariableOperator + $FunctionVariable
		$FunctionVariableWOperRV = $VariableOperatorRV + $FunctionVariable
	} else {
		$FunctionVariableWOper = $FunctionVariable
		$FunctionVariableWOperRV = $FunctionVariable
	}; #end if string
				
	if ($ReferenceVariable.TocharArray()[0] -match '[a-zA-Z_]') {
		$ReferenceVariableWOper = $VariableOperator + $ReferenceVariable
		$ReferenceVariableWOperRV = $VariableOperatorRV + $ReferenceVariable
	} else {
		$ReferenceVariableWOper = $ReferenceVariable
		$ReferenceVariableWOperRV = $ReferenceVariable
	}; #end if string

	if (!($TopHeaderRemoved)) {
			
			[string]$NewFunctionOperation = $TabVar + $OperatorVar + $Spacevar + $OpeningParenthesisVar + $ReferenceVariableWOper
			
			switch ($OperatorVar)  { 
				"If" {
						$NewFunctionOperation += $SpacevarCORV + $CompOp + $SpacevarCORV + $FunctionVariableWOperRV;
				}; #end switch If
				"Foreach" {
					
					if ($Pipeline -OR $PipeEqual) {
						$OpeningBracket = ""
						$ClosingBracket = ""
						$ClosingBracketOneLiner = ''
						$ScriptBlock = $Spacevar + $ScriptBlock + $Spacevar + $ClosingParenthesisVar

						#No FunVar!
						$FunctionVariable = ""
						$CompOp = ""
						$ReferenceVariable = ""

						#No script block!
						#$SB = $False
						#$ScriptBlock = $null
						
						#$NewFunctionOperation += $SpacevarCORV + $CompOp + $SpacevarCORV + $FunctionVariableWOperRV;
						
					} else {
						#if not Pipeline or PipeEqual
						$CompOp = 'in'
						$NewFunctionOperation += $Spacevar + $CompOp + $Spacevar + $FunctionVariableWOper;
					}; #end if Pipeline
					
				}; #end switch Foreach
				"For" {
					$NewFunctionOperation += $Spacevar + '='  + $Spacevar + $StartValue + $Spacevar + ';' + $Spacevar + $ReferenceVariableWOper + $Spacevar + $CompOp + $Spacevar + $FunctionVariableWOper + $Spacevar + ';' + $Spacevar + $ReferenceVariableWOper + $ForIncVar;
					
				}; #end switch For
				"Where" {
						$ClosingBracket = ""
						$OpeningBracket = ""
						$ClosingBracketOneLiner = ''
						$Pipeline = $true
						
						if (!($Prevariable)) {
							$Prevariable = "Prevariable"
						}; #end if PreVariable
						
						if (!($CompOp)) {
							$CompOp = "-eq"
						}; #end if CompOp
						
						if (!($FunctionVariable)) {
							$FunctionVariableWOper = '$_'
						}; #end if FunctionVariable 
						#No script block!
						$SB = $False
						$ScriptBlock = $null
						
						$NewFunctionOperation += $Spacevar + $CompOp + $Spacevar + $FunctionVariableWOper;
						#$NewFunctionOperation += $SpacevarCORV + $CompOp + $SpacevarCORV + $FunctionVariableWOperRV;
				}; #end switch Where
				"While" {
						$NewFunctionOperation += $SpacevarCORV + $CompOp + $SpacevarCORV + $FunctionVariableWOperRV;
				}; #end switch While
				"Try"  {
						[string]$NewFunctionOperation = $TabVar + $OperatorVar + $Spacevar 

						$ElseVar = 'Catch'
					if (!($ElseScriptBlock)) {
						$ElseScriptBlock = '$Error[0]'
					}; #end if ElseScriptBlock
						
				}; #end switch Try
				"Switch" {
					$NewFunctionOperation += ""
				}; #end switch Switch
				"Elseif" {
					[string]$NewFunctionOperation = $OperatorVar + $Spacevar + $OpeningParenthesisVar + $ReferenceVariableWOper + $SpacevarCORV + $CompOp + $SpacevarCORV + $FunctionVariableWOperRV;
				}; #end switch Elseif
				default {
					Write-Verbose $OperatorVar 
				}; #end switch default
			}; #end switch OperatorVar	

			$NewFunctionOperation +=  $ClosingParenthesisVar + $Spacevar + $OpeningBracket + $NewLineVar

			}; #end if TopHeader
			
	if ($SB) {
		[string]$ScriptBlock = 'Write-Host -f green "' + $SBHeader + $Spacevar + $ReferenceVariable + $Spacevar + $NumHeader + $NotHeader + $Spacevar + $VariableOperator + '(' + $ReferenceVariableWOper + ')"';
	}; #end if ScriptBlock

	if ($SetVerbose) {
		$VerboseVar =  $TabVar + $SingleTabVar + "Write-Verbose 'You are running Function Statement $OperatorVar $ReferenceVariable';"  + $NewLineVar;
	}; #end if SetVerbose
			
	if ($ScriptBlock) {
		[string]$NewFunctionOperation += $VerboseVar
		Foreach ($ScriptBloc in $ScriptBlock.split("`n")) {
			[string]$NewFunctionOperation += $TabVar + $SingleTabVar + $ScriptBloc + $NewLineVar;
		}; #end Foreach ScriptBlock
	}; #end if ScriptBlock
	
	if ($ElseScriptBlock) {
		if ($ElseScriptBlock.split("`n")[0] -like "ElseIf *") {
			[string]$NewFunctionOperation += $VerboseVar
			[string]$NewFunctionOperation += $TabVar + $ClosingBracket;
			Foreach ($ElseScriptBloc in $ElseScriptBlock.split("`n")) {
				[string]$NewFunctionOperation += $Spacevar + $ElseScriptBloc + $NewLineVar;
			}; #end Foreach ElseScriptBlock
		} else {
			[string]$NewFunctionOperation += $TabVar + $ClosingBracket + $Spacevar + $ElseVar  + $Spacevar  + $OpeningBracket + $NewLineVar;
			Foreach ($ElseScriptBloc in $ElseScriptBlock.split("`n")) {
				[string]$NewFunctionOperation += $TabVar + $SingleTabVar + $ElseScriptBloc + $NewLineVar;
			}; #end Foreach ElseScriptBlock
		}; #end if ElseScriptBlock.split("`n")[0]
		
	}; #end if ElseScriptBlock
	
	if (!($BottomHeaderRemoved)) {
		[string]$NewFunctionOperation += $TabVar + $ClosingBracketOneLiner
	}; #end if BottomHeader
	[string]$PipelineVar = ''

	if ($Pipeline) {
		#If Pipeline, prepend with PipelineVar
		$PipelineVar += '| '
		#[string]$NewFunctionOperation = $PipelineVar + $NewFunctionOperation
	}; #end if Pipeline
		#} elseif ($PipeEqual) {
	if ($PipePlus) {
		#If PipePlus, prepend with Plus
		$PipelineVar += "+ "
	}; #end if PipePlus
	if ($PipeMinus) {
		#If PipeMinus, prepend with Minus
		$PipelineVar += "- "
	}; #end if PipeMinus
	if ($PipeEqual) {
		#If PipeEqual, prepend with Equals
		$PipelineVar += "= "
	}; #end if PipeEqual
	[string]$NewFunctionOperation = $PipelineVar + $NewFunctionOperation
	#Pipe, Equal, PlusEqual, MinusEqual
	
	if ($PreVariable) {
		#If PreVariable, prepend with it...need to add in pipe somehow
		[string]$NewFunctionOperation = $VariableOperator + $PreVariable + $Spacevar+ $NewFunctionOperation
	}; #end if PreVariable
	
	if ($Clipboard) {
		$NewFunctionOperation | clip
	} else {
		return $NewFunctionOperation
	}; #end if Clipboard
	
}; #end New-FunctionStatement

New-Alias -name ff -value Find-Function -Force
Function Find-Function {
	Param(
		[string]$FunctionName = "Find-Function",
		[array]$FileName
	); #end Param
	
	#If FileName wasn't entered as a param,
	if (!($FileName)) {
		#Grab all loaded module names and return all which have this function.
		[array]$FileName = Foreach ($ModuleName in (Get-Module).path) {
			if ((gc $ModuleName) -like "*Function $FunctionName*" -OR (gc $ModuleName) -like "*Filter $FunctionName*") {
					$ModuleName
				}; #end if gc Module 
		}; #end Foreach Module
	}; #end if FileName
	
	Foreach ($File in $FileName) {
		$Func = New-Object System.Object | select "FileName","StartLine","EndLine","ParamStartLine","ParamEndLine","Parameters","Process";
		$Func.FileName = $File
		$Filecontents = (gc $Func.FileName);
		
		#Start line is where either the Function or Filter is declared.
		$Func.StartLine = ((($Filecontents | Select-String "Function $FunctionName ").LineNumber) + (($Filecontents | Select-String "Filter $FunctionName ").LineNumber) );
		#End line uses my #end function name tag and the optional semicolon.
		$Func.EndLine = ((($Filecontents | Select-String "}; #end $FunctionName$").LineNumber) - 0);
		
		#Pull the function out of the file contents, this is only used to find the parameter section lines.
		$Funcn = $Filecontents[($Func.StartLine)..($Func.EndLine)];
		#Parameter start line is found by regexing the opening parenthesis.
		$Func.ParamStartLine = (($Func.StartLine + (($Funcn | Select-String 'Param[(]').LineNumber) ))
		#Parameter end line is found by regexing the closing parenthesis, optional semicolon, and my tag.
		$Func.ParamEndLine = ($Func.StartLine + (($Funcn | Select-String '[)][;] [#]end Param').LineNumber) - 2)
		
		$Func.Parameters = $Filecontents[($Func.ParamStartLine)..($Func.ParamEndLine)];
		$Func.Process = $Filecontents[($Func.ParamEndLine + 2)..($Func.EndLine)];
		$Func
	}; #end Foreach File
}; #end Find-Function


Function Get-DevFlags {
	Param(
		[array]$File = (Get-Module).path
	); #end Param
	#Make this take a file/directory as input. (FLAG)
	Foreach ($Fil in $File) {
		Write-Host $Fil "has changes:"; 
		gc $Fil | Select-String "[(]FLAG[)]" -All | Select LineNumber, Line | Format-Table -Auto
	}; #end Foreach
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
	); #end Param
	if ($Location){
		explorer.exe $Location
	} else {
		explorer.exe (Get-Location)
	}; #end if Location
}; #end Open-Explorer


New-Alias -name nsp -value New-Powershell -Force
New-Alias -Name npo -Value New-Powershell -Force
Function New-Powershell {
	Param(
		[switch]$Elevated,
		[switch]$NoProfile
	); #end Param
	if ($Elevated) {
		start-process powershell -verb runas
	} elseif ($NoProfile) {
		Start-Process powershell.exe "-noprofile"
	} else {
		Start-Process powershell 
	}; #end if Elevated
	#Need to change to Start-Process powershell.exe @args FLAG
}; #end New-Powershell


New-Alias -name rsp -value Restart-Powershell -Force
New-Alias -Name rpo -Value Restart-Powershell -Force
Function Restart-Powershell {
	Param(
		[switch]$Elevated,
		[switch]$NoProfile
	); #end Param
	Reset-CipherKey
	Stop-AllJobs
	if ($Elevated) {
		New-Powershell -Elevated
	} elseif ($NoProfile) {
		New-Powershell -NoProfile
	} else {
		New-Powershell 
	}; #end if Elevated
	#Need to change to New-Powershell@args FLAG
	exit
}; #end Restart-Powershell



Function Get-PSVersion {
	if ($PSVersionTable.psversion.major -ge 4) {
		Write-Host "PowerShell Version: $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Build).$($PSVersionTable.PSVersion.Revision)" -f Yellow 
	} else {
		Write-Host "PowerShell Version: $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" -f Yellow 
	}; #end if PSVersionTable
}; #end Get-PSVersion


New-Alias -name spsz -value Set-PSWindowSize -Force
Function Set-PSWindowSize {
	[CmdletBinding()]
	Param(
		[int]$Rows = 0,
		[int]$Columns = 0
	); #end Param
	#from http://www.powershellserver.com/support/articles/powershell-server-changing-terminal-width/
	$pshost = Get-Host			  # Get the PowerShell Host.
	$pswindow = $pshost.UI.RawUI	# Get the PowerShell Host's UI.
	
	$maxWindowSize = $pswindow.MaxPhysicalWindowSize # Get the max window size. 
	$newBufferSize = $pswindow.BufferSize # Get the UI's current Buffer Size.
	$newWindowSize = $pswindow.windowsize # Get the UI's current Window Size.
	
	if ($Rows -gt $maxWindowSize.height) {
		Write-Verbose "Max height $($maxWindowSize.height) rows tall."
		$Rows = $maxWindowSize.height
	}; #end if Rows -gt
	
	if ($Columns -gt $maxWindowSize.width) {
		Write-Verbose "Max width $($maxWindowSize.width) columns wide."
		$Columns = $maxWindowSize.width
	}; #end if Columns -gt
	
	$oldBufferSize = $newBufferSize			 # Save the oldsize.
	$oldWindowSize = $newWindowSize
	
	if ($Rows -gt 0 ) {
		$newWindowSize.height = $Rows
	} if ($oldWindowSize.height -eq $Rows) {
		Write-Verbose "Window is already $($newWindowSize.height) rows tall."
	} else {
		$pswindow.windowsize = $newWindowSize # Set the new Window Size as active.
	}; #end if Rows
	
	
	if ($Columns -gt 0) {
	$newWindowSize.width = $Columns # Set the new buffer's width to 150 columns.
	$newBufferSize.width = $Columns

	if ($newWindowSize.width -gt $oldWindowSize.width) {
		$pswindow.buffersize = $newBufferSize # Set the new Buffer Size as active.
		$pswindow.windowsize = $newWindowSize # Set the new Window Size as active.
	} elseif ($oldWindowSize.width -gt $newWindowSize.width) { #Order is important, buffer must always be wider.
		$pswindow.windowsize = $newWindowSize # Set the new Window Size as active.
		$pswindow.buffersize = $newBufferSize # Set the new Buffer Size as active.
	} elseif ($oldWindowSize.width -eq $newWindowSize.width) {
		Write-Verbose "Window is already $($newWindowSize.width) columns wide."
		}; #end if newWindowSize.width -gt
	}; #end if WindowWidth
}; #end Set-PSWindowSize


New-Alias -name spsy -value Set-PSWindowStyle -Force
Function Set-PSWindowStyle {
	Param(
		[Parameter()]
		[ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE',
					 'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED',
					 'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
		$Style = 'MINIMIZE',
		[Parameter()]
		$MainWindowHandle = (Get-Process -id $pid).MainWindowHandle
	); #end Param

	$WindowStates = @{
		'FORCEMINIMIZE'	= 11
		'HIDE'			= 0
		'MAXIMIZE'		= 3
		'MINIMIZE'		= 6
		'RESTORE'		 = 9
		'SHOW'			= 5
		'SHOWDEFAULT'	 = 10
		'SHOWMAXIMIZED'	= 3
		'SHOWMINIMIZED'	= 2
		'SHOWMINNOACTIVE' = 7
		'SHOWNA'		  = 8
		'SHOWNOACTIVATE'  = 4
		'SHOWNORMAL'	  = 1
	}; #end WindowStates

$memberDefintion = @"
	[DllImport("user32.dll")]
	public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@

	$Win32ShowWindowAsync = Add-Type -memberDefinition $memberDefintion -name "Win32ShowWindowAsync" -namespace Win32Functions -passThru

	$Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$Style]) | Out-Null
	Write-Verbose ("Set Window Style '{1} on '{0}'" -f $MainWindowHandle, $Style)

}; #end Set-PSWindowStyle


#System WMI stuffs
Function Invoke-WMIInstaller {
	Param(
		[String]$Uninstall
	); #end Param
	$IsElevated = (whoami /all | Select-String S-1-16-12288) -ne $null

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

Function Get-WMIMemory {
	
		Param(
			$ProcessName = 'powershell.exe'
		); #end Param
	if (!($ProcessName.substring(($($ProcessName.Length) - 4), 4) -like '.exe')) {
		$ProcessName = $ProcessName + ".exe"
	}; #end if ProcessName.substring(($($ProcessName.Length) - 4), 4)
	
	Get-WMIObject Win32_Process -Filter "Name='$ProcessName'"  | Sort PrivatePageCount | Select Name,ProcessID,CommandLine,@{n="Private Memory(gb)";e={$_.PrivatePageCount/1gb}}
	
}; #end Get-WMIMemory

Function Get-WMIDisk {
	Param(
		[String]$Drive,
		[Switch]$Raw
	); #end Param
	if ($drive.Length -eq 1) {
		$Filter = ("DeviceID='" + $Drive + ":'")
		$GetWmiDisk = Get-WmiObject Win32_LogicalDisk -Filter $Filter
	} else {
		[object]$GetWmiDisk = Get-WmiObject Win32_LogicalDisk
	}; #end if Drive
	if ($Raw) {
		$GetWmiDisk
	} else {
		#$GetWmiDisk
		Foreach ($Disk in $GetWmiDisk) {
			#$Disk = [object]$Disk
			#$Disk
			#$Disk.DeviceID
			#$Disk.size
			#"Drive size here."
			if ($Disk.size -gt 0) {
				[math]::Round((($Disk.FreeSpace / $Disk.Size) * 100)).ToString() + "% free in drive " + $Disk.DeviceID
			}; #end if drivesize gt 0
		}; #end Foreach drive
	}; #end if Raw
}; #end Get-WMIDisk 


Function Get-RunningProcess {
#Forgot where I found this, not sure how it works. 
	$CPUPercent = @{
	  Name = 'CPUPercent'
	  Expression = {
		$TotalSec = (New-TimeSpan -Start $_.StartTime).TotalSeconds
			[Math]::Round( ($_.CPU * 100 / $TotalSec), 2)
	  }; #end TotalSec
	}; #end CPUPercent
	
	Get-Process | Select-Object privatememorysize64,$CPUPercent,id,name,Description | Sort-Object -Property CPUPercent -Descending 
}; #end Get-RunningProcess

Function Export-PuTTY {
	Write-Host "Exports your PuTTY profiles to $home\Desktop\putty.reg"
	reg export HKCU\Software\SimonTatham $home\Desktop\putty.reg
}; #end Export-PuTTY


#Github
Function Get-GithubStatus {
	$StatusJSON = Invoke-RestMethod -Uri "https://status.github.com/api/status.JSON?callback=apiStatus"
	#Dig out the JSON from the response, convert.
	$Status = ConvertFrom-JSON $StatusJSON.substring(10,($StatusJSON.Length - 11))
	#Convert the date into a Powershell object
	$Status.last_updated = get-date ($Status.last_updated)
	#Return the status
	$Status
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


Function Stop-Explorer {
	get-process explorer | Foreach { stop-process $_.id }
}; #end Stop-Explorer


Function Receive-AllJobs {
	Foreach ($job in (get-job).id ) { 
		while ((get-job $job ).hasmoredata) { 
			receive-job $job
		}; #end while
	}; #end Foreach
}; #end Receive-AllJobs


Function Stop-AllJobs {
	Foreach ($job in (get-job).id ) {
		stop-job $job
	}; #end Foreach
}; #end Stop-AllJobs


Function Get-Clipboard {
#https://www.bgreco.net/powershell/get-clipboard/
	Param(
		[switch]$JSON,
		[switch]$raw
	); #end Param 
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

Function Get-UsGovWeather {
#https://blogs.technet.microsoft.com/heyscriptingguy/2010/11/07/use-powershell-to-retrieve-a-weather-forecast/
	Param([string]$zip = 98104,
		[int]$numberDays = 4,
		[switch]$Fahrenheit
	); #end Param

	$URI = "http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl"
	$Proxy = New-WebServiceProxy -uri $URI -namespace WebServiceProxy
	[xml]$latlon=$proxy.LatLonListZipCode($zip)
	Foreach($l in $latlon) {
		$a = $l.dwml.latlonlist -split ",";
		$lat = $a[0]
		$lon = $a[1]
		$sDate = get-date -UFormat %Y-%m-%d
		$format = "Item24hourly"

		if ($Fahrenheit) { $unit = "e" } else { $unit = "m" } 

		[xml]$weather = $Proxy.NDFDgenByDay($lat,$lon,$sDate,$numberDays,$unit,$format)

		For($i = 0 ; $i -le $numberDays -1 ; $i ++) {
			New-Object psObject -Property @{
				"Date" = ((Get-Date).addDays($i)).ToString("MM/dd/yyyy") ;
				"maxTemp" = $weather.dwml.data.Parameters.temperature[0].value[$i] ;
				"minTemp" = $weather.dwml.data.Parameters.temperature[1].value[$i] ;
				"Summary" = $weather.dwml.data.Parameters.weather."weather-conditions"[$i]."Weather-summary"
			}; #end New-Object
		}; #end For i
	}; #end  Foreach l
}; #end Get-UsGovWeather


Function Test-PingJob {
	start-job { 
		ping -t 8.8.8.8 
	} ; 
	$pingjob = (get-job).id[-1] ; 
	while ((get-job $pingjob ).hasmoredata) {
		receive-job $pingjob 
	}; #end while 
}; #end Test-PingJob


Function Test-TCPPortConnection {
	[CmdletBinding()]
	Param(
		[IPAddress]$IPAddress = "127.0.0.1",
		[int]$Port = 443
	); #end Param
	try {
		(new-object Net.Sockets.TcpClient).Connect("$($IPAddress.IPAddressToString)", $Port)
	} catch {
		return $false
		Write-Verbose -Message "Connection failed.";
		break
	}; #end try 
	return $true
	Write-Verbose -Message "Connection succeeded.";
}; #end Test-TCPPortConnection

#endregion

#region init
#Set TLS 1.2:
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

#Set UTF8 Encoding 
#$OutputEncoding = New-Object -typename System.Text.UTF8Encoding #This messes up copypasta & other stuff.
#[Console]::OutputEncoding = New-Object -typename System.Text.UTF8Encoding #This setting messes up VI.
#Just use WriteAllLines instead.
	
	if (!($DontShowPoweGILVersionOnStartup)){
		Get-ModuleVersion
	}; #end if DontShowPSVersionOnStartup
	#$DontShowPoweGILVersionOnStartup = $false # to turn off PowerGIL Build display.

	#Need this for Image functions.
	[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | out-null

	#For the audio player 
	Add-Type -AssemblyName presentationCore
	$wmplayer = New-Object System.Windows.Media.MediaPlayer

	#Rename isn't Rename-Item, it's dumb.
	New-Alias -name rename -value Rename-Item -Force

	#Hate VIM
	if ($VIMPATH) {
		Set-Alias vi	$VIMPATH
		Set-Alias vim  $VIMPATH
	} else {
		Write-Host -f red "VIM not found, disabling alias." 
	}; #end if VIMPATH

	#Love Notepad++
	if ($NppPATH) {
		Set-Alias note  $NppPATH
	} else {
		Write-Host -f red "Notepad++ not found, disabling alias."
	}; #end if NppPATH

	#Fight with LYNX
	if ($LynxW32Path) {
		Set-Alias LYNX  $LynxW32Path
	} else {
		Write-Host -f red "LYNX not found, disabling alias."
	}; #end if LynxW32Path

	#Update with GIT
	if ($GITPath) {
		Set-Alias GIT  $GITPath
	} else {
		Write-Host -f red "GIT not found, disabling alias."
	}; #end if GITPath

#Move to Profile?
[ipaddress]$localhost = "127.0.0.1"
$ProfileFolder = (split-path $PROFILE)

$RemoteHost = $localhost 
#$RemoteHost = (Resolve-DnsName gilgamech.com).IPAddress
$RemotePort = 65001

#$DontShowPSVersionOnStartup = $false # to turn off Powershell Version display.
#if (!($DontShowPSVersionOnStartup)){
#	Get-PSVersion
#}

#endregion

#region PowerShiri
Function Start-PowerShiri {
	Import-Module "C:\Dropbox\repos\PowerShiri\PowerShiri.ps1" -Force
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
}; #end Say-This
#endregion

#region Time
Function Convert-Time {
	#If there's more than 1 option, have it loop. (FLAG)
	Param(
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
	); #end Param
	#1. Funnel the TLAs into the fromtimezone
	#2. Set the partnames to be a Foreach loop. 


	$SystemTZones = ([System.TimeZoneInfo]::GetSystemTimeZones()).id
	if ($ListTZones) {
		#ListTZones will just dump the system time zones.
		$SystemTZones
		Write-Host -f y "This system knows about the above time zones. Please use these with '-FromTimeZoneFullName' and '-ToTimeZoneFullName' Parameters."
		break
	} else {
		#Otherwise run the full script.
		
		#Three Letter Acronym Time Zone (TLATZ) list
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
		}; #end TLATZ
		
		if ($FromTimeZoneFullName) {
			$fromtzone = $SystemTZones |  where {$_ -like "*$FromTimeZoneFullName*"}
		} elseif ($FromTZ) {
			$fromtzone = $TLATZ[$FromTZ]
		} else {
			Write-Host -f red "No 'From' time zone entered. Use -FromTZ or -FromTimeZoneFullName"
			break
		}; #end if fromTimeZone
		
		$oFromTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($fromtzone)
		Write-Verbose "Converting from $oFromTimeZone"
		
		if ($ToTimeZoneFullName) {
			$totzone = $SystemTZones |  where {$_ -like "*$ToTimeZoneFullName*"}
		} elseif ($ToTZ) {
			$totzone = $TLATZ[$ToTZ]
		} else {
			Write-Host -f red "No 'To' time zone entered. Use -ToTZ or -ToTimeZoneFullName"
			break
		}; #end if toTimeZone
		
		
		$oToTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($totzone)
		Write-Verbose "Converting to $oToTimeZone"
		
		$utc = [System.TimeZoneInfo]::ConvertTimeToUtc($time, $oFromTimeZone)
		$newTime = [System.TimeZoneInfo]::ConvertTime($utc, $oToTimeZone)
		
		$newtime
		
		if ($UTCtoo){
			$utc
		}; #end if UTC
	}; #end if ListTZones

}; #end Convert-Time

#List of TLAs
#$r = Foreach ($name in (([System.TimeZoneInfo]::GetSystemTimeZones()).standardname)) {-Join (($name).split(" ") | Foreach {$_[0]})} ; 
#$r | select -Unique | where {$_.Length -eq 3} | sort

#endregion

#region Music!

Function Start-Music {
#http://www.adminarsenal.com/admin-arsenal-blog/powershell-music-remotely/
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		[uri]$FileName
	); #end Param
	#Add-Type -AssemblyName presentationCore
	#$FileName = [uri] "C:\temp\Futurama - Christmas Elves song.mp3"
	#$wmplayer = New-Object System.Windows.Media.MediaPlayer
	$wmplayer.Open($FileName)
	Start-Sleep 2 # This allows the $wmplayer time to load the audio file
	#$duration = $wmplayer.NaturalDuration.TimeSpan.TotalSeconds
	$wmplayer.Play()
}; #end Start-Music-Music

Function Stop-Music {
	$wmplayer.Stop()
	$wmplayer.Close()
}; #end Stop-Music

#endregion

#region Conversions

#1..50 | Filter-FizzBuzz
Filter Filter-FizzBuzz {
	if (!($_ % 15)) {
		return "FizzBuzz"
	} elseif (!($_ % 5)) {
			return "Buzz"
	} elseif (!($_ % 3)) {
			return "Fizz"
	} else {
		return $_
	}; #end if 15
}; #end Filter-FizzBuzz

Filter Flip-TextToBinary {
	[System.Text.Encoding]::UTF8.Getbytes($_) | %{ 
		[System.Convert]::ToString($_,2).PadLeft(8,'0')
	}; #end Foreach
#[System.Text.Encoding]::UTF8.Getbytes([System.Convert]::ToString($_,2).PadLeft(8,'0'))
}; #end Filter

Filter Flip-BinaryToText {
	Param(
		[switch]$ASCII
	); #end Param
	if ($ASCII) {
		#[System.Text.Encoding]::ASCII.Getbytes($_)
		%{ 
			[System.Text.Encoding]::ASCII.GetString([System.Convert]::ToInt32($_,2)) 
		}; #end Foreach
	} else {
		%{ 
			[System.Text.Encoding]::UTF8.GetString([System.Convert]::ToInt32($_,2)) 
		}; #end Foreach
	}; #end if
}; #end Filter

Filter Flip-TextToBytes {
	Param(
		[switch]$ASCII
	); #end Param
	if ($ASCII) {
		[System.Text.Encoding]::ASCII.Getbytes($_)
	} else {
		[System.Text.Encoding]::Unicode.Getbytes($_)
	}; #end if
}; #end Filter

<# Filter Flip-TextToHex {
	Param(
		[switch]$ASCII
	)
	if ($ASCII) {
		$ab = [System.Text.Encoding]::ASCII.Getbytes($_);
	} else {
		$ab = [System.Text.Encoding]::UTF8.Getbytes($_);
	}; #end if
	$ac = [System.BitConverter]::ToString($ab);
	$ac.split("-")
}; #end Filter
 #>

Filter Flip-BytesToText {
	Param(
		[int]$Unicode2 = 0,
		[switch]$Unicode
	); #end Param
	$RetStr = ""
	if ($Unicode) {
		#if ($Unicode2) {
			$RetStr = [System.Text.Encoding]::Unicode.GetString(($_,$Unicode2))
		#} else {
			#[System.Text.Encoding]::Unicode.GetString(($_))
		#}; #end if Unicode2
		#write-host "Unicode currently broken."
		#break
	} else {
		$RetStr = [System.Text.Encoding]::ASCII.GetString($_)
	}; #end if Unicode
	if ($RetStr -ne "") {
		return $RetStr
	}; #end if RetStr	
}; #end Flip-BytesToText

Filter Flip-TextToBase64 {
	#$EncodedText =[Convert]::ToBase64String([System.Text.Encoding]::Unicode.Getbytes($InputText))
	$bytes = [System.Text.Encoding]::Unicode.Getbytes($_)
	$EncodedText =[Convert]::ToBase64String($bytes)
	$EncodedText
}; #end Filter

Function Flip-Base64ToText($InputText) {
	$DecodedText = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($InputText))
	#$DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($InputText))
	$DecodedText
}; #end Filter

Filter Flip-HexToText {
	$_.Split(" ") | Foreach {
		[char][byte]([CONVERT]::ToInt16($_,16))
	}; #end Foreach
}; #end Flip-HexToText

Filter Flip-TextToHex {
	$_.TocharArray() | Foreach {
		([CONVERT]::ToString([byte][char]$_,16))
	}; #end Foreach
}; #end Flip-HexToText

Filter Flip-HexToBinary {
	$_.Split(" ") | Foreach {
		([CONVERT]::ToInt16($_,16))
	}; #end Foreach
}; #end Flip-HexToText

New-Alias -name Scramble-String -value Shuffle-String -force
Function Shuffle-String {
	#http://poshcode.org/4531
	Param(
	[string]$String, 
	[switch]$IgnoreSpaces, 
	[switch]$IgnoreCRLF, 
	[switch]$IgnoreWhitespace
	); #end Param
	#Simple enough, input a string or here-string, return it randomly shuffled, whitespace, carriage returns and all
	#IgnoreSpaces removes spaces from output
	#IgnoreCRLF removes Carriage Returns and LineFeeds from the output
	#IgnoreWhitespace removes spaces and tabs from the output
	#Tab = [char]9
	#LF = [char]10
	#CR = [char]13
	
	If ($string.Length -eq 0) {
		Return
	}; #end if string.Length
	
	If ($IgnoreWhiteSpace) {
		$String = $String.Replace([string][char]9,"")
		$IgnoreSpaces = $True
	}; #end if IgnoreWhiteSpace
 
	If ($IgnoreSpaces) {
		$String = $String.Replace(" ","")
	}; #end if IgnoreSpaces
 
	If ($IgnoreCRLF) {
		$String = $String.Replace([string][char]10,"").Replace([string][char]13,"")
	}; #end if IgnoreCRLF

	$Random = New-Object Random
	
	Return [string]::join("",($String.ToCharArray()|sort {$Random.Next()}))
}; #end Shuffle-String


<#
	$SymbolKey = '!','"','#','$','%','&',"'",'(',')','*','+',',','-',' - ','.','/',':',';','<','=','>','?','@','[','\',']','^','_','`','{','|','}','~','  ';
	$WordKey = ' not ',' double quote ',' comment ',' variable ',' foreach ',' and ',' quote ',' OpenParens ','CloseParens ',' all ',' plus ',' comma ',' dash ',' minus ',' dot ',' slash ',' colon ',' end ',' GreaterThan ','Equals ',' LessThan ',' where ',' At ',' OpenSquareBracket ',' EscapeSlash ',' CloseSquareBracket ',' to thepower of ',' this ',' escape ',' script ',' pipe ',' endscript ',' about ',' ';
	
Filter Flip-SymbolToWord2 {
#http://securekomodo.com/powershell-simple-substitution-cipher/
	$SymbolText = $_
	$Hash = @{}
	$WordText=""

	# Adding letters to array
	for($i=0; $i -lt ($WordKey.Length); $i+=1) {
		$Hash.add($SymbolKey[$i],$WordKey[$i])
	}; #end for i
	
	#Swap letters
	for($i=0; $i -lt ($SymbolText.Length); $i+=1) {
		$char = $SymbolText[$i]
		$WordText+=$Hash[$char]
	}; #end for i

	Return $WordText
}; #end Flip-SymbolToWord2


Filter Flip-WordToSymbol2 {
#http://securekomodo.com/powershell-simple-substitution-cipher/
	$WordText = $_
	$Hash = @{}
	$SymbolText=""

	# Adding letters to array
	for($i=0; $i -lt ($WordKey.Length); $i+=1) {
		$Hash.add($WordKey[$i],$SymbolKey[$i])
	}; #end for i

	#Swap letters
	for($i=0; $i -lt ($WordText.Length); $i+=1) {
		$char = $WordText[$i]
		$SymbolText+=$Hash[$char]
	}; #end for i
	
	#Write-host -ForegroundColor Green "`n$SymbolText"
	Return $SymbolText
}; #end Flip-WordToSymbol2

#>

#"if  OpenParens  variable Text -eq  variable true  CloseParens  script  write dash host  DoubleQuote hello world DoubleQuote  endscript " | Flip-WordToSymbol

Filter Flip-SymbolToWord {
	
	If ($_) {
		$_ = $_.replace('-eq ',' IsEqual ')
		$_ = $_.replace('-ne ',' IsNotEqual ')
		$_ = $_.replace('-ge ',' IsGreaterThanOrEqual ')
		$_ = $_.replace('-gt ',' IsGreaterThan ')
		$_ = $_.replace('-lt ',' IsLessThan ')
		$_ = $_.replace('-le ',' IsLessThanOrEqual ')
		$_ = $_.replace('-like ',' IsLike ')
		$_ = $_.replace('-notlike ',' IsNotLike ')
		$_ = $_.replace('-match ',' Matches ')
		$_ = $_.replace('-notmatch ',' DoesNotMatch ')
		$_ = $_.replace('-contains ',' Contains ')
		$_ = $_.replace('-notcontains ',' DoesNotContain ')
		$_ = $_.replace('-or ',' Or ')
		$_ = $_.replace('-and ',' And ')
		$_ = $_.replace('-not ',' IsNot ')
		$_ = $_.replace('-in ',' IsIn ')
		$_ = $_.replace('-notin ',' IsNotIn ')
		$_ = $_.replace('-is ',' Is ')
		$_ = $_.replace('-isnot ',' IsNot ')
		$_ = $_.replace('-as ',' As ')
		$_ = $_.replace('-band ',' BinaryAnd ')
		$_ = $_.replace('-bor ',' BinaryOr ')
		$_ = $_.replace('% ',' Modulus ')
		$_ = $_.replace('!',' Not ')
		$_ = $_.replace('"',' DoubleQuote ')
		$_ = $_.replace('#',' Comment ')
		$_ = $_.replace('$',' Variable ')
		$_ = $_.replace('%',' Foreach ')
		$_ = $_.replace('&',' And ')
		$_ = $_.replace("'",' Quote ')
		$_ = $_.replace('(',' OpenParens ')
		$_ = $_.replace(')',' CloseParens ')
		$_ = $_.replace('*',' All ')
		$_ = $_.replace('+',' Plus ')
		$_ = $_.replace(',',' Comma ')
		$_ = $_.replace('-',' Dash ')
		$_ = $_.replace(' - ',' Minus ')
		$_ = $_.replace('.',' Dot ')
		$_ = $_.replace(':',' Colon ')
		$_ = $_.replace(';',' End ')
		$_ = $_.replace('<',' GreaterThan ')
		$_ = $_.replace('=',' Equals ')
		$_ = $_.replace('-eq',' IsEqualTo ')
		$_ = $_.replace('-eq',' IsEqualTo ')
		$_ = $_.replace('>',' LessThan ')
		$_ = $_.replace('?',' Where ')
		$_ = $_.replace('@',' At ')
		$_ = $_.replace('[',' OpenSquareBracket ')
		$_ = $_.replace(']',' CloseSquareBracket ')
		$_ = $_.replace('^',' OfPower ')
		$_ = $_.replace('_',' This ')
		$_ = $_.replace('{',' Script ')
		$_ = $_.replace('|',' Pipe ')
		$_ = $_.replace('}',' Endscript ')
		$_ = $_.replace('~',' About ')
		$_ = $_.replace('`t',' Tab ')
		$_ = $_.replace('`',' Escape ')
		$_ = $_.replace('\',' Slash ')
		$_ = $_.replace('/',' Escape ')
		#$_ = $_.replace('  ',' ')
	}; #end If _
	
	Return $_
}; #end Flip-SymbolToWord


Filter Flip-WordToSymbol {
	
	If ($_) {
		$_ = $_.replace(' IsEqual ','-eq ')
		$_ = $_.replace(' IsNotEqual ','-ne ')
		$_ = $_.replace(' IsGreaterThanOrEqual ','-ge ')
		$_ = $_.replace(' IsGreaterThan ','-gt ')
		$_ = $_.replace(' IsLessThan ','-lt ')
		$_ = $_.replace(' IsLessThanOrEqual ','-le ')
		$_ = $_.replace(' IsLike ','-like ')
		$_ = $_.replace(' IsNotLike ','-notlike ')
		$_ = $_.replace(' Matches ','-match ')
		$_ = $_.replace(' DoesNotMatch ','-notmatch ')
		$_ = $_.replace(' Contains ','-contains ')
		$_ = $_.replace(' DoesNotContain ','-notcontains ')
		$_ = $_.replace(' Or ','-or ')
		$_ = $_.replace(' And ','-and ')
		$_ = $_.replace(' IsNot ','-not ')
		$_ = $_.replace(' IsIn ','-in ')
		$_ = $_.replace(' IsNotIn ','-notin ')
		$_ = $_.replace(' Is ','-is ')
		$_ = $_.replace(' IsNot ','-isnot ')
		$_ = $_.replace(' As ','-as ')
		$_ = $_.replace(' BinaryAnd ','-band ')
		$_ = $_.replace(' BinaryOr ','-bor ')
		$_ = $_.replace(' Modulus ','% ')
		$_ = $_.replace(' not ','!')
		$_ = $_.replace(' DoubleQuote ','"')
		$_ = $_.replace(' Comment ','#')
		$_ = $_.replace(' Variable ','$')
		$_ = $_.replace(' Foreach ','%')
		$_ = $_.replace(' And ','&')
		$_ = $_.replace(' Quote ',"'")
		$_ = $_.replace(' OpenParens ','(')
		$_ = $_.replace(' CloseParens ',')')
		$_ = $_.replace(' All ','*')
		$_ = $_.replace(' Plus ','+')
		$_ = $_.replace(' Comma ',',')
		$_ = $_.replace(' Dash ','-')
		$_ = $_.replace(' Minus ',' - ')
		$_ = $_.replace(' Dot ','.')
		$_ = $_.replace(' Colon ',':')
		$_ = $_.replace(' End ',';')
		$_ = $_.replace(' GreaterThan ','<')
		$_ = $_.replace(' Equals ','=')
		$_ = $_.replace(' LessThan ','>')
		$_ = $_.replace(' Where ','?')
		$_ = $_.replace(' At ','@')
		$_ = $_.replace(' OpenSquareBracket ','[')
		$_ = $_.replace(' CloseSquareBracket ',']')
		$_ = $_.replace(' OfPower ','^')
		$_ = $_.replace(' This ','_')
		$_ = $_.replace(' Script ','{')
		$_ = $_.replace(' Pipe ','|')
		$_ = $_.replace(' Endscript ','}')
		$_ = $_.replace(' About ','~')
		$_ = $_.replace(' Tab ','`t')
		$_ = $_.replace(' Escape ','`')
		$_ = $_.replace(' Slash ','\')
		$_ = $_.replace(' EscapeSlash ','/')
		#$_ = $_ -Replace "\s+"," "
	}; #end If _
	
	Return $_
}; #end Flip-WordToSymbol

#endregion

#region Images

#Take-Screenshot -bounds (Get-Window).rectangle -ascii

Function Take-Screenshot {
#https://stackoverflow.com/questions/2969321/how-can-i-do-a-screen-capture-in-windows-powershell
	[CmdletBinding()]
	Param(
		[int]$xMin = 0,
		#[ValidateRange(($xMin),999999)]
		[int]$xMax = 1000,
		[int]$yMin = 0,
		#[ValidateRange(($yMin),999999)]
		[int]$yMax = 900,
		[Drawing.Rectangle]$bounds = (Get-Window).rectangle,
		[switch]$ascii,
		[string]$path = (".\" + (get-date -f yy-MM-dd-HH-mm-ss) + ".png")
	); #end Param
	
	if ($xMin -gt $xMax) {
		0;
		Write-Verbose "First value xMin = $xMin must be less than Second value xMax = $xMax";
		return
	}; #end if xMin
	
	if ($yMin -gt $yMax) {
		0;
		Write-Verbose "Third value yMin = $yMin must be less than Fourth value yMax = $yMax";
		return
	}; #end if yMin
	
	$bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height
	$graphics = [Drawing.Graphics]::FromImage($bmp)
	$graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)
	
	if (test-path $path) {
		rm $path 
	}; #end if path
	
	$bmp.Save($path)
	write-host -f green "File $path written."
	$graphics.Dispose()
	$bmp.Dispose()
	if ($ascii) {
		ciai $path
	}; #end if ascii
}; #end Take-Screenshot


Function Invoke-PowerGilImage {
# load the appropriate assemblies 
	[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
	[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

	# create chart object 
	$chart = New-object System.Windows.Forms.DataVisualization.charting.chart 
	$chart.Width = 500 
	$chart.Height = 400 
	$chart.Left = 40 
	$chart.Top = 30

	# create a chartarea to draw on and add to chart 
	$chartArea = New-Object System.Windows.Forms.DataVisualization.charting.chartArea 
	$chart.chartAreas.Add($chartArea)

	# add data to chart 
	$Cities = @{London=7556900; Berlin=3429900; Madrid=3213271; Rome=2726539; 
				Paris=2188500} 
	[void]$chart.Series.Add("Data") 
	$chart.Series["Data"].Points.DataBindXY($Cities.Keys, $Cities.Values)

	# display the chart on a form 
	$chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
					[System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left 
	$Form = New-Object Windows.Forms.Form 
	$Form.Text = "PowerShell chart" 
	$Form.Width = 600 
	$Form.Height = 600 
	$Form.controls.add($chart) 
	$Form.Add_Shown({$Form.Activate()}) 
	$Form.ShowDialog()
}; #end Invoke-PowerGilImage


Function Display-Image {
# Loosely based on http://www.vistax64.com/powershell/202216-display-image-powershell.html
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		[string]$FileName
	); #end Param
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

New-Alias -name ciai -value ConvertImage-ToASCIIArt -Force
Function ConvertImage-ToASCIIArt {
	#----------------------------------------------------------------------------- 
	# Copyright 2006 Adrian Milliner (ps1 at soapyfrog dot com) 
	# http://ps1.soapyfrog.com 
	# 
	# This work is licenced under the Creative Commons  
	# Attribution-NonCommercial-ShareAlike 2.5 License.  
	# To view a copy of this licence, visit  
	# http://creativecommons.org/licenses/by-nc-sa/2.5/  
	# or send a letter to  
	# Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA. 
	#----------------------------------------------------------------------------- 
	
	#----------------------------------------------------------------------------- 
	# This script loads the specified image and outputs an ascii version to the 
	# pipe, line by line. 
	# Heavily modified by Gil.
	Param( 
		[Parameter(Mandatory=$True,Position=1)]
		[string]$path, #= $(throw "Supply an image path"), 
		[int]$maxwidth, # default is width of console 
		[ValidateSet("ascii","shade","bw")]
		[string]$palette = "ascii", # choose a palette, "ascii" or "shade" 
		[float]$ratio = 1.5 # 1.5 means char height is 1.5 x width 
	); #end Param
	
	
	#----------------------------------------------------------------------------- 
	# here we go 
	
	$palettes = @{ 
		"ascii" = " .,:;=|iI+hHOE#`$" 
		"shade" = " " + [char]0x2591 + [char]0x2592 + [char]0x2593 + [char]0x2588 
		"bw"	= " " + [char]0x2588 
	} 

	$c = $palettes[$palette] 

<#
	if (-not $c) { 
		write-warning "palette should be one of:  $($palettes.keys.GetEnumerator())" 
		write-warning "defaulting to ascii" 
		$c = $palettes.ascii 
	} 
#>

	[char[]]$charpalette = $c.TocharArray() 
	
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
			if (-not $ch) { 
				#overflow 
				$ch = $charpalette[-1] 
			}; #end if not ch 
			$line += $ch 
		}; #end for x
		$line 
	}; #end for y
	
}; #end ConvertImage-ToASCIIArt


Function Get-Window {
#https://gallery.technet.microsoft.com/scriptcenter/Get-the-position-of-a-c91a5f1f
#That version only outputs RECT, the Rectangle portions are by Gil, to work with Take-Screenshot.
    <#
        .SYNOPSIS
            Retrieve the window size (height,width) and coordinates (x,y) of
            a process window.

        .DESCRIPTION
            Retrieve the window size (height,width) and coordinates (x,y) of
            a process window.

        .PARAMETER ProcessName
            Name of the process to determine the window characteristics

        .NOTES
            Name: Get-Window
            Author: Boe Prox
            Version History
                1.0//Boe Prox - 11/20/2015
                    - Initial build
				1.1//PowerGIL - 06/26/2016
					-	Changed output to be more useful.

        .OUTPUT
            System.Automation.WindowInfo

        .EXAMPLE
            Get-Process powershell | Get-Window

            ProcessName Size     TopLeft  BottomRight
            ----------- ----     -------  -----------
            powershell  1262,642 2040,142 3302,784   

            Description
            -----------
            Displays the size and coordinates on the window for the process PowerShell.exe
        
    #>
    [OutputType('System.Automation.WindowInfo')]
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipelineByPropertyName=$True)]
        $ProcessName = "powershell"
    ); #end Param
    Begin {
        Try{
            [void][Window]
        } Catch {
        Add-Type @"
              using System;
              using System.Runtime.InteropServices;
              public class Window {
                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
              }
              public struct RECT
              {
                public int Left;        // x position of upper-left corner
                public int Top;         // y position of upper-left corner
                public int Right;       // x position of lower-right corner
                public int Bottom;      // y position of lower-right corner
              }
"@
        }
    }
    Process {        
        Get-Process -Name $ProcessName | ForEach {
            $Handle = $_.MainWindowHandle
            $Rectangle = New-Object Drawing.Rectangle
            $Rect = New-Object RECT
            $Return = [Window]::GetWindowRect($Handle,[ref]$Rect)
            If ($Return) {
                $Rectangle.Height = $Rect.Bottom - $Rect.Top
                $Rectangle.Width = $Rect.Right - $Rect.Left
				$Rectangle.x = $Rect.Left
				$Rectangle.y = $Rect.Top
				
                If ($Rect.Top -lt 0 -AND $Rect.Left -lt 0) {
                    Write-Warning "Window is minimized! Coordinates will not be accurate."
                }; #end if $Rectangle.Top
                $Object = [pscustomobject]@{
                    ProcessName = $ProcessName
                    #TopLeft = $TopLeft
                    #BottomRight = $BottomRight
					Rect = $Rect
					Rectangle = $Rectangle
                }
                $Object.PSTypeNames.insert(0,'System.Automation.WindowInfo')
                $Object
            }; #end if Return
        }; #end Foreach
    }; #end Process
}; #end Get-Window

#endregion

#region Encryption
#Run in Elevated: New-SelfSignedCertificate -CertStoreLocation cert:\LocalMachine\My -DnsName "gilgamech.com"

#$test = Get-Encrypted "test"
#$de = Get-Decrypted $test

Function Get-Encrypted {
#http://powershell.org/wp/2014/02/01/revisited-powershell-and-encryption/
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		[object]$Message,
		[string]$FileName
	); #end Param
	#Write-Verbose "Encrypting to $FileName..."
	try {
	Write-Verbose "Encrypting input..."
	$secureString = $Message | ConvertTo-SecureString -AsPlainText -Force
	#	$secureString = 'This is my password.  There are many like it, but this one is mine.' | 
	#ConvertTo-SecureString -AsPlainText -Force
	
	# Generate our new 32-byte AES key.  They don't recommend using Get-Random for this; the System.Security.Cryptography namespace offers a much more secure random number generator.
	
	$key = New-Object byte[](32)
	$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
	Write-Verbose "Creating key..."
	$rng.Getbytes($key)
	
	Write-Verbose "Encrypting input..."
	$encryptedString = ConvertFrom-SecureString -SecureString $secureString -Key $key
	Write-Verbose "Input encrypted."
	
	# This is the thumbprint of a certificate on my test system where I have the private key installed.
	
	$thumbprint = (ls  -Path Cert:\CurrentUser\My\).Thumbprint
	$cert = Get-Item -Path Cert:\CurrentUser\My\$thumbprint -ErrorAction Stop
		
	$encryptedKey = $cert.PublicKey.Key.Encrypt($key, $true)
	Write-Verbose "Key encrypted."
	
	$object = New-Object psobject -Property @{
		Key = $encryptedKey
		Payload = $encryptedString
	}; #end object
	
	Write-Verbose "Encryption complete."
	
	if ($FileName) {
		$object | Export-Clixml $FileName
	} else {
		$object
	}; #end if FileName
	
	} 	finally {
		if ($null -ne $key) { [array]::Clear($key, 0, $key.Length) }
		Write-Verbose "Key cleared."
	#	if ($null -ne $secureString) { [array]::Clear($secureString, 0, $secureString.Length) }
	#	if ($null -ne $rng) { [array]::Clear($rng, 0, $rng.Length) }
	#	if ($null -ne $encryptedString) { [array]::Clear($encryptedString, 0, $encryptedString.Length) }
	#	if ($null -ne $thumbprint) { [array]::Clear($thumbprint, 0, $thumbprint.Length) }
	#	if ($null -ne $cert) { [array]::Clear($cert, 0, $cert.Length) }
	#	if ($null -ne $encryptedKey) { [array]::Clear($encryptedKey, 0, $encryptedKey.Length) }
	#	if ($null -ne $object) { [array]::Clear($object, 0, $object.Length) }

	}; #end try
}; #end Get-Encrypted 


Function Get-Decrypted {
#http://powershell.org/wp/2014/02/01/revisited-powershell-and-encryption/
	[CmdletBinding()]
	Param(
		[string]$FileName,
		[Parameter(Position=1)]
		[object]$Object #= (Import-Clixml -Path $FileName)
	); #end Param
	Write-Verbose "Decrypting..."
	try {
		#Write-Verbose "Reading file $FileName"
		#$object = Import-Clixml -Path $FileName
		if ($FileName) {
			Write-Verbose "Removing $FileName"
			rm $FileName
		}; #end if FileName
		
		$thumbprint = (ls  -Path Cert:\CurrentUser\My\).Thumbprint
		$cert = Get-Item -Path Cert:\CurrentUser\My\$thumbprint -ErrorAction Stop
		Write-Verbose $cert
		Write-Verbose $object
		$key = $cert.PrivateKey.Decrypt($object.Key, $true)
		Write-Verbose "Key decrypted."
		Write-Verbose "Decrypting payload, this may take a while..."
		$secureString = $object.Payload | ConvertTo-SecureString -Key $key
		Write-Verbose "Input decrypted."
		ConvertFrom-SecureToPlain $secureString
		Write-Verbose "Decryption complete. Hope you wrote this to a variable!"
	
	} finally {
		if ($null -ne $key) { [array]::Clear($key, 0, $key.Length) }
	Write-Verbose "Key cleared."
	}; #end try
}; #end Get-Decrypted


Function Get-BadPassword {
#http://blog.oddbit.com/2012/11/04/powershell-random-passwords/
#http://www.peterprovost.org/blog/2007/06/22/Quick-n-Dirty-PowerShell-Password-Generator/
#http://powershell.org/wp/2014/02/01/revisited-powershell-and-encryption/
	Param(
		$Length = 16,
		[string] $chars = $PlainTextAlpha 
	); #end Param
	#$chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_!@#$%^&*()_"
	#$chars = 48..57 + 65..90 + 97..122
	
	# Generate our new 32-byte AES key.  They don't recommend using Get-Random for this; the System.Security.Cryptography namespace offers a much more secure random number generator.
		
	$key = New-Object byte[]($Length)
	$rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
	#Write-Host "Creating key..." -f y
	
	$rng.Getbytes($key) #| Flip-BytesToText )
	
	#Original wouldn't reuse letters from the set. This gave a max Length of the 62 chars in the set, not random at all. This way reuses the entire set foreach letter in the password.
	[string]$NewPassword = ""
	for ($FunctionVariable = 0 ; $FunctionVariable -lt $Length ; $FunctionVariable++) {
		$NewPassword += $chars[ $key[$FunctionVariable] % $chars.Length ]	
	}; #end for FunctionVariable
	
	Return $NewPassword
	
}; #end Get-BadPassword

	#(09,10,13,(32..126)) #Can't use this because the last section stays stuck together; have to manually write them all out.
	$PlainTextKey = 9, 10, 13, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126; 
	$CipherTextKey = 41, 101, 81, 34, 104, 87, 37, 10, 77, 49, 121, 107, 105, 111, 89, 45, 42, 109, 122, 124, 116, 85, 55, 46, 99, 48, 51, 60, 125, 86, 123, 63, 50, 47, 39, 84, 114, 110, 9, 98, 79, 82, 73, 96, 64, 120, 118, 108, 40, 32, 66, 65, 117, 13, 83, 112, 113, 70, 102, 75, 69, 57, 58, 92, 53, 59, 35, 56, 94, 33, 67, 78, 68, 71, 72, 88, 80, 36, 106, 62, 44, 38, 95, 97, 100, 43, 52, 76, 126, 74, 54, 115, 61, 91, 93, 119, 90, 103;
	
	$PlainTextAlpha = -Join ($PlainTextKey | Flip-BytesToText -ASCII)
	$CipherTextAlpha = -Join ($CipherTextKey | Flip-BytesToText -ASCII)
	
Function Reset-CipherKey {
	Param(
		[string]$InputFile = $PowerGIL,
		[array]$ScrambleKey = $PlainTextKey
	); #end Param
	
	$ModuleContents = gc $InputFile
	$CTKLineNo = (($ModuleContents | Select-String '[$]CipherTextKey [=]*')[0].LineNumber - 1)
	Write-Verbose $ModuleContents[$CTKLineNo]
	$ModuleOut =  $ModuleContents[0..($CTKLineNo -1)]
	
	$NewCipherKey = Get-Random -InputObject $ScrambleKey -Count $ScrambleKey.Length
	
	[string]$OutKey = "`t`$`CipherTextKey = " 
	#Foreach Char in NewCipherKey,
	foreach ($Char in $NewCipherKey) {
		#If Char equal item last one NewCipherKey, 
		if ($Char -eq $NewCipherKey[-1]) {
		#DelimVar equals semicolon, 
			$DelimVar = ';'
		} else {
		#Else DelimVar equals comma and space.
			$DelimVar = ', '
		}; #end if Char
		$OutKey += $Char.ToString() + $DelimVar 
	}; #end foreach Char
	#$OutKey
	$ModuleOut += $OutKey
	$ModuleOut += $ModuleContents[($CTKLineNo +1)..$ModuleContents.Length]
	Insert-TextIntoFile -FileOutput $ModuleOut -FileName $InputFile
}; #end Reset-CipherKey
	
Filter Flip-StringToHashed {
#http://securekomodo.com/powershell-simple-substitution-cipher/
	$Message = $_
	# Declaring the encryption and decryption key (A=A,B=Z,C=Q dash = dash or something (this part keeps getting corrupted by something) etc)
	$CTALength = $CipherTextAlpha.Length
	# Adding letters to array
	$Hash = @{}
	for($i=0; $i -lt $CTALength; $i+=1) {
		$Hash.add($PlainTextAlpha[$i],$CipherTextAlpha[$i])
	}; #end for i
	
	# Converting to Upper
	#$Message = $Message.ToUpper()
	$CTLength = $Message.Length
	$CipherText=""
	
	for($i=0; $i -lt $CTLength; $i+=1) {
		$char = $Message[$i]
		$CipherText+=$Hash[$char]
	}; #end for i
	#Write-host -ForegroundColor Yellow "`n$CipherText"
	$CipherText

}; #end Flip-StringToHashed


Filter Flip-HashedToString {
#http://securekomodo.com/powershell-simple-substitution-cipher/
	$CipherText = $_

	# Declaring the encryption and decryption key (A=A,B=Z,C=Q dash = dash or something (this part keeps getting corrupted by something) etc)
	$CTALength = $CipherTextAlpha.Length
	# Adding letters to array
	$Hash = @{}
	for($i=0; $i -lt $CTALength; $i+=1) {
		$Hash.add($CipherTextAlpha[$i],$PlainTextAlpha[$i])
	}; #end for i

	#$CipherText = $CipherText.ToUpper()
	$CTLength = $CipherText.Length
	$PlainText=""

	for($i=0; $i -lt $CTLength; $i+=1) {
		$char = $CipherText[$i]
		$PlainText+=$Hash[$char]
	}; #end for i
	#Write-host -ForegroundColor Green "`n$PlainText"
	$PlainText
}; #end Flip-HashedToString
		


#endregion

#region UDP

Function Send-UDPText {
#http://powershell.com/cs/blogs/tips/archive/2012/05/09/communicating-between-multiple-powershells-via-udp.aspx
	Param(
		[object]$Message = (Get-Clipboard),
		[ipaddress]$serveraddr = $localhost,
		[int]$serverport = $RemotePort,
		[switch]$NotJSON,
		[switch]$Insecure
	); #end Param

	#Basic protection, at least it's not plaintext. Doesn't work with JSON IIRC.
	
	#Send Objects with JSON flag set on both sender and listener, otherwise they'll just be the useless output strings.
	if (!($NotJSON)) {
		try {
			$Message = ConvertTo-JSON $Message -ErrorAction SilentlyContinue
		} catch {
			#Try to convert to JSON, but failback to just passing the message.
			$Message = $Message
		}; #end try
	}; #end if NotJSON
		
	if (!($Insecure)) {
		$Message = ($Message | Flip-StringToHashed) 
	}; #end if Insecure
	
	$Message = Get-Encrypted $Message
	$Message = ConvertTo-JSON $Message -Compress
	
	#Create endpoint & UDP client
	$endpoint = New-Object System.Net.IPEndPoint ($serveraddr,$serverport)
	$udpclient = New-Object System.Net.Sockets.UdpClient
	
	#Swaps the message from ASCII to bytes. Should change for like Flip-TextToBytes (FLAG)
	$bytes = [Text.Encoding]::ASCII.Getbytes($Message)
	#$bytes = $Message | Flip-TextToBytes -ASCII
	
	$bytesSent = $udpclient.Send($bytes,$bytes.Length,$endpoint)
	$udpclient.Close()
}; #end Send-UDPText


Function Start-UDPListen {
#http://powershell.com/cs/blogs/tips/archive/2012/05/09/communicating-between-multiple-powershells-via-udp.aspx
	Param(
		[int]$ServerPort = $RemotePort,
		[string]$FileName,
		[switch]$NotContinuous,
		[switch]$NotJSON,
		[int]$Timeout = 2000,
		[switch]$Insecure
	); #end Param
	#If there's no endpoint, create one - this tries to avoid errors that the endpoint already exists.
	#Swap [IPAddress]::Any for an address (or range?) to limit who can send to this. That would be an ACL, and we should limit to who we think/know who has the file. OR maybe send others to another file?
	if ($endpoint.port -eq $null) {
		$endpoint = New-Object System.Net.IPEndPoint ([IPAddress]::Any,$serverport)
	}; #end if

	Write-Host "Now listening on port" $serverport -f green
	if (!($NotContinuous)) {
		Write-Host "Continuous mode" -f "Red"
	}; #end if
	
	#Create the socket
	$udpclient = New-Object System.Net.Sockets.UdpClient $serverport
	$udpclient.Client.ReceiveTimeout = $Timeout
	
	#Quick and dirty way to loop when iterate is set to true. 
	$iterate = $true
	while ($iterate) {
		#Open socket, store 
		$Content = $udpclient.Receive([ref]$endpoint) 
		
		if ($Content) {
			#Swaps the message from bytes to ASCII. Should change for like Flip-BytesToText (FLAG)
			$Content = [Text.Encoding]::ASCII.GetString($Content)
			#$Content = $Content | Flip-BytesToText -ASCII
			#$bytes = [Text.Encoding]::ASCII.Getbytes($Message)
			#$bytes = $Message | Flip-TextToBytes -ASCII
			
			#How to improve security?
			#PSK: 
			#PSK used for first message, 
			#new key computed and sent, 
			#new key encrypts second message
			#Second key encrypted and sent.
			$Content = ConvertFrom-JSON $Content
			$Content = Get-Decrypted $Content
		
			if (!($Insecure)) {
				$Content = $Content | Flip-HashedToString
				#$Content = ConvertFrom-SecureToPlain $Content -ErrorAction SilentlyContinue
				#$key = -Join ((get-random -count 16	-input (  48..57 + 65..90 + 97..122 ) ) | Flip-BytesToText)
			}; #end if Insecure
			
			#If you're receiving Objects, expect them to be sent as JSON strings, so convert them back to Objects.
			if (!($NotJSON)) {
				try {
					$Content = ConvertFrom-JSON $Content -ErrorAction SilentlyContinue
				} catch {
					#Try to convert to JSON, but failback to just passing the message.
					$Content = ConvertFrom-JSON ("'" + $Content + "'") -ErrorAction SilentlyContinue
					#$Content = $Content
				}; #end try
			} else {	}; #end if - Not sure what was going there.
			
			if ($Error) {
				Write-Verbose $Error[0]
			}; #end if Error
			
			#If Continuous flag wasn't set, dump us from the loop.
			if ($NotContinuous) {
				$iterate = $false
			}; #end if
			
			if ($FileName) {
				Write-Verbose $Content
				if ($Content.Length -ge 1) {
					$Content >> $FileName
				}; #end if content.Length
				Write-Verbose "Written to $FileName"
			} else {
				#Unsure of output format, this way just works. 
				$Content
				Write-Verbose "Standard out."
			}; #end if FileName
		} else {
			Write-Verbose "No content."
		}; #end if Content
	Write-Verbose $iterate
	} # end while
}; #end Start-UDPListen

# endregion

#region Enables the [Audio] stuffs. 
#[Audio]::Mute
#[Audio]::Volume
#[Audio]::Volume=.5
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

if ($PowerGIL) {
	#If this is running on the main module, it will load my profile. Otherwise the variable won't be there.  
	Send-UDPText (start-job -ScriptBlock {
		ipmo C:\Dropbox\Public\html5\PS1\PowerGIL.ps1; 
		Start-UDPListen -FileName C:\Dropbox\ListenFile.txt
	}) #>> C:\Dropbox\ListenFile.txt; 
	Send-UDPText (get-date -f s)
}; #end if PowerGIL


#endregion
