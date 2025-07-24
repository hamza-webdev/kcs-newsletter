# 📡 Scripts de Synchronisation VPS - Guide d'Utilisation

## 🎯 Scripts Disponibles

J'ai créé **4 scripts de synchronisation** différents pour copier vos fichiers vers le VPS selon vos besoins.

### **📋 Configuration VPS :**
- **IP** : `167.86.93.157`
- **Utilisateur** : `vpsadmin`
- **Destination** : `/home/vpsadmin/newslettre`
- **Mot de passe** : `Besmillah2025`

## 🚀 Scripts Créés

### **1. 🎨 `interactive-sync.sh` (Recommandé)**
**Script interactif avec menu coloré et options multiples**

```bash
./interactive-sync.sh
```

**Fonctionnalités :**
- ✅ **Interface colorée** avec menu de sélection
- ✅ **Options multiples** : Complète, Dossiers, Config, Rapide, Vérification
- ✅ **Vérification système** : État du serveur avant sync
- ✅ **Confirmations** : Demande validation avant actions
- ✅ **Rapport détaillé** : Statistiques et instructions finales

**Options disponibles :**
1. **Synchronisation complète** (dossiers + fichiers)
2. **Dossiers seulement** (public, src, scripts)
3. **Fichiers de config seulement**
4. **Synchronisation rapide** (sans vérifications)
5. **Vérifier l'état du serveur**

---

### **2. 🧠 `smart-sync.sh`**
**Synchronisation intelligente avec optimisations**

```bash
./smart-sync.sh
```

**Fonctionnalités :**
- ✅ **Rsync optimisé** avec exclusions automatiques
- ✅ **Exclusions intelligentes** : node_modules, .next, .git, logs
- ✅ **Sauvegarde automatique** : .env.local existant
- ✅ **Nettoyage post-sync** : Suppression fichiers temporaires
- ✅ **Rapport détaillé** : Structure et statistiques

---

### **3. ⚡ `quick-sync.sh`**
**Synchronisation rapide et simple**

```bash
./quick-sync.sh
```

**Fonctionnalités :**
- ✅ **Rapide** : Synchronisation directe sans vérifications
- ✅ **Simple** : Minimum de questions
- ✅ **Efficace** : Pour les mises à jour fréquentes
- ✅ **Léger** : Moins de logs, plus d'action

---

### **4. 📋 `sync-to-vps.sh`**
**Synchronisation complète avec vérifications détaillées**

```bash
./sync-to-vps.sh
```

**Fonctionnalités :**
- ✅ **Vérifications complètes** : Tous les fichiers avant sync
- ✅ **Rsync avec progress** : Barre de progression
- ✅ **Gestion d'erreurs** : Détection et rapport des problèmes
- ✅ **Documentation** : Explications détaillées

## 📁 Fichiers et Dossiers Synchronisés

### **Dossiers :**
```
📂 /public          # Fichiers statiques et uploads
📂 /src             # Code source Next.js
📂 /scripts         # Scripts de maintenance
```

### **Fichiers de Configuration :**
```
📄 .env.local           # Variables d'environnement
📄 package.json         # Dépendances Node.js
📄 postcss.config.mjs   # Configuration PostCSS
📄 next.config.ts       # Configuration Next.js
📄 tsconfig.json        # Configuration TypeScript
📄 docker-compose.yml   # Configuration Docker (racine)
📄 init-db.sql          # Script DB (racine)
```

## 🔧 Utilisation Recommandée

### **🎯 Première Synchronisation :**
```bash
# Script interactif avec vérifications complètes
./interactive-sync.sh
# Choisir option 1 (Synchronisation complète)
```

### **🔄 Mises à Jour Fréquentes :**
```bash
# Script rapide pour les changements mineurs
./quick-sync.sh
```

### **🧠 Synchronisation Optimisée :**
```bash
# Script intelligent avec exclusions
./smart-sync.sh
```

### **📋 Synchronisation avec Vérifications :**
```bash
# Script complet avec rapports détaillés
./sync-to-vps.sh
```

## 🔍 Vérification Post-Synchronisation

### **Connexion au VPS :**
```bash
ssh vpsadmin@167.86.93.157
cd /home/vpsadmin/newslettre
```

### **Vérification des Fichiers :**
```bash
# Structure des dossiers
ls -la

# Taille totale
du -sh .

# Permissions
ls -la *.json *.ts *.mjs .env.local

# Dossier uploads
ls -la public/uploads/
```

### **Installation et Démarrage :**
```bash
# Installation des dépendances
npm install --production

# Build de l'application
npm run build

# Démarrage des services Docker
docker-compose up -d

# Vérification des containers
docker-compose ps

# Logs en temps réel
docker-compose logs -f
```

## 🛠️ Dépannage

### **Problème de Connexion SSH :**
```bash
# Tester la connexion
ssh vpsadmin@167.86.93.157

# Configurer une clé SSH (recommandé)
ssh-keygen -t rsa -b 4096
ssh-copy-id vpsadmin@167.86.93.157
```

### **Permissions Refusées :**
```bash
# Sur le VPS, corriger les permissions
ssh vpsadmin@167.86.93.157
sudo chown -R vpsadmin:vpsadmin /home/vpsadmin/newslettre
chmod -R 755 /home/vpsadmin/newslettre
```

### **Fichiers Manquants :**
```bash
# Vérifier les fichiers locaux avant sync
ls -la app/
ls -la *.yml *.sql
```

### **Problème Docker :**
```bash
# Sur le VPS, redémarrer Docker
ssh vpsadmin@167.86.93.157
cd /home/vpsadmin/newslettre
docker-compose down
docker-compose up -d --build
```

## 📊 Comparaison des Scripts

| Script | Vitesse | Vérifications | Interface | Recommandé pour |
|--------|---------|---------------|-----------|-----------------|
| `interactive-sync.sh` | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | **Première fois** |
| `smart-sync.sh` | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | **Usage régulier** |
| `quick-sync.sh` | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ | **Mises à jour rapides** |
| `sync-to-vps.sh` | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | **Déploiement complet** |

## 🎯 Workflow Recommandé

### **1. Première Installation :**
```bash
./interactive-sync.sh  # Option 1 (Complète)
```

### **2. Développement Quotidien :**
```bash
./quick-sync.sh  # Pour les changements fréquents
```

### **3. Mise à Jour Majeure :**
```bash
./smart-sync.sh  # Avec optimisations
```

### **4. Vérification Système :**
```bash
./interactive-sync.sh  # Option 5 (Vérifier état)
```

## 🌐 Accès à l'Application

### **Après Synchronisation Réussie :**
- **HTTP** : http://167.86.93.157:3001
- **HTTPS** : https://newslettre.kcs.zidani.org (si configuré)
- **pgAdmin** : http://167.86.93.157:5050

### **Identifiants pgAdmin :**
- **Email** : `admin@newsletter-kcs.local`
- **Mot de passe** : `admin123`

---

## 🎉 **Scripts de Synchronisation Prêts !**

Vous avez maintenant **4 scripts optimisés** pour synchroniser votre application vers le VPS :

- ✅ **Interface interactive** avec menu coloré
- ✅ **Synchronisation intelligente** avec exclusions
- ✅ **Synchronisation rapide** pour les mises à jour
- ✅ **Synchronisation complète** avec vérifications

**🚀 Commencez par :**
```bash
./interactive-sync.sh
```

---

*Scripts de synchronisation automatisés pour Newsletter KCS* ✨
