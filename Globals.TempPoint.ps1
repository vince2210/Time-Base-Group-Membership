#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------


#Sample function that provides the location of the script
function Get-ScriptDirectory
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
#>
	[OutputType([string])]
	param ()
	if ($null -ne $hostinvocation)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}

function Get-IniSection($inifile, $section)
{
	$sections = select-string "^\[.*\]" $inifile
	if (!$section)
	{
		return $sections | %{ $_.Line.Trim("[]") }
	}
	$start = 0
	switch ($sections)
	{
		{ $_.Line.Trim() -eq "[$section]" }{
			$start = $_.LineNumber - 1
			
		}
		default
		{
			if ($start)
			{
				return (gc $inifile)[($start) .. ($start + ($_.LineNumber - 2 - $start))]
			}
		}
	}
	$lines = gc $inifile
	return $lines[$start .. ($lines.length - 1)]
}

function test-initsection($inifile, $section)
{
	$test_section = "[$section]"
	$content = gc $inifile
	if ($content -eq $test_section)
	{
		#$test_initsection = $true
		return $true
	}
	else
	{
		#$test_initsection = $False
		return $false
		#Set-IniSection -inifile $inifile -section $test_section
	}
}

function Set-IniSection($inifile, $section)
{
	$mode = [System.IO.FileMode]::Append
	$access = [System.IO.FileAccess]::Write
	$sharing = [IO.FileShare]::Read
	$fs = New-Object IO.FileStream($inifile, $mode, $access, $sharing)
	$sw = New-Object System.IO.StreamWriter($fs)
	$sw.WriteLine("`n[$section]")
	$sw.WriteLine("USERNAME=")
	$sw.WriteLine("PASSWORD=")
	$sw.WriteLine("CONNEXION=False")
	$sw.Dispose()
	$fs.Dispose()
	
	$sw.Close()
	$fs.Close()
}

function Get-IniValue($inifile, $section, $name)
{
	$section = Get-IniSection $inifile $section
	($section | Select-String "^\s*$name\s*=").Line.Split("=", 2)[1]
}

function Set-IniValue($inifile, $section, $name, $value)
{
	$lines = gc $inifile
	$pattern = "^\[.*\]"
	
	$sections = select-string -Pattern $pattern -Path $inifile
	$start, $end = 0, 0
	for ($l = 0; $l -lt $sections.Count; ++$l)
	{
		if ($sections[$l].Line.Trim() -eq "[$section]")
		{
			$start = $sections[$l].LineNumber
			if ($l + 1 -ge $sections.Count)
			{
				$end = $lines.length - 1;
			}
			else
			{
				$end = $sections[$l + 1].LineNumber - 2
			}
		}
	}
	
	if ($start -and $end)
	{
		$done = $false
		for ($l = $start; $l -le $end; ++$l)
		{
			if ($lines[$l] -match "^\s*$name\s*=")
			{
				$lines[$l] = "{0}={1}" -f $name, $value
				$done = $true
				break;
			}
		}
		if (!$done)
		{
			$output = $lines[0 .. $start]
			$output += "{0}={1}" -f $name, $value
			$output += $lines[($start + 1) .. ($lines.Length - 1)]
			$lines = $output
		}
	}
	
	Set-Content $inifile $lines
}

##
## This is a ... different way of doing it, 
## which will be faster if you need to read lots of values
#### HOWEVER ####
## I don't recommend using Set-IniFile, because it will loose any comments etc
## 
function Get-IniFile
{
	param ([string]$inifile = $(Throw "You must specify the name of an ini file!"))
	$INI = @{ }
	$s, $k, $v = $null
	foreach ($line in (gc $inifile | ? { $_[0] -ne ";" -and $_.Trim().Length -gt 0 }))
	{
		$k, $v = $line.Split("=", 2)
		if ($v -eq $null)
		{
			$s = $k.Trim("[]")
			$INI[$s] = @{ }
		}
		else
		{
			$INI[$s][$k.Trim()] = $v.Trim()
		}
	}
	return $INI
}

function Set-IniFile
{
	param ([HashTable]$ini,
		[string]$inifile = $(Throw "You must specify the name of an ini file!"))
	[string[]]$inistring = @()
	foreach ($section in $ini.Keys)
	{
		#Add-Content $inifile ("[{0}]" -f $section)
		$inistring += ("`n[{0}]" -f $section)
		foreach ($key in $ini[$section].Keys)
		{
			$inistring += ("{0} = {1}" -f $key, $ini[$section][$key])
		}
	}
	# make the write be atomic ... 
	Set-Content $inifile $inistring
}


function Show-MsgBox
{
	[CmdletBinding()]
	param (
		[Parameter(Position = 0, Mandatory = $true)]
		[string]$Prompt,
		[Parameter(Position = 1, Mandatory = $false)]
		[string]$Title = "",
		[Parameter(Position = 2, Mandatory = $false)]
		[ValidateSet("Information", "Question", "Critical", "Exclamation")]
		[string]$Icon = "Information",
		[Parameter(Position = 3, Mandatory = $false)]
		[ValidateSet("OKOnly", "OKCancel", "AbortRetryIgnore", "YesNoCancel", "YesNo", "RetryCancel")]
		[string]$BoxType = "OkOnly",
		[Parameter(Position = 4, Mandatory = $false)]
		[ValidateSet(1, 2, 3)]
		[int]$DefaultButton = 1
	)
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
	switch ($Icon)
	{
		"Question" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Question }
		"Critical" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Critical }
		"Exclamation" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Exclamation }
		"Information" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Information }
	}
	switch ($BoxType)
	{
		"OKOnly" { $vb_box = [microsoft.visualbasic.msgboxstyle]::OKOnly }
		"OKCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::OkCancel }
		"AbortRetryIgnore" { $vb_box = [microsoft.visualbasic.msgboxstyle]::AbortRetryIgnore }
		"YesNoCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::YesNoCancel }
		"YesNo" { $vb_box = [microsoft.visualbasic.msgboxstyle]::YesNo }
		"RetryCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::RetryCancel }
	}
	switch ($Defaultbutton)
	{
		1 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton1 }
		2 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton2 }
		3 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton3 }
	}
	$popuptype = $vb_icon -bor $vb_box -bor $vb_defaultbutton
	$ans = [Microsoft.VisualBasic.Interaction]::MsgBox($prompt, $popuptype, $title)
	return $ans
}

function show-inputbox
{
	[CmdletBinding()]
	param (
		[Parameter(Position = 0, Mandatory = $true)]
		[string]$message,
		[Parameter(Position = 1, Mandatory = $false)]
		[string]$title = "input Box",
		[Parameter(Position = 2, Mandatory = $false)]
		[ValidateSet("OKOnly", "OKCancel", "AbortRetryIgnore", "YesNoCancel", "YesNo", "RetryCancel")]
		[string]$BoxType = "OkOnly",
		[Parameter(Position = 3, Mandatory = $false)]
		[string]$DefaultButton
	)
	[reflection.assembly]::loadwithpartialname("microsoft.visualbasic") | Out-Null
	switch ($BoxType)
	{
		"OKOnly" { $vb_box = [microsoft.visualbasic.msgboxstyle]::OKOnly }
		"OKCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::OkCancel }
		"AbortRetryIgnore" { $vb_box = [microsoft.visualbasic.msgboxstyle]::AbortRetryIgnore }
		"YesNoCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::YesNoCancel }
		"YesNo" { $vb_box = [microsoft.visualbasic.msgboxstyle]::YesNo }
		"RetryCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::RetryCancel }
	}
	switch ($Defaultbutton)
	{
		1 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton1 }
		2 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton2 }
		3 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton3 }
	}
	$popuptype = $vb_box -bor $vb_defaultbutton
	$ans = [Microsoft.VisualBasic.Interaction]::inputbox($message, $title)
	return $ans
}


#Sample variable that provides the location of the script
[string]$ScriptDirectory = Get-ScriptDirectory
$Script:Base32Charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'

$Global:config = "$ScriptDirectory\TBGM.ps1.config"
#if ((Test-Path $Global:config) -eq $false)
#{
#	$mode = [System.IO.FileMode]::Append
#	$access = [System.IO.FileAccess]::Write
#	$sharing = [IO.FileShare]::Read
#	$fs = New-Object IO.FileStream($Global:config, $mode, $access, $sharing)
#	$sw = New-Object System.IO.StreamWriter($fs)
#	$sw.WriteLine("[SMTP]")
#	$sw.WriteLine("SERVER=")
#	$sw.WriteLine("PORT=")
#	$sw.WriteLine("FROM=")
#	$sw.Dispose()
#	$fs.Dispose()
#	$sw.Close()
#	$fs.Close()
#}

$Global:QRCODEICON = "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"
$GLOBAL:iconBytes = [Convert]::FromBase64String($Global:QRCODEICON)
$GLOBAL:stream = New-Object IO.MemoryStream($GLOBAL:iconBytes, 0, $GLOBAL:iconBytes.Length)
$GLOBAL:stream.Write($GLOBAL:iconBytes, 0, $GLOBAL:iconBytes.Length);
$GLOBAL:iconImage = [System.Drawing.Image]::FromStream($GLOBAL:stream, $true)
$GLOBAL:Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $GLOBAL:stream).GetHIcon())

#Measure-Command -Expression { Get-ADGroup -filter 'GroupCategory -eq "Security"' -SearchBase "DC=lab,DC=metsys,DC=fr" -Properties * }
#Measure-Command -Expression { Get-ADGroup -filter 'GroupCategory -eq "Security"' -SearchBase "DC=lab,DC=metsys,DC=fr" -Properties SamAccountName, Name, Members, MemberOf, Member, DistinguishedName -ShowMemberTimeToLive }



#-filter 'GroupCategory -eq "Security"'


#SamAccountName, DistinguishedName, ObjectClass


[void]([System.Reflection.Assembly]::Load([System.Convert]::FromBase64String($assemblyString)))
if ((Get-IniValue $Global:config "SMTP" "SERVER") -eq '')
{
	$inputmessage = show-inputbox -message "Setup SMTP Server" -title "Config SMTP" -BoxType OKCancel
	if ($inputmessage -ne '')
	{
		Set-IniValue -inifile $global:config -section "SMTP" -name "SERVER" -value $inputmessage
		$Global:SMTPSERVER = Get-IniValue $Global:config "SMTP" "SERVER"
	}
}
else
{
	$Global:SMTPSERVER = Get-IniValue $Global:config "SMTP" "SERVER"
}

if ((Get-IniValue $Global:config "SMTP" "PORT") -eq '')
{
	$inputmessage = show-inputbox -message "Setup SMTP Server PORT" -title "Config SMTP" -BoxType OKCancel
	if ($inputmessage -ne '')
	{
		Set-IniValue -inifile $global:config -section "SMTP" -name "PORT" -value $inputmessage
		$Global:SMTPSERVERPORT = Get-IniValue $Global:config "SMTP" "PORT"
	}
}
else
{
	$Global:SMTPSERVERPORT = Get-IniValue $Global:config "SMTP" "PORT"
}

if ((Get-IniValue $Global:config "SMTP" "FROM") -eq '')
{
	$inputmessage = show-inputbox -message "Setup SMTP Server FROM" -title "Config SMTP" -BoxType OKCancel
	if ($inputmessage -ne '')
	{
		Set-IniValue -inifile $global:config -section "SMTP" -name "FROM" -value $inputmessage
		$Global:SMTPSERVERFROM = Get-IniValue $Global:config "SMTP" "FROM"
	}
}
else
{
	$Global:SMTPSERVERFROM = Get-IniValue $Global:config "SMTP" "FROM"
}


$OutputPath = "$env:temp\qrcode.png"
$CodeWidth = 20

$global:ForestMode = ""
$global:DomainMode = ""
$global:PAMF = ""
$Global:domain = ""