# 🚀 Guide de Déploiement - Newsletter KCS

## 📋 Informations de Déploiement

### **Configuration VPS :**
- **IP** : `167.86.93.157`
- **Utilisateur** : `vpsadmin`
- **Domaine** : `newslettre.kcs.zidani.org`
- **Répertoire** : `/home/vpsadmin/newslettre`
- **Mot de passe** : `Besmillah2025`

## 🔧 Prérequis

### **1. Configuration DNS :**
Assurez-vous que votre domaine pointe vers votre VPS :
```
A    newslettre.kcs.zidani.org    167.86.93.157
```

### **2. Accès SSH :**
Testez la connexion SSH :
```bash
ssh vpsadmin@167.86.93.157
```

### **3. Clé OpenAI :**
Préparez votre clé API OpenAI pour la configuration.

## 🚀 Déploiement Automatique

### **Étape 1 : Préparation du Serveur**
```bash
# Rendre le script exécutable
chmod +x setup-server.sh

# Configurer le serveur (Docker, Nginx, SSL)
./setup-server.sh
```

### **Étape 2 : Déploiement de l'Application**
```bash
# Rendre le script exécutable
chmod +x deploy.sh

# Déployer l'application
./deploy.sh
```

## 📦 Fichiers Déployés

### **Structure sur le VPS :**
```
/home/vpsadmin/newslettre/
├── src/                          # Code source Next.js
├── public/                       # Fichiers statiques
│   └── uploads/                  # Images uploadées
├── database/                     # Scripts de base de données
│   └── init-db.sql
├── package.json                  # Dépendances Node.js
├── docker-compose.prod.yml       # Configuration Docker production
├── Dockerfile                    # Image Docker de l'app
├── .env.local                    # Variables d'environnement
├── next.config.ts               # Configuration Next.js
├── middleware.ts                # Middleware Next.js
└── tailwind.config.ts           # Configuration Tailwind
```

### **Services Docker :**
- **newslettre-postgres** : Base de données PostgreSQL (port 5433)
- **newslettre-app** : Application Next.js (port 3001)
- **newslettre-pgadmin** : Interface d'administration (port 5050)

## 🌐 Configuration Nginx

### **Fichier de Configuration :**
```nginx
# /etc/nginx/sites-available/newslettre.kcs.zidani.org
server {
    listen 80;
    listen 443 ssl http2;
    server_name newslettre.kcs.zidani.org;

    # Certificat SSL (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/newslettre.kcs.zidani.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/newslettre.kcs.zidani.org/privkey.pem;

    # Proxy vers l'application
    location / {
        proxy_pass http://localhost:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # pgAdmin
    location /pgadmin/ {
        proxy_pass http://localhost:5050/;
    }

    # Fichiers statiques
    location /uploads/ {
        alias /home/vpsadmin/newslettre/public/uploads/;
        expires 1y;
    }
}
```

## 🔒 Configuration SSL

### **Certificat Let's Encrypt :**
```bash
# Installation automatique via le script setup-server.sh
sudo certbot --nginx -d newslettre.kcs.zidani.org
```

### **Renouvellement Automatique :**
```bash
# Cron job configuré automatiquement
0 12 * * * /usr/bin/certbot renew --quiet
```

## ⚙️ Configuration Post-Déploiement

### **1. Configuration OpenAI :**
```bash
# Se connecter au VPS
ssh vpsadmin@167.86.93.157

# Éditer le fichier .env.local
nano /home/vpsadmin/newslettre/.env.local

# Remplacer la ligne :
OPENAI_API_KEY=your-openai-api-key-here
# Par votre vraie clé :
OPENAI_API_KEY=your-actual-openai-api-key

# Redémarrer l'application
cd /home/vpsadmin/newslettre
docker-compose -f docker-compose.prod.yml restart app
```

### **2. Vérification du Déploiement :**
```bash
# Statut des containers
docker-compose -f docker-compose.prod.yml ps

# Logs de l'application
docker-compose -f docker-compose.prod.yml logs -f app

# Logs PostgreSQL
docker-compose -f docker-compose.prod.yml logs -f postgres
```

## 🔗 Accès aux Services

### **URLs Disponibles :**
- **Application** : https://newslettre.kcs.zidani.org
- **pgAdmin** : https://newslettre.kcs.zidani.org/pgadmin/
- **API** : https://newslettre.kcs.zidani.org/api/newsletters

### **Identifiants pgAdmin :**
- **Email** : `admin@newsletter-kcs.local`
- **Mot de passe** : `admin123`

### **Connexion PostgreSQL (pgAdmin) :**
- **Host** : `newslettre-postgres`
- **Port** : `5432`
- **Database** : `newsletter_kcs`
- **Username** : `postgres`
- **Password** : `postgres123`

## 🛠️ Maintenance

### **Commandes Utiles :**
```bash
# Se connecter au VPS
ssh vpsadmin@167.86.93.157

# Aller dans le répertoire de l'app
cd /home/vpsadmin/newslettre

# Voir les containers
docker-compose -f docker-compose.prod.yml ps

# Redémarrer tous les services
docker-compose -f docker-compose.prod.yml restart

# Voir les logs en temps réel
docker-compose -f docker-compose.prod.yml logs -f

# Mettre à jour l'application
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build

# Sauvegarder la base de données
docker exec newslettre-postgres pg_dump -U postgres newsletter_kcs > backup-$(date +%Y%m%d).sql
```

### **Monitoring :**
```bash
# Espace disque
df -h

# Utilisation mémoire
free -h

# Processus Docker
docker stats

# Logs Nginx
sudo tail -f /var/log/nginx/newslettre.kcs.zidani.org.access.log
sudo tail -f /var/log/nginx/newslettre.kcs.zidani.org.error.log
```

## 🔄 Mise à Jour

### **Pour mettre à jour l'application :**
1. **Modifier le code localement**
2. **Relancer le déploiement** :
   ```bash
   ./deploy.sh
   ```
3. **L'application sera automatiquement reconstruite et redémarrée**

## 🚨 Dépannage

### **Problèmes Courants :**

#### **Application inaccessible :**
```bash
# Vérifier Nginx
sudo systemctl status nginx
sudo nginx -t

# Vérifier les containers
docker-compose -f docker-compose.prod.yml ps

# Redémarrer les services
sudo systemctl restart nginx
docker-compose -f docker-compose.prod.yml restart
```

#### **Base de données inaccessible :**
```bash
# Vérifier PostgreSQL
docker-compose -f docker-compose.prod.yml logs postgres

# Redémarrer PostgreSQL
docker-compose -f docker-compose.prod.yml restart postgres
```

#### **Certificat SSL expiré :**
```bash
# Renouveler manuellement
sudo certbot renew

# Redémarrer Nginx
sudo systemctl reload nginx
```

## 📊 Monitoring et Logs

### **Logs Importants :**
- **Application** : `docker-compose logs app`
- **PostgreSQL** : `docker-compose logs postgres`
- **Nginx** : `/var/log/nginx/newslettre.kcs.zidani.org.*.log`

### **Métriques :**
- **Utilisation Docker** : `docker stats`
- **Espace disque** : `df -h`
- **Mémoire** : `free -h`

---

## 🎉 **Déploiement Prêt !**

Votre application Newsletter KCS sera accessible à :
**https://newslettre.kcs.zidani.org**

### **Fonctionnalités Disponibles :**
- ✅ **Création de newsletters** avec images IA et upload
- ✅ **Base de données PostgreSQL** persistante
- ✅ **Interface d'administration** pgAdmin
- ✅ **SSL automatique** avec Let's Encrypt
- ✅ **Sauvegarde automatique** des données
- ✅ **Monitoring** et logs complets

---

*Déploiement automatisé pour Newsletter KCS* ✨
