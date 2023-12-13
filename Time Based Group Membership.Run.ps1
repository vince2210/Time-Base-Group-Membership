#------------------------------------------------------------------------
# Source File Information (DO NOT MODIFY)
# Source ID: d4e21eb8-d088-4004-8fae-94b0bc495c8d
# Source File: C:\Data\00-Personnel\IT-EasyTools\Applications\Powershell\Time Based Group Membership\Time Based Group Membership.psproj
#------------------------------------------------------------------------
<#
    .NOTES
    --------------------------------------------------------------------------------
     Code generated by:  SAPIEN Technologies, Inc., PowerShell Studio 2023 v5.8.233
     Generated on:       13/12/2023 09:12
     Generated by:       vincent.vuccino
    --------------------------------------------------------------------------------
    .DESCRIPTION
        Script generated by PowerShell Studio 2023
#>



#region Source: Startup.pss
#----------------------------------------------
#region Import Assemblies
#----------------------------------------------
#endregion Import Assemblies

#Define a Param block to use custom parameters in the project
#Param ($CustomParameter)

function Main {
<#
    .SYNOPSIS
        The Main function starts the project application.
    
    .PARAMETER Commandline
        $Commandline contains the complete argument string passed to the script packager executable.
    
    .NOTES
        Use this function to initialize your script and to call GUI forms.
		
    .NOTES
        To get the console output in the Packager (Forms Engine) use: 
		$ConsoleOutput (Type: System.Collections.ArrayList)
#>
	Param ([String]$Commandline)
		
	#--------------------------------------------------------------------------
	#TODO: Add initialization script here (Load modules and check requirements)
	
	
	#--------------------------------------------------------------------------
	
	
		#TODO: Place initialization script here:
		
	
	if((Show-MainForm_psf) -eq 'OK')
	{
		
	}
	
	$script:ExitCode = 0 #Set the exit code for the Packager
}



#region Splash Screen Helper Function
function Show-SplashScreen
{
	<#
	.SYNOPSIS
		Displays a splash screen using the specified image.
	
	.PARAMETER Image
		Mandatory Image object that is displayed in the splash screen.
	
	.PARAMETER Title
		(Optional) Sets a title for the splash screen window. 
	
	.PARAMETER Timeout
		The amount of seconds before the splash screen is closed.
		Set to 0 to leave the splash screen open indefinitely.
		Default: 2
	
	.PARAMETER ImageLocation
		The file path or url to the image.

	.PARAMETER PassThru
		Returns the splash screen form control. Use to manually close the form.
	
	.PARAMETER Modal
		The splash screen will hold up the pipeline until it closes.

	.EXAMPLE
		PS C:\> Show-SplashScreen -Image $Image -Title 'Loading...' -Timeout 3

	.EXAMPLE
		PS C:\> Show-SplashScreen -ImageLocation 'C:\Image\MyImage.png' -Title 'Loading...' -Timeout 3

	.EXAMPLE
		PS C:\> $splashScreen = Show-SplashScreen -Image $Image -Title 'Loading...' -PassThru
				#close the splash screen
				$splashScreen.Close()
	.OUTPUTS
		System.Windows.Forms.Form
	
	.NOTES
		Created by SAPIEN Technologies, Inc.

		The size of the splash screen is dependent on the image.
		The required assemblies to use this function outside of a WinForms script:
		Add-Type -AssemblyName System.Windows.Forms
		Add-Type -AssemblyName System.Drawing
#>
	[OutputType([System.Windows.Forms.Form])]
	param
	(
		[Parameter(ParameterSetName = 'Image',
				   Mandatory = $true,
				   Position = 1)]
		[ValidateNotNull()]
		[System.Drawing.Image]$Image,
		[Parameter(Mandatory = $false)]
		[string]$Title,
		[int]$Timeout = 2,
		[Parameter(ParameterSetName = 'ImageLocation',
				   Mandatory = $true,
				   Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]$ImageLocation,
		[switch]$PassThru,
		[switch]$Modal
	)
	
	#Create a splash screen form to display the image.
	$splashForm = New-Object System.Windows.Forms.Form
	
	#Create a picture box for the image
	$pict = New-Object System.Windows.Forms.PictureBox
	
	if ($Image)
	{
		$pict.Image = $Image;
	}
	else
	{
		$pict.Load($ImageLocation)
	}
	
	$pict.AutoSize = $true
	$pict.Dock = 'Fill'
	$splashForm.Controls.Add($pict)
	
	#Display a title if defined.
	if ($Title)
	{
		$splashForm.Text = $Title
		$splashForm.FormBorderStyle = 'FixedDialog'
	}
	else
	{
		$splashForm.FormBorderStyle = 'None'
	}
	
	#Set a timer
	if ($Timeout -gt 0)
	{
		$timer = New-Object System.Windows.Forms.Timer
		$timer.Interval = $Timeout * 1000
		$timer.Tag = $splashForm
		$timer.add_Tick({
				$this.Tag.Close();
				$this.Stop()
			})
		$timer.Start()
	}
	
	#Show the form
	$splashForm.AutoSize = $true
	$splashForm.AutoSizeMode = 'GrowAndShrink'
	$splashForm.ControlBox = $false
	$splashForm.StartPosition = 'CenterScreen'
	$splashForm.TopMost = $true
	
	if ($Modal) { $splashForm.ShowDialog() }
	else { $splashForm.Show() }
	
	if ($PassThru)
	{
		return $splashForm
	}
}
#endregion
#endregion Source: Startup.pss

#region Source: MainForm.psf
function Show-MainForm_psf
{
	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$MainForm = New-Object 'System.Windows.Forms.Form'
	$pictureboxSplashScreenHidden = New-Object 'System.Windows.Forms.PictureBox'
	$buttonCallChildForm = New-Object 'System.Windows.Forms.Button'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	$MainForm_Load={
	#TODO: Initialize Form Controls here
		<#
		Use the -PassTru parameter to update the splash screen text:
		.EXAMPLE
		$splashForm = Show-SplashScreen ... -PassThru
		#Update the splash screen text
		$splashForm.Text = 'Loading Modules...'
		#>
			
			$paramShowSplashScreen = @{
				Image    = $pictureboxSplashScreenHidden.Image
				Title    = 'Loading...'
				PassThru = $false
			}
			
			Show-SplashScreen @paramShowSplashScreen
	}
	
	$buttonCallChildForm_Click={
		#TODO: Place custom script here
		if((Show-ChildForm_psf) -eq 'OK')
		{
			
		}
	}
	
	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$MainForm.WindowState = $InitialFormWindowState
	}
	
	$Form_StoreValues_Closing=
	{
		#Store the control values
	}

	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$buttonCallChildForm.remove_Click($buttonCallChildForm_Click)
			$MainForm.remove_Load($MainForm_Load)
			$MainForm.remove_Load($Form_StateCorrection_Load)
			$MainForm.remove_Closing($Form_StoreValues_Closing)
			$MainForm.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$MainForm.SuspendLayout()
	$pictureboxSplashScreenHidden.BeginInit()
	#
	# MainForm
	#
	$MainForm.Controls.Add($pictureboxSplashScreenHidden)
	$MainForm.Controls.Add($buttonCallChildForm)
	$MainForm.AutoScaleDimensions = New-Object System.Drawing.SizeF(6, 13)
	$MainForm.AutoScaleMode = 'Font'
	$MainForm.ClientSize = New-Object System.Drawing.Size(292, 266)
	$MainForm.Margin = '4, 4, 4, 4'
	$MainForm.Name = 'MainForm'
	$MainForm.StartPosition = 'CenterScreen'
	$MainForm.Text = 'Main Form'
	$MainForm.add_Load($MainForm_Load)
	#
	# pictureboxSplashScreenHidden
	#
	#region Binary Data
	$Formatter_binaryFomatter = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
	$System_IO_MemoryStream = New-Object System.IO.MemoryStream (,[byte[]][System.Convert]::FromBase64String('
AAEAAAD/////AQAAAAAAAAAMAgAAAFFTeXN0ZW0uRHJhd2luZywgVmVyc2lvbj00LjAuMC4wLCBD
dWx0dXJlPW5ldXRyYWwsIFB1YmxpY0tleVRva2VuPWIwM2Y1ZjdmMTFkNTBhM2EFAQAAABVTeXN0
ZW0uRHJhd2luZy5CaXRtYXABAAAABERhdGEHAgIAAAAJAwAAAA8DAAAACDcAAAL/2P/gABBKRklG
AAEBAQEsASwAAP/bAEMAAwICAwICAwMDAwQDAwQFCAUFBAQFCgcHBggMCgwMCwoLCw0OEhANDhEO
CwsQFhARExQVFRUMDxcYFhQYEhQVFP/bAEMBAwQEBQQFCQUFCRQNCw0UFBQUFBQUFBQUFBQUFBQU
FBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFP/AABEIAlgDIAMBIgACEQEDEQH/xAAe
AAEAAwEBAQEBAQEAAAAAAAAABwgJBgUEAgEDCv/EAFcQAQABAwMBAwQJDgoGCgMAAAABAgMEBQYR
BwgSIQkTMVEUGSJBVmF1lbMVFhcYNzhVdIGUtNHS0yMyNlRxkZOlstRCUldikqEkNXJ2goSxtcHw
Q1Nj/8QAHAEBAAIDAQEBAAAAAAAAAAAAAAUGAwQHCAIB/8QAPBEBAAECAwIKBwcEAwEAAAAAAAEC
AwQFEQYhEjFBUWFxgZGxwRMyNFOh0fAHFBUiMzVSkrLh4hdUctL/2gAMAwEAAhEDEQA/ANUwAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAGNuX2xuqmxOvev7is7pz9QsW9VyKLmjZuRXcwK7EXaoizFqZmKI
imOImniY96fTzskwA6jfdC3R8qZX0tSzZJaouzciuNd0IDNrlduLc0Tpvltx0G677b7Qmw8fcu3r
s0VRMWs3T7sx57Cv8RM26/XHjzFUeFUePh4xEjsJ+gvXrc3Z73zY3Ft2/wB+3VxbztNu1T5jNs8+
NFce9PpmmqPGmfi5idnOifWfb3XnYGFuvbd6qca9M2sjGu+F3EvxETXauR645iefRMTEx4S0sxy+
rCVcKnfRPw6JbWBxsYmng1etHx6XePC3lvLTtj6Lc1HUbnFMe5tWaf492v3qaY/+8P7vHd+n7I0O
7qWoVzFFPubdqn+Pdr96mn4//T0qjb33vqO/Narz8+vimOabOPTPuLNHqj/5n33LNptpreSWvRWv
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
kH3Wtk/LeF9PQ27URo8nfq23uuuka1t7WMGjZGJqVjUIoy7lc5lmmi5Fc2Yju8V+McRVNUeE+PjH
je5vZtibWJqoqtTruSGcYq1iqrdVqddwAgFdAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABW
/S/KEdEtY1PEwMXceZXk5V6ixapnS8iImuqqKaY5mjw8ZhZAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAByHWHKvYPSTe+TjXrmPkWdDzrlu9aqmmuiqMeuYqpmPGJiY5iYde4v
rX9xrfnyBn/o9wGSXZk6tb41btC9O8LO3nuDNw7+uYtu9j5GqX7lu5TNyOaaqZr4mJ9Urc+VJ3lr
+0NB6eV6DrmpaJXfyc2LtWnZdzHm5EU2eIq7kxzxzPp9ajfZU++T6afL+J9LDcTM07E1CKYysWzk
xT/Fi9bivj+jkGDX2auofw83N88ZH7Z9mrqH8PNzfPGR+23b+tvSPwXhfm9H6lKfKpaVhYHR/aVe
Lh4+NXVrsRNVm1TRMx7Hu+HhAM+vs1dQ/h5ub54yP2z7NXUP4ebm+eMj9tcPyUGnYmobh6jxlYtn
JinFwe7F63FfHu73o5aMfW3pH4Lwvzej9QM7PJh7/wB0bt6t7qxtc3Jq+tY9rQ5uUWdQzrt+iir2
RajvRFdUxE8TMc/G0lfJiaVhYFdVeLh4+NXVHE1WbVNEzHq8IfWAAAye7efaF399sPuLbembp1bR
NC0TzGPjYWm5lzGoqqmzRXXXX3Jjv1TVXVxM88RxEceLWFir25/vruoX41Z/RrQI8+zV1D+Hm5vn
jI/bPs1dQ/h5ub54yP22xPZZ0HTMjs4dNrl3TsS5cq0LEmquuxTMzPm48ZnhKX1t6R+C8L83o/UD
CT7NXUP4ebm+eMj9t13R/rBvzO6tbJxsne248jHva5g27lq7q2RVRXTN+iJpqia+JiYniYltb9be
kfgvC/N6P1P1Rt7SrVdNdGm4dFdM801U2KImJ9ceAPQBR/tk9uDfXZ56uWdrbc0nbubp9emWc2bm
qY1+5d79ddyJjmi9RHHFEe96/EF4BlX7at1Z+D2zPzLL/wA0+7RfKudRrGo269X2ntfOwI/j2MKj
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
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB//9kL'))
	#endregion
	$pictureboxSplashScreenHidden.Image = $Formatter_binaryFomatter.Deserialize($System_IO_MemoryStream)
	$Formatter_binaryFomatter = $null
	$System_IO_MemoryStream = $null
	$pictureboxSplashScreenHidden.Location = New-Object System.Drawing.Point(37, 13)
	$pictureboxSplashScreenHidden.Name = 'pictureboxSplashScreenHidden'
	$pictureboxSplashScreenHidden.Size = New-Object System.Drawing.Size(100, 50)
	$pictureboxSplashScreenHidden.TabIndex = 1
	$pictureboxSplashScreenHidden.TabStop = $False
	#
	# buttonCallChildForm
	#
	$buttonCallChildForm.Anchor = 'None'
	$buttonCallChildForm.Location = New-Object System.Drawing.Point(97, 122)
	$buttonCallChildForm.Name = 'buttonCallChildForm'
	$buttonCallChildForm.Size = New-Object System.Drawing.Size(98, 23)
	$buttonCallChildForm.TabIndex = 0
	$buttonCallChildForm.Text = 'Call Child Form'
	$buttonCallChildForm.UseCompatibleTextRendering = $True
	$buttonCallChildForm.UseVisualStyleBackColor = $True
	$buttonCallChildForm.add_Click($buttonCallChildForm_Click)
	$pictureboxSplashScreenHidden.EndInit()
	$MainForm.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $MainForm.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$MainForm.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$MainForm.add_FormClosed($Form_Cleanup_FormClosed)
	#Store the control values when form is closing
	$MainForm.add_Closing($Form_StoreValues_Closing)
	#Show the Form
	return $MainForm.ShowDialog()

}
#endregion Source: MainForm.psf

#region Source: Globals.ps1
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
	
	#Sample variable that provides the location of the script
	[string]$ScriptDirectory = Get-ScriptDirectory
	
	
	
	
#endregion Source: Globals.ps1

#region Source: ChildForm.psf
function Show-ChildForm_psf
{
	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$formChildForm = New-Object 'System.Windows.Forms.Form'
	$buttonOK = New-Object 'System.Windows.Forms.Button'
	$buttonCancel = New-Object 'System.Windows.Forms.Button'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	
	$formChildForm_Load={
		#TODO: Initialize Form Controls here
		
	}
	
	
	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$formChildForm.WindowState = $InitialFormWindowState
	}
	
	$Form_StoreValues_Closing=
	{
		#Store the control values
	}

	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$formChildForm.remove_Load($formChildForm_Load)
			$formChildForm.remove_Load($Form_StateCorrection_Load)
			$formChildForm.remove_Closing($Form_StoreValues_Closing)
			$formChildForm.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$formChildForm.SuspendLayout()
	#
	# formChildForm
	#
	$formChildForm.Controls.Add($buttonOK)
	$formChildForm.Controls.Add($buttonCancel)
	$formChildForm.AutoScaleDimensions = New-Object System.Drawing.SizeF(6, 13)
	$formChildForm.AutoScaleMode = 'Font'
	$formChildForm.ClientSize = New-Object System.Drawing.Size(284, 262)
	$formChildForm.Margin = '4, 4, 4, 4'
	$formChildForm.Name = 'formChildForm'
	$formChildForm.StartPosition = 'CenterParent'
	$formChildForm.Text = 'Child Form'
	$formChildForm.add_Load($formChildForm_Load)
	#
	# buttonOK
	#
	$buttonOK.Anchor = 'Bottom, Right'
	$buttonOK.DialogResult = 'OK'
	$buttonOK.Location = New-Object System.Drawing.Point(116, 227)
	$buttonOK.Name = 'buttonOK'
	$buttonOK.Size = New-Object System.Drawing.Size(75, 23)
	$buttonOK.TabIndex = 1
	$buttonOK.Text = '&OK'
	$buttonOK.UseCompatibleTextRendering = $True
	$buttonOK.UseVisualStyleBackColor = $True
	#
	# buttonCancel
	#
	$buttonCancel.Anchor = 'Bottom, Right'
	$buttonCancel.CausesValidation = $False
	$buttonCancel.DialogResult = 'Cancel'
	$buttonCancel.Location = New-Object System.Drawing.Point(197, 227)
	$buttonCancel.Name = 'buttonCancel'
	$buttonCancel.Size = New-Object System.Drawing.Size(75, 23)
	$buttonCancel.TabIndex = 0
	$buttonCancel.Text = '&Cancel'
	$buttonCancel.UseCompatibleTextRendering = $True
	$buttonCancel.UseVisualStyleBackColor = $True
	$formChildForm.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $formChildForm.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$formChildForm.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$formChildForm.add_FormClosed($Form_Cleanup_FormClosed)
	#Store the control values when form is closing
	$formChildForm.add_Closing($Form_StoreValues_Closing)
	#Show the Form
	return $formChildForm.ShowDialog()

}
#endregion Source: ChildForm.psf

#Start the application
Main ($CommandLine)
