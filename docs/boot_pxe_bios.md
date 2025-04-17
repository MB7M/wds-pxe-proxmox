## Boot PXE en mode BIOS avec WDS

### Objectif

Configurer un environnement PXE fonctionnel pour les machines virtuelles démarrant en **mode BIOS**, à l’aide d’un serveur WDS sur Windows Server 2022. Ce guide s’applique aux environnements virtualisés sous Proxmox VE.

> Pour la configuration du démarrage PXE en mode UEFI (et cohabitation BIOS/UEFI), se référer au fichier [boot-pxe-uefi.md](./boot_pxe_uefi.md).  
> Pour la configuration des VMs dans Proxmox, se référer au fichier [configurer-vm-proxmox-bios-uefi.md](./configurer-vm-proxmox-bios-uefi.md)  
> Pour l'installation du rôle WDS et l'ajout des images, voir [installation_wds.md](./installation_wds.md)

---

### Prérequis

- Un serveur WDS installé et intégré au domaine
    
- Images de démarrage et d’installation déjà importées
    
- Une VM configurée en mode BIOS (SeaBIOS), avec le **boot PXE en premier**
    
- Connexion réseau fonctionnelle avec le serveur DHCP
    

---

### Configuration du DHCP pour PXE BIOS

Dans le cas d’un serveur DHCP **séparé du serveur WDS**, certaines options doivent être explicitement définies pour permettre aux clients BIOS de localiser le serveur de démarrage et initier correctement le processus PXE.

#### Étapes à suivre :

1. Ouvrir la **console DHCP** sur le serveur AD/DHCP
    
2. Clic droit sur **IPv4 > Options d’étendue**
    
3. Ajouter les options suivantes :
    

|Option|Description|Valeur|
|---|---|---|
|066|Nom d’hôte du serveur de démarrage|IP du serveur WDS (ex. `172.168.1.42`)|
|067|Nom du fichier de démarrage|`boot\x64\wdsnbp.com`|

> Cette configuration permet aux clients BIOS de télécharger le fichier `wdsnbp.com`, qui est un **Network Bootstrap Program (NBP)** utilisé par WDS pour initialiser le démarrage PXE.  
> Il agit comme un premier niveau de chargeur, vérifie l’architecture du client, et transfère le contrôle au fichier `boot.wim` via TFTP.


![sortie](/captures/options_66_67_DHCP.png)
    
![sortie](/captures/option_67_DHCP.png)
    

---

### Test du démarrage PXE BIOS

#### Scénario

- VM Windows 10 configurée avec :
    
    - Firmware : **SeaBIOS**
        
    - Carte réseau : **Intel E1000**, mode bridge
        
    - Ordre de démarrage : `net0` (PXE) en premier
        
- Serveur WDS en ligne avec images configurées
    
- Serveur DHCP avec les options 066 et 067 correctement définies
    

#### Étapes observées au démarrage

1. La VM obtient une adresse IP via DHCP
    
2. Le fichier `wdsnbp.com` est téléchargé depuis le serveur WDS via TFTP
    
3. Affichage de l’invite PXE : `Press F12 for network service boot`  

![sortie](/captures/boot_pxe_cli10_bios_ok.png)

4. Après avoir appuyé sur **F12**, le fichier `boot.wim` est téléchargé et monté en mémoire
    

![sortie](/captures/démarrage_mode_bios_cli10.png)
