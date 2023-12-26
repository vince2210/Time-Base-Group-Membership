<# 
.SYNOPSIS 

    Ce script permet l'ajout temporaire pour un utilisateur dans un groupe AD en graphique.  

.DESCRIPTION 

	  Ce script permet via l'interface graphique de:
        - choisir un utilisateur (possible de taper les premières lettres pour limiter la sortie du combobox)
        - Choisir le groupe dnas lequel l'utilisateur sera ajouté (possible de taper les premières lettres pour limiter la sortie du combobox)
        - indiquer combien de temps l'utilisateur devra être ajouté (possible en jour Heure ou Minute ou une combiniason des 3)
     Ce script log dans un fichier LOGS_Temporary_Group_Membership.txt à l'endroit du script, les actions menées la date et qui les a effectué   

.REQUIREMENT
    La fonctionnalité "Temporary group Membership" DOIT etre activée sur la forêt (Cette fonctionnalité nécessite une foret en niveau fonctionnel 2016)
    le module ActiveDirectory doit etre présent
    
.NOTES 

    Nom de l'auteur : Thierry PLANTIVE 
    Entreprise      : METSYS 
    Version         : 1.0 
    Date            : 20/12/2023
    Modification    : rédaction initiale. 
    Permissions     : utilisateur avec droit d'ajouter des membres au groupe cible
#>

#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function Show-MainForm_psf {

	#----------------------------------------------
	#region Import des Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	#endregion Import des Assemblies

	#----------------------------------------------
	#region Generer les objets du formulaire
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$Add_Temorary_Member = New-Object 'System.Windows.Forms.Form'
	$button_Add_member = New-Object 'System.Windows.Forms.Button'
	$labelMinutes = New-Object 'System.Windows.Forms.Label'
	$cmbbox_Minutes = New-Object 'System.Windows.Forms.ComboBox'
	$lbl_hours = New-Object 'System.Windows.Forms.Label'
	$cmbbox_heures = New-Object 'System.Windows.Forms.ComboBox'
	$lbl_jours = New-Object 'System.Windows.Forms.Label'
	$cmbbox_Jours = New-Object 'System.Windows.Forms.ComboBox'
	$lbl_membre_pendant = New-Object 'System.Windows.Forms.Label'
	$cmbbox_GroupName = New-Object 'System.Windows.Forms.ComboBox'
	$lbl_Group_Name = New-Object 'System.Windows.Forms.Label'
	$cmbbox_SamAccName = New-Object 'System.Windows.Forms.ComboBox'
	$lbl_SamAccName = New-Object 'System.Windows.Forms.Label'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	$Add_Temorary_Member_Load={
		#TODO: Initialize Form Controls here
		
	}
	
	$lbl_SamAccName_Click={
		#TODO: Place custom script here
		
	}
function Test-ADModuleInstalled {
    param()

    # Vérifie si le module est importé
    $moduleImported = Get-Module -Name ActiveDirectory -ListAvailable

    # Vérifie si la fonctionnalité Active Directory est installée
    $featureInstalled = Get-WindowsFeature -Name AD-Domain-Services

    $isImported = if ($moduleImported -ne $null) { $true } else { $false }
    $isInstalled = if ($featureInstalled.Installed -eq "True") { $true } else { $false }

    return @{
        ModuleImported = $isImported
        ModuleInstalled = $isInstalled
    }
}
	
function Test-TemporaryGroupMembership {
    $result = $null

    # Récupération des informations sur la forêt
    $temporaryGroupMembership = (Get-ADOptionalFeature -Filter "name -eq 'Privileged Access Management Feature'").featurescope

    if ($temporaryGroupMembership -eq "ForestOrConfigurationSet") {
            $result = $true
        } else {
            $result = $false
        }
return $result
}


	#region Control Helper Functions
	function Update-ComboBox
	{
	<#
		.SYNOPSIS
			This functions helps you load items into a ComboBox.
		
		.DESCRIPTION
			Use this function to dynamically load items into the ComboBox control.
		
		.PARAMETER ComboBox
			The ComboBox control you want to add items to.
		
		.PARAMETER Items
			The object or objects you wish to load into the ComboBox's Items collection.
		
		.PARAMETER DisplayMember
			Indicates the property to display for the items in this control.
			
		.PARAMETER ValueMember
			Indicates the property to use for the value of the control.
		
		.PARAMETER Append
			Adds the item(s) to the ComboBox without clearing the Items collection.
		
		.EXAMPLE
			Update-ComboBox $combobox1 "Red", "White", "Blue"
		
		.EXAMPLE
			Update-ComboBox $combobox1 "Red" -Append
			Update-ComboBox $combobox1 "White" -Append
			Update-ComboBox $combobox1 "Blue" -Append
		
		.EXAMPLE
			Update-ComboBox $combobox1 (Get-Process) "ProcessName"
		
		.NOTES
			Additional information about the function.
	#>
		
		param
		(
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			[System.Windows.Forms.ComboBox]
			$ComboBox,
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			$Items,
			[Parameter(Mandatory = $false)]
			[string]$DisplayMember,
			[Parameter(Mandatory = $false)]
			[string]$ValueMember,
			[switch]
			$Append
		)
		
		if (-not $Append)
		{
			$ComboBox.Items.Clear()
		}
		
		if ($Items -is [Object[]])
		{
			$ComboBox.Items.AddRange($Items)
		}
		elseif ($Items -is [System.Collections.IEnumerable])
		{
			$ComboBox.BeginUpdate()
			foreach ($obj in $Items)
			{
				$ComboBox.Items.Add($obj)
			}
			$ComboBox.EndUpdate()
		}
		else
		{
			$ComboBox.Items.Add($Items)
		}
		
		$ComboBox.DisplayMember = $DisplayMember
		$ComboBox.ValueMember = $ValueMember
	}
	#end 

##############################################################################
###############  Fonction pour écrire dans les logs  #########################
##############################################################################
Function writelog($log_path, $LogText)
{
	# Définir la variable de date à la française 
	$system_date = (get-date).tostring('dd/MM/yyyy HH:mm:ss') # Récupération de la date pour les logs
	
	$contents = "[" + $system_date + "] - " + [Environment]::UserName + " : " + $LogText # Informations pour les logs
	Add-content -path $log_path -value $contents # Ajout d'informations dans les logs
}

# variable du log de sortie : 
$logfile = "$PSScriptRoot\LOGS_Temporary_Group_Membership.txt"

	
# Utilisation de la fonction pour vérifier la présence de la fonctionnalité "Temporary Group Membership"
$result = Test-TemporaryGroupMembership 

if ($result) {
    Write-Host "La fonctionnalité 'Temporary Group Membership' est présente dans la forêt."
} else {
    Write-Host "La fonctionnalité 'Temporary Group Membership' n'est pas présente dans la forêt."
    Write-Host "Ce script ne sert à rien."
    exit
}


# Utilisation de la fonction de vérification des outils AD
$moduleInfo = Test-ADModuleInstalled

if ($moduleInfo.ModuleInstalled) {
    Write-Host "La fonctionnalité Active Directory est installée."
    if ($moduleInfo.ModuleImported) {
    Write-Host "Le module Active Directory est importé."
} else {
    Write-Host "Le module Active Directory n'est pas importé. Le script ne fonctionnera pas."
    import-module ActiveDirectory
}
} else {
    Write-Host "La fonctionnalité Active Directory n'est pas installée. Le script ne fonctionnera pas."
    Write-Host "Merci d'installer les outils AD sur ce poste et le relancer."

}


    #remplir le combobox jours de 0 à 30
	for ($i=0; $i -lt 8; $i++)
	{
		$cmbbox_Jours.Items.Add($i)
	}
    $cmbbox_Jours.Items.Add(14)
    $cmbbox_Jours.Items.Add(21)
    $cmbbox_Jours.Items.Add(30)
    
    $cmbbox_Jours.SelectedIndex = 0
	

	#remplir le combobox heure de 0 à 23
	for ($i=0;$i -lt 8;$i++)
	{
		$cmbbox_heures.Items.Add($i)
        
	}
    $cmbbox_heures.Items.Add(12)
    $cmbbox_heures.Items.Add(14)
    $cmbbox_heures.Items.Add(23)
	$cmbbox_heures.SelectedIndex = 0

	#remplir le combobox Minutes de 0 à 59
	for ($i=0;$i -lt 60; $i=$i+10)
	{
		$cmbbox_minutes.Items.Add($i)
	}
    $cmbbox_minutes.SelectedIndex = 0

	
	$cmbbox_SamAccName_TextUpdate={
	    $saisie = $cmbbox_SamAccName.Text
        $user_begin = $cmbbox_SamAccName.Text+"*"
        $Users_possibles = Get-ADUser -Filter {sAMAccountName -like $user_begin} | select samaccountname
		Update-ComboBox $cmbbox_SamAccName $Users_possibles.samaccountname
        $cmbbox_SamAccName.DroppedDown = $true
        $cmbbox_SamAccName.Text = $saisie
        $cmbbox_SamAccName.Select($cmbbox_SamAccName.Text.Length, 0)
        #$cmbbox_SamAccName.Focus()	
	}
	
	$cmbbox_GroupName_TextUpdate={
	    $saisieG = $cmbbox_GroupName.Text
        $Grp_begin = $cmbbox_GroupName.Text+"*"
        $Grp_possibles = Get-ADgroup -Filter {sAMAccountName -like $Grp_begin} | select samaccountname
		Update-ComboBox $cmbbox_GroupName $Grp_possibles.samaccountname
		$cmbbox_GroupName.DroppedDown = $true
        $cmbbox_GroupName.text = $saisieG
        $cmbbox_GroupName.Select($cmbbox_GroupName.Text.Length, 0)
	}
	
	$button_Add_member_Click={
		write-host "click"
        # Calculer le Temps en seconde
        $nombreJ = [int]$cmbbox_Jours.text
        $nombreH = [int]$cmbbox_heures.text
        $nombreM = [int]$cmbbox_Minutes.text
        $tempspSec = ($nombreJ * 24*60*60)+ ($nombreH.text *60*60)+($nombreM *60)
        write-host "vous voulez placer le compte dans le groupe pour $tempspSec Secondes" 

        Add-ADGroupMember -Identity $cmbbox_GroupName.text -Members $cmbbox_SamAccName.text -MemberTimeToLive (New-TimeSpan -seconds $tempspSec) 
        writelog $logfile "Ajout du compte $($cmbbox_SamAccName.text) dans le groupe $($cmbbox_GroupName.text) pendant $nombreJ jours, $nombreH heures et $nombreM minutes."
        #Lancer le script de scan des groupes
        #$checkallgroups = read-host "Voulez-vous lister tous les membres temporaires de la forêt (o / n). Attention le scan portera sur tous les groupes). ?" 
        
        Add-Type -AssemblyName System.Windows.Forms

        # Message à afficher dans la boîte de dialogue
        $message = "Voulez-vous lancer le script de scan des membres temporaires (attention, cela scan tous les groupes de l'AD) ?"

        # Titre de la boîte de dialogue
        $titre = "Confirmation du lancement du script"

        # Options de la boîte de dialogue
        $options = [System.Windows.Forms.MessageBoxButtons]::YesNo

        # Type de message (question)
        $type = [System.Windows.Forms.MessageBoxIcon]::Question

        # Afficher la boîte de dialogue et récupérer la réponse de l'utilisateur
        $resultat = [System.Windows.Forms.MessageBox]::Show($message, $titre, $options, $type)

        # Vérifier la réponse de l'utilisateur
        if ($resultat -eq [System.Windows.Forms.DialogResult]::Yes) {
            # L'utilisateur a choisi "Oui", exécuter le script
            Invoke-Expression -Command "& `"$PSScriptRoot\Get-List_group_members_with_expiration_TTL_V1.0.ps1`""
        } else {
            # L'utilisateur a choisi "Non", ne pas exécuter le script
            Write-Host "Opération annulée."
        }
	}
	
	# --End User Script--

	#----------------------------------------------
	# Evenements
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$Add_Temorary_Member.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$button_Add_member.remove_Click($button_Add_member_Click)
			$cmbbox_GroupName.remove_TextUpdate($cmbbox_GroupName_TextUpdate)
			$cmbbox_SamAccName.remove_TextUpdate($cmbbox_SamAccName_TextUpdate)
			$lbl_SamAccName.remove_Click($lbl_SamAccName_Click)
			$Add_Temorary_Member.remove_Load($Add_Temorary_Member_Load)
			$Add_Temorary_Member.remove_Load($Form_StateCorrection_Load)
			$Add_Temorary_Member.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
	}
	#end Evenements

	#----------------------------------------------
	# Formulaire
	#----------------------------------------------
	$Add_Temorary_Member.SuspendLayout()
	#
	# Add_Temorary_Member
	#
	$Add_Temorary_Member.Controls.Add($button_Add_member)
	$Add_Temorary_Member.Controls.Add($labelMinutes)
	$Add_Temorary_Member.Controls.Add($cmbbox_Minutes)
	$Add_Temorary_Member.Controls.Add($lbl_hours)
	$Add_Temorary_Member.Controls.Add($cmbbox_heures)
	$Add_Temorary_Member.Controls.Add($lbl_jours)
	$Add_Temorary_Member.Controls.Add($cmbbox_Jours)
	$Add_Temorary_Member.Controls.Add($lbl_membre_pendant)
	$Add_Temorary_Member.Controls.Add($cmbbox_GroupName)
	$Add_Temorary_Member.Controls.Add($lbl_Group_Name)
	$Add_Temorary_Member.Controls.Add($cmbbox_SamAccName)
	$Add_Temorary_Member.Controls.Add($lbl_SamAccName)
	$Add_Temorary_Member.AutoScaleDimensions = '6, 13'
	$Add_Temorary_Member.AutoScaleMode = 'Font'
	$Add_Temorary_Member.ClientSize = '1200, 360'
	$Add_Temorary_Member.Name = 'Add_Temorary_Member'
	$Add_Temorary_Member.Text = 'Ajouter temporairement un utilisateur dans un groupe'
	$Add_Temorary_Member.add_Load($Add_Temorary_Member_Load)
	#
# button_Add_member
	#
	$button_Add_member.Location = '837, 119'
	$button_Add_member.Name = 'button_Add_member'
	$button_Add_member.Size = '148, 23'
	$button_Add_member.TabIndex = 11
	$button_Add_member.Text = 'Ajouter l''utilisateur'
	$button_Add_member.UseCompatibleTextRendering = $True
	$button_Add_member.UseVisualStyleBackColor = $True
	$button_Add_member.add_Click($button_Add_member_Click)
	#
	# labelMinutes
	#
	$labelMinutes.AutoSize = $True
	$labelMinutes.Location = '673, 123'
	$labelMinutes.Name = 'labelMinutes'
	$labelMinutes.Size = '51, 17'
	$labelMinutes.TabIndex = 10
	$labelMinutes.Text = 'minute(s)'
	$labelMinutes.UseCompatibleTextRendering = $True
	#
	# cmbbox_Minutes
	#
	$cmbbox_Minutes.FormattingEnabled = $True
	$cmbbox_Minutes.Location = '630, 123'
	$cmbbox_Minutes.Name = 'cmbbox_Minutes'
	$cmbbox_Minutes.Size = '37, 21'
	$cmbbox_Minutes.TabIndex = 9
	#
	# lbl_hours
	#
	$lbl_hours.AutoSize = $True
	$lbl_hours.Location = '545, 123'
	$lbl_hours.Name = 'lbl_hours'
	$lbl_hours.Size = '46, 17'
	$lbl_hours.TabIndex = 8
	$lbl_hours.Text = 'heure(s)'
	$lbl_hours.UseCompatibleTextRendering = $True
	#
	# cmbbox_heures
	#
	$cmbbox_heures.FormattingEnabled = $True
	$cmbbox_heures.Location = '495, 123'
	$cmbbox_heures.Name = 'cmbbox_heures'
	$cmbbox_heures.Size = '35, 21'
	$cmbbox_heures.TabIndex = 7
	#
	# lbl_jours
	#
	$lbl_jours.AutoSize = $True
	$lbl_jours.Location = '435, 123'
	$lbl_jours.Name = 'lbl_jours'
	$lbl_jours.Size = '36, 17'
	$lbl_jours.TabIndex = 6
	$lbl_jours.Text = 'jour(s)'
	$lbl_jours.UseCompatibleTextRendering = $True
	#
	# cmbbox_Jours
	#
	$cmbbox_Jours.FormattingEnabled = $True
	$cmbbox_Jours.Location = '372, 123'
	$cmbbox_Jours.Name = 'cmbbox_Jours'
	$cmbbox_Jours.Size = '40, 21'
	$cmbbox_Jours.TabIndex = 5
	#
	# lbl_membre_pendant
	#
	$lbl_membre_pendant.AutoSize = $True
	$lbl_membre_pendant.Location = '36, 127'
	$lbl_membre_pendant.Name = 'lbl_membre_pendant'
	$lbl_membre_pendant.Size = '206, 17'
	$lbl_membre_pendant.TabIndex = 4
	$lbl_membre_pendant.Text = 'Ajouter l''utilisateur dans le groupe pour :'
	$lbl_membre_pendant.UseCompatibleTextRendering = $True
	#
	# cmbbox_GroupName
	#
	$cmbbox_GroupName.FormattingEnabled = $True
	$cmbbox_GroupName.Location = '372, 78'
	$cmbbox_GroupName.Name = 'cmbbox_GroupName'
	$cmbbox_GroupName.Size = '352, 21'
	$cmbbox_GroupName.TabIndex = 3
	$cmbbox_GroupName.add_TextUpdate($cmbbox_GroupName_TextUpdate)
	#
	# lbl_Group_Name
	#
	$lbl_Group_Name.AutoSize = $True
	$lbl_Group_Name.Location = '36, 78'
	$lbl_Group_Name.Name = 'lbl_Group_Name'
	$lbl_Group_Name.Size = '82, 17'
	$lbl_Group_Name.TabIndex = 2
	$lbl_Group_Name.Text = 'Nom du groupe'
	$lbl_Group_Name.UseCompatibleTextRendering = $True
	#
	# cmbbox_SamAccName
	#
	$cmbbox_SamAccName.FormattingEnabled = $True
	$cmbbox_SamAccName.Location = '372, 29'
	$cmbbox_SamAccName.Name = 'cmbbox_SamAccName'
	$cmbbox_SamAccName.Size = '352, 21'
	$cmbbox_SamAccName.TabIndex = 1
	$cmbbox_SamAccName.add_TextUpdate($cmbbox_SamAccName_TextUpdate)
	#
	# lbl_SamAccName
	#
	$lbl_SamAccName.AutoSize = $True
	$lbl_SamAccName.Location = '36, 33'
	$lbl_SamAccName.Name = 'lbl_SamAccName'
	$lbl_SamAccName.Size = '171, 17'
	$lbl_SamAccName.TabIndex = 0
	$lbl_SamAccName.Text = 'SamAccountName de l''utilisateur'
	$lbl_SamAccName.UseCompatibleTextRendering = $True
	$lbl_SamAccName.add_Click($lbl_SamAccName_Click)
	$Add_Temorary_Member.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $Add_Temorary_Member.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$Add_Temorary_Member.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$Add_Temorary_Member.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $Add_Temorary_Member.ShowDialog()

} #End Function

#Call the form
Show-MainForm_psf | Out-Null
