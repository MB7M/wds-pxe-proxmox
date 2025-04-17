## Configuration des VMs pour tests PXE dans Proxmox

### Objectif

Préparer une machine virtuelle dans **Proxmox VE** pour tester le démarrage PXE sur un serveur WDS, en mode **BIOS** ou **UEFI**, selon les scénarios documentés ci-dessous :

- [Configuration PXE en mode BIOS](./boot_pxe_bios.md)
    
- [Configuration PXE en mode UEFI et cohabitation BIOS/UEFI](./boot_pxe_uefi.md)
    

---

### Contexte

Le test a été réalisé dans un environnement virtualisé sous **Proxmox VE**, avec une seule VM Windows 10 utilisée pour valider les deux modes de démarrage :

- Mode **BIOS** configuré avec le firmware SeaBIOS
    
- Mode **UEFI** configuré avec le firmware OVMF (UEFI)
    

Les paramètres ont été modifiés **après création de la VM**, directement dans l’interface Proxmox.

---

### Configuration réseau de la VM

- **Connexion** : interface réseau en mode bridge (ex :`vmbr0`, `vmbr1`), sur le même sous-réseau que le serveur DHCP/WDS
    
- **Type d’interface recommandé** : `Intel E1000`
    
    - Nativement reconnue par Windows PE (aucun pilote à injecter)
        
- **Note technique** :
    
    - En cas d’utilisation de l’interface `VirtIO`, il faut **intégrer les pilotes réseau dans le fichier `boot.wim`** pour garantir la détection de l’interface lors du démarrage PXE
        

---

### Paramétrage du démarrage réseau (BIOS ou UEFI)

> La procédure de configuration du démarrage réseau est identique quel que soit le mode (BIOS ou UEFI). Les différences concernent uniquement le choix du firmware.

#### 1. Choisir le type de BIOS

- Aller dans **Hardware > BIOS**
    
- Choisir le firmware selon le scénario :
    
    - **SeaBIOS** pour le test en mode BIOS
        
    - **OVMF (UEFI)** pour le test en mode UEFI
        
- Exemple de sélection SeaBIOS :

![sortie](/captures/mode_bios_proxmox.png)

> Pour le mode UEFI :
> 
> - Ajouter un **EFI Disk** (via _Add > EFI Disk_) si non présent
>     
> - Désactiver l’option **Secure Boot**
>     

#### 2. Configurer l’ordre de démarrage

- Aller dans **Options > Boot Order**
    
- Placer **net0 (Network Device)** en première position

![sortie](/captures/test_vmcli10_bootorder_PXE_BIOS.png)
