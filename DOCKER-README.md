# 🐳 Déploiement Docker - Newsletter KCS

Guide complet pour déployer l'application Newsletter KCS avec Docker en local.

## 📋 Prérequis

### **Logiciels Requis :**
- ✅ **Docker Desktop** (Windows/Mac) ou **Docker Engine** (Linux)
- ✅ **Docker Compose** (inclus avec Docker Desktop)
- ✅ **Git** (pour cloner le repository)

### **Configuration Système :**
- 🖥️ **RAM** : Minimum 4GB (8GB recommandé)
- 💾 **Espace disque** : 2GB libres
- 🌐 **Ports** : 3001, 5050, 5433, 8025, 1025 (libres)

## 🚀 Démarrage Rapide

### **1. Cloner le Repository :**
```bash
git clone https://github.com/hamza-webdev/kcs-newsletter.git
cd kcs-newsletter
```

### **2. Configuration :**
```bash
# Copier le fichier d'environnement
cp .env.docker .env

# IMPORTANT: Éditer le fichier .env et configurer votre clé OpenAI
nano .env  # ou votre éditeur préféré
```

### **3. Démarrage :**
```bash
# Méthode 1: Script automatique (recommandé)
./start-docker.sh

# Méthode 2: Commande manuelle
docker-compose up --build -d
```

### **4. Vérification :**
Attendez 1-2 minutes puis accédez à :
- 🌐 **Application** : http://localhost:3001
- 🗄️ **pgAdmin** : http://localhost:5050
- 📧 **MailHog** : http://localhost:8025

## 🔧 Services Inclus

| Service | Port | Description | Accès |
|---------|------|-------------|-------|
| **Newsletter App** | 3001 | Application Next.js | http://localhost:3001 |
| **PostgreSQL** | 5433 | Base de données | localhost:5433 |
| **pgAdmin** | 5050 | Interface DB | http://localhost:5050 |
| **MailHog** | 8025 | Serveur email test | http://localhost:8025 |

### **Identifiants pgAdmin :**
- 📧 **Email** : `admin@newsletter-kcs.local`
- 🔑 **Mot de passe** : `admin123`

## ⚙️ Configuration

### **Variables d'Environnement (.env) :**
```bash
# OpenAI (OBLIGATOIRE)
OPENAI_API_KEY=sk-proj-votre-cle-ici

# Base de données (automatique)
DB_HOST=postgres
DB_PORT=5432
DB_NAME=newsletter_kcs
DB_USER=postgres
DB_PASSWORD=postgres123

# Email (MailHog pour tests)
SMTP_HOST=mailhog
SMTP_PORT=1025
SMTP_FROM=newsletter@kcs.local
```

### **Personnalisation :**
Pour modifier les ports ou la configuration, éditez `docker-compose.yml`.

## 📊 Commandes Utiles

### **Gestion des Services :**
```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Redémarrer
docker-compose restart

# Voir les logs
docker-compose logs -f

# Voir l'état
docker-compose ps
```

### **Maintenance :**
```bash
# Reconstruire l'application
docker-compose up --build -d app

# Nettoyer les volumes (⚠️ supprime les données)
docker-compose down -v

# Nettoyer complètement
docker system prune -a
```

### **Base de Données :**
```bash
# Accès direct à PostgreSQL
docker exec -it newsletter-postgres psql -U postgres -d newsletter_kcs

# Sauvegarde
docker exec newsletter-postgres pg_dump -U postgres newsletter_kcs > backup.sql

# Restauration
docker exec -i newsletter-postgres psql -U postgres newsletter_kcs < backup.sql
```

## 🔍 Dépannage

### **Problèmes Courants :**

#### **1. Port déjà utilisé :**
```bash
# Vérifier les ports occupés
netstat -tulpn | grep :3001

# Modifier les ports dans docker-compose.yml
ports:
  - "3002:3000"  # Changer 3001 en 3002
```

#### **2. Erreur de build :**
```bash
# Nettoyer et reconstruire
docker-compose down
docker system prune -f
docker-compose up --build
```

#### **3. Base de données non accessible :**
```bash
# Vérifier l'état de PostgreSQL
docker-compose logs postgres

# Redémarrer uniquement PostgreSQL
docker-compose restart postgres
```

#### **4. Application ne démarre pas :**
```bash
# Voir les logs de l'application
docker-compose logs app

# Vérifier la santé
curl http://localhost:3001/api/health
```

### **Logs et Monitoring :**
```bash
# Logs en temps réel
docker-compose logs -f app

# Logs spécifiques
docker-compose logs postgres
docker-compose logs pgadmin
docker-compose logs mailhog

# Statistiques des containers
docker stats
```

## 🏗️ Architecture Docker

```
newsletter-kcs/
├── docker-compose.yml      # Configuration des services
├── app/
│   ├── Dockerfile         # Image de l'application
│   ├── .dockerignore      # Fichiers exclus du build
│   └── ...               # Code source Next.js
├── database/
│   └── init-db.sql       # Script d'initialisation DB
├── .env.docker           # Template d'environnement
└── start-docker.sh       # Script de démarrage
```

## 🔒 Sécurité

### **Recommandations :**
- 🔑 **Changez les mots de passe** par défaut en production
- 🌐 **Utilisez HTTPS** en production
- 🔥 **Configurez un firewall** approprié
- 📝 **Sauvegardez régulièrement** la base de données

### **Variables Sensibles :**
- ⚠️ **Ne commitez jamais** le fichier `.env` avec de vraies clés
- 🔐 **Utilisez des secrets** Docker en production
- 🛡️ **Limitez l'accès** aux ports de base de données

## 📚 Ressources

- 📖 **Documentation Docker** : https://docs.docker.com/
- 🐳 **Docker Compose** : https://docs.docker.com/compose/
- ⚡ **Next.js Docker** : https://nextjs.org/docs/deployment#docker-image
- 🐘 **PostgreSQL Docker** : https://hub.docker.com/_/postgres

---

## 🆘 Support

En cas de problème :
1. 📋 Vérifiez les logs : `docker-compose logs`
2. 🔍 Consultez la section dépannage ci-dessus
3. 🐛 Ouvrez une issue sur GitHub avec les logs d'erreur

**🎉 Bon développement avec Docker !**
