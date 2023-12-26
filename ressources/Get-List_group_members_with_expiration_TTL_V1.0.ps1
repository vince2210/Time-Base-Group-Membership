<# 
.SYNOPSIS 

    Ce script permet de lister tous les groupes contenant des membres pendant une durée déterminée à l'ajout dans le groupe.  

.DESCRIPTION 

	  Ce script identifie pour tous les groupes de l'AD la présence de membres ajoutés avec un TTL via la fonctionnalité Temporary Group Membership 
        Il effectue un rendu en tableau avec le groupe concerné, le compte avec un TTL dnas ce groupe, le temps restant et la date d'expiration de cette jonction au groupe.
 
        - les données seront aussi exportées dans un ficihier de logs.

.NOTES 

    Nom de l'auteur : Thierry PLANTIVE 
    Entreprise      : METSYS 
    Version         : 1.0 
    Date            : 16/12/2023
    Modification    : rédaction initiale. 
    Permissions     : DomainAdmins 
#>

cls

# path du file de sortie (option de sortie des OUs dans un CSV)
$pathfile = "$PSScriptRoot\Groupes_Avec_Membres_Temporaires.log"

$resultat = ""
# Création d'une liste d'objets avec les informations
$groupesUtilisateurs = @()

##### Variables #####
#$all_groups = get-adgroup -filter * -SearchBase "OU=G_DEFAULT_USERS_CONTENER_GROUPS_T0,OU=Groupes_T0,OU=T0,OU=Administration,DC=Labth22,DC=fr" | select name, distinguishedname
$all_groups = get-adgroup -filter *  | select name, distinguishedname


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

foreach ($OneGroup in $all_groups){
    # Obtenez les membres du groupe AD
    $groupemembers = Get-ADGroup -Identity $OneGroup.name -Properties Member -ShowMemberTimeToLive

    # Parcourez les membres du groupe
    foreach ($membre in $groupemembers.Member) {
            
        # Vérifier si la première partie commence par '<TTL=2633>'
        if ($membre.StartsWith("<TTL=")) {
            #write-host "TROUVE : $membre"
            $elements = $membre.Split(',', 2)
            # Récupérer la première partie avant la virgule
            $ttl = $elements[0].Trim()
            $Compte = $elements[1].Trim()

        # Vérifier si la chaîne contient '<TTL='
        if ($ttl -match '<TTL=(\d+)>') {
            $nombreSecondes = [int]($Matches[1])
            }
            #write-host "nb secondes: $nombreSecondes"
            # Convertir les secondes en jours, heures et minutes
            $jours = [math]::Floor($nombreSecondes / 86400)
            $resteJours = $nombreSecondes % 86400
            $heures = [math]::Floor($resteJours / 3600)
            $resteHeures = $resteJours % 3600
            $minutes = [math]::Floor($resteHeures / 60)
            #Write-Host "Nombre de secondes : $nombreSecondes"
            #Write-Host "Reste $jours jours, $heures heures et $minutes minutes"
            $Reste = "Il en est encore membre pour $jours jours, $heures heures et $minutes minutes."
            # Obtenir la date et l'heure actuelles
            $now = Get-Date

            # Ajouter le nombre de secondes de la TTL à la date actuelle
            $expiration = $now.AddSeconds($nombreSecondes)

            #Write-Host "Nombre de secondes : $nombreSecondes"
            Write-Host "Le compte $compte sera supprimé du groupe $($OneGroup.name) a cette date: $expiration. $reste"
            #$resultat +=   "La TTL expirera le : $expiration pour le membre $compte dans le groupe $($OneGroup.name)"

            # Ajout des données pour chaque groupe/utilisateur
            $groupe_user = [PSCustomObject]@{
            NomDuGroupe = "$($OneGroup.name)"
            CompteUtilisateur = "$Compte"
            DateExpiration = "$expiration"
            tempsRestant = "$Reste"
            }
            # Ajout des objets à la liste
            $groupesUtilisateurs += $groupe_user
            
            writelog "$pathfile" "Le compte $compte sera supprimé du groupe $($OneGroup.name) a cette date: $expiration. $reste"
        } # fin foreach
    } # fin du if group exist

} # fin du foreach groups

#Write-host "voici le résultat: $resultat"
$groupesUtilisateurs | Out-GridView