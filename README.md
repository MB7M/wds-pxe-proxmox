# Déploiement PXE BIOS / UEFI via WDS – Proxmox VE

Infrastructure de déploiement automatisé de postes de travail Windows 10 sur un cloud privé Proxmox, avec configuration du serveur WDS, gestion du boot PXE (BIOS & UEFI), DHCP séparé et intégration de scripts PowerShell pour l'automatisation.  

🔗 Ce dépôt constitue la **première étape** d’un projet complet de déploiement. Il s’accompagne d’un second volet dédié à l’utilisation de **MDT** pour déployer automatiquement des postes Windows 11 via PXE.  
Accéder au projet MDT : [mdt-pxe-proxmox](https://github.com/MB7M/mdt-pxe-proxmox)

---

## Schéma d’architecture

![Schéma réseau - PXE WDS](/captures/schema_pxe_wds.png)

---

## Architecture

**Hyperviseur** : Proxmox VE  
**Réseau** : 172.168.1.0/24 (bridge)  
**Domaine** : MBITS.LAN  

**Machines virtuelles** :
- WIN-AD-GUI : Windows Server 2022 – AD / DNS / DHCP
- SRV-WDS : Windows Server 2022 – Serveur WDS
- CLI-WIN10 : Client Windows 10 – boot PXE BIOS / UEFI

---

## Services déployés

- DHCP avec options PXE (066 / 067 / 060)
- WDS (Windows Deployment Services)

---

## Documentation technique

Accessible dans [`/docs`](./docs) :  

- [Configuration VM Proxmox BIOS / UEFI](./docs/configurer_vm_proxmox_bios_uefi.md)
- [Installation du rôle WDS](./docs/installation_wds.md)
- [Configuration boot PXE BIOS](./docs/boot_pxe_bios.md)
- [Configuration boot PXE UEFI](./docs/boot_pxe_uefi.md)


---

## Automatisation

Le script PowerShell permet la configuration automatisée du service DHCP :

- Définition des classes de fournisseurs PXE
- Ajout de l’option 060
- Création des stratégies DHCP par type d’architecture
- Définition des options 066 et 067 par stratégie

→ [Script complet](scripts/pxe_dhcp_strategies.ps1)

---

## Structure du dépôt
```bash
wds-pxe-proxmox/
├── captures/                          
│   ├── schema-pxe-wds.png
│
├── docs/                              
│   ├── boot_pxe_bios.md
│   ├── boot_pxe_uefi.md
│   ├── configurer-vm-proxmox-bios-uefi.md
│   └── installation_wds.md
│
├── scripts/                          
│   └── pxe_dhcp_strategies.ps1
│
├── .gitignore                         
└── README.md   
```
---

## Objectifs atteints

- Déploiement automatique de Windows 10 via WDS
- Boot PXE BIOS / UEFI entièrement fonctionnel
- DHCP configuré avec stratégies avancées
