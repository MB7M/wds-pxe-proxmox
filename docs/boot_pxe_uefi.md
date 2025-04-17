## Boot PXE en mode UEFI avec WDS

### Objectif

Configurer un environnement PXE fonctionnel pour les machines virtuelles démarrant en **mode UEFI**, à l’aide d’un serveur WDS sur Windows Server 2022 et d’un serveur DHCP distinct.  
Ce guide s’applique aux environnements virtualisés sous Proxmox VE.

> Pour la configuration du démarrage PXE en mode BIOS uniquement, se référer à `boot-pxe-bios.md`.  
> Pour la configuration des VMs dans Proxmox, se référer à `configurer-vm-proxmox-bios-uefi.md`.  
> Pour l'installation du rôle WDS et l'ajout des images, voir `installation_wds.md`.

---

### Prérequis

- Un serveur WDS installé, configuré et intégré au domaine  
- Un serveur DHCP distinct, sur le même réseau  
- Une VM en **mode UEFI (OVMF)** 
- Carte réseau **E1000**
- Boot PXE configuré en priorité dans la VM

---

### A. Ajouter l’option 060 PXEClient

Par défaut, l’option 060 n’est pas visible dans la console DHCP. Elle est indispensable pour permettre au serveur DHCP d'indiquer sa capacité PXE.

#### Interface graphique

Non disponible par défaut.

#### PowerShell sur le serveur DHCP :

```powershell
Add-DhcpServerv4OptionDefinition -ComputerName WIN-AD-GUI -Name PXEClient -Description "PXE Support" -OptionId 060 -Type String
```

- ComputerName à adapter en fonction du serveur

![PXE Option 060](/captures/ajout_op_60.png)

---

### B. Déclarer les classes de fournisseurs

Ces classes permettent d’identifier l’architecture du client (BIOS ou UEFI) lors de la demande PXE.

#### Interface graphique

1. Ouvrir la console DHCP  
2. Clic droit sur **IPv4 > Définir les classes**  
3. Ajouter :

| Nom                           | ID de classe fournisseur     |
|--------------------------------|-------------------------------|
| PXEClient - BIOS x86 et x64   | PXEClient:Arch:00000          |
| PXEClient - UEFI x64          | PXEClient:Arch:00007          |
| PXEClient - UEFI x86 *(optionnel)* | PXEClient:Arch:00006    |

 
![Classes DHCP](/captures/classe_fournisseurs.png)


---

### C. Créer les stratégies DHCP conditionnelles

Les stratégies permettent de fournir dynamiquement le bon fichier de démarrage (`wdsnbp.com` ou `wdsmgfw.efi`) selon l’architecture détectée.

#### Interface graphique

1. DHCP > IPv4 > Étendue > clic droit sur **Stratégies**
2. Créer une stratégie par classe de fournisseur (ex. : BIOS, UEFI x64)
3. Définir les options :

| Architecture cible | Option 066 (Serveur WDS) | Option 067 (Fichier)            |
|--------------------|---------------------------|----------------------------------|
| BIOS x86/x64       | 172.168.1.42              | `boot\x64\wdsnbp.com`            |
| UEFI x64           | 172.168.1.42              | `boot\x64\wdsmgfw.efi`           |
| UEFI x86 (optionnel)| 172.168.1.42             | `boot\x86\wdsmgfw.efi`           |

  
  ![Stratégies DHCP](/captures/stratégies_etendues.png)  

Si l'on regarde les options de notre étendue DHCP, on peut voir qu'il y a beaucoup de valeurs. Effectivement, nous avons plusieurs fois les mêmes options, mais avec des valeurs différentes, et la bonne valeur sera appliquée en fonction de la machine qui initie la connexion.

  ![Options PXE](/captures/options_etendues.png)

---

### D. Test du démarrage PXE UEFI

#### Scénario

- VM Windows 10 configurée avec :
    
    - Firmware : **OVMF (UEFI)**
        
    - Carte réseau : **Intel E1000**, mode bridge
        
    - Ordre de démarrage : `net0` (PXE) en premier

#### Étapes observées au démarrage

1. La VM UEFI reçoit une adresse IP du serveur DHCP  
2. Le fichier `wdsmgfw.efi` est chargé depuis le WDS  
3. L'écran du **WDS Boot Manager** s'affiche, indiquant que le client est prêt  
4. L'utilisateur doit appuyer sur **Entrée** pour lancer le chargement de `boot.wim`

![Boot PXE UEFI](/captures/boot_uefi.png)  

##  Automatiser toute la configuration

L'ensemble des étapes manuelles décrites ci-dessus (option 060, classes de fournisseurs, stratégies DHCP) peuvent être automatisées via un script PowerShell.

Voir le script complet : [`scripts/pxe_dhcp_strategies.ps1`](../scripts/pxe_dhcp_strategies.ps1)
