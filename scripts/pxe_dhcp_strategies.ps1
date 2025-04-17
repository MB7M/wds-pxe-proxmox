# ---------------------------------------------------------------------
# Script PowerShell - Configuration PXE DHCP (BIOS + UEFI)
# Auteur : Mohamed B.
# Objectif : Créer les classes fournisseurs + stratégies DHCP PXE
# ---------------------------------------------------------------------

# VARIABLES PRINCIPALES
$DhcpServerName = "WIN-AD-GUI"            # Nom d'hôte du serveur DHCP
$PxeServerIp    = "172.168.1.42"          # IP du serveur WDS
$Scope          = "172.168.1.0"           # Adresse réseau de l'étendue DHCP

# -- Étape 1 : Ajouter les classes de fournisseurs DHCP
Add-DhcpServerv4Class -ComputerName $DhcpServerName -Name "PXEClient - UEFI x64" -Type Vendor -Data "PXEClient:Arch:00007" -Description "PXEClient:Arch:00007"
Add-DhcpServerv4Class -ComputerName $DhcpServerName -Name "PXEClient - UEFI x86" -Type Vendor -Data "PXEClient:Arch:00006" -Description "PXEClient:Arch:00006"
Add-DhcpServerv4Class -ComputerName $DhcpServerName -Name "PXEClient - BIOS x86 et x64" -Type Vendor -Data "PXEClient:Arch:00000" -Description "PXEClient:Arch:00000"

# -- Étape 2 : Créer la stratégie BIOS
$PolicyNameBIOS = "PXEClient - BIOS x86 et x64"
Add-DhcpServerv4Policy -ComputerName $DhcpServerName -ScopeId $Scope -Name $PolicyNameBIOS -Description "Options DHCP pour boot BIOS x86 et x64" -Condition Or -VendorClass EQ, "PXEClient - BIOS x86 et x64*"
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 066 -Value $PxeServerIp -PolicyName $PolicyNameBIOS
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 067 -Value "boot\x64\wdsnbp.com" -PolicyName $PolicyNameBIOS

# -- Étape 3 : Créer la stratégie UEFI x86
$PolicyNameUEFIx86 = "PXEClient - UEFI x86"
Add-DhcpServerv4Policy -ComputerName $DhcpServerName -ScopeId $Scope -Name $PolicyNameUEFIx86 -Description "Options DHCP pour boot UEFI x86" -Condition Or -VendorClass EQ, "PXEClient - UEFI x86*"
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 060 -Value "PXEClient" -PolicyName $PolicyNameUEFIx86
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 066 -Value $PxeServerIp -PolicyName $PolicyNameUEFIx86
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 067 -Value "boot\x86\wdsmgfw.efi" -PolicyName $PolicyNameUEFIx86

# -- Étape 4 : Créer la stratégie UEFI x64
$PolicyNameUEFIx64 = "PXEClient - UEFI x64"
Add-DhcpServerv4Policy -ComputerName $DhcpServerName -ScopeId $Scope -Name $PolicyNameUEFIx64 -Description "Options DHCP pour boot UEFI x64" -Condition Or -VendorClass EQ, "PXEClient - UEFI x64*"
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 060 -Value "PXEClient" -PolicyName $PolicyNameUEFIx64
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 066 -Value $PxeServerIp -PolicyName $PolicyNameUEFIx64
Set-DhcpServerv4OptionValue -ComputerName $DhcpServerName -ScopeId $Scope -OptionId 067 -Value "boot\x64\wdsmgfw.efi" -PolicyName $PolicyNameUEFIx64
