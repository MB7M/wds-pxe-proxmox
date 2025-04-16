## Installation et configuration de WDS sur Windows Server 2022

### Objectif

Configurer le rôle **Windows Deployment Services (WDS)** , afin de permettre le démarrage PXE des postes clients dans le cadre d’un déploiement automatisé de Windows 10 ou Windows 11.

Le serveur WDS est intégré à un domaine Active Directory. Le service DHCP est hébergé sur un serveur distinct, qui assure également les rôles de contrôleur de domaine (AD DS) et de serveur DNS.

---

### Prérequis

#### Environnement réseau

- Un serveur AD avec les rôles **AD DS, DNS et DHCP** installés et opérationnels
    
- Un domaine Active Directory fonctionnel 
    
- Une infrastructure réseau configurée avec une plage d’adresses attribuées via DHCP
    

#### Serveur WDS

- Windows Server 2022 (GUI) installé
    
- Serveur joint au domaine
    
- Adresse IP statique
    
- Une **image ISO de Windows 10 ou Windows 11** montée
    
- Un **disque secondaire** ou une **partition dédiée** pour stocker les fichiers WDS (ex. : `D:\RemoteInstall`)
    

---

### Étapes d’installation de WDS

#### 1. Ajout du rôle via le Gestionnaire de serveur

- Ouvrir le **Gestionnaire de serveur**
    
- Lancer **Ajouter des rôles et fonctionnalités**
    
- Type d’installation : `Installation basée sur un rôle ou une fonctionnalité`
    
- Sélectionner le serveur local
    

#### 2. Sélection du rôle WDS

- Cochez **Services de déploiement Windows**
    
- Ajouter les fonctionnalités requises
    
- Composants à sélectionner :
    
    - Serveur de déploiement
        
    - Transport PXE
        

![sortie](/captures/wds_composants.png)

#### 3. Lancer l’installation

- Valider et lancer l’installation
    
- Redémarrer le serveur si demandé
    

---

### Configuration initiale de WDS

#### 1. Lancer la console WDS

- Outils > Services de déploiement Windows
    
- Clic droit sur le nom du serveur > **Configurer le serveur**
    

#### 2. Paramètres

- Type : **Intégré à Active Directory**
    
- Répertoire d'installation : `D:\RemoteInstall`
    
- Répondre aux clients : **connus et inconnus**
    

![sortie](/captures/console_wds.png)

---

### Ajout des images de déploiement

#### 1. Monter l’image ISO

- Monter une ISO Windows 10 ou 11 sur le serveur
    
- Accéder au répertoire `sources` :
    
    - `boot.wim` → image de démarrage
        
    - `install.wim` ou `install.esd` → image d’installation
        

#### 2. Cas des ISO avec `install.esd`

Certaines ISO (notamment issues de l'outil Media Creation Tool) contiennent un fichier `install.esd` à la place de `install.wim`.

Dans ce cas, il est nécessaire de **convertir l’ESD en WIM** à l’aide de PowerShell et `DISM`.

##### Commande PowerShell (à exécuter en tant qu’administrateur) :


```powershell
dism /Export-Image /SourceImageFile:"D:\sources\install.esd" /SourceIndex:6 /DestinationImageFile:"D:\sources\install.wim" /Compress:max /CheckIntegrity
```

- `SourceIndex` : correspond à l’édition de Windows (ex. : 6 = Windows 10 Pro)
    
- Le fichier `install.wim` sera généré dans le même dossier
    

#### 3. Ajouter une image de démarrage

- WDS > clic droit sur **Images de démarrage** > Ajouter une image
    
- Sélectionner `boot.wim`
    
- Nom personnalisé : `Windows PE`
    

![sortie](/captures/image_démarrage.png)

#### 4. Ajouter une image d’installation

- WDS > clic droit sur **Images d’installation** > Ajouter une image
    
- Créer un groupe d’image : `Windows 10` ou `Windows 11`
    
- Sélectionner `install.wim`
    
- Cochez l’édition souhaitée (ex. : Windows 10 Pro)
    

![sortie](/captures/image_installation.png)

---

### Résultat

- Rôle WDS installé et intégré au domaine
    
- Images de démarrage et d’installation disponibles dans la console
    
- Dossier `D:\RemoteInstall` prêt pour les démarrages PXE BIOS/UEFI
