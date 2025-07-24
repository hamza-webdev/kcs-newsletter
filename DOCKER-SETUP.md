# 🐳 Configuration Docker - Newsletter KCS

## 📋 Services Disponibles

Le fichier `docker-compose.yml` a été simplifié pour inclure seulement les services essentiels :

### **1. PostgreSQL Database**
- **Image** : `postgres:15`
- **Port** : `5433:5432` (externe:interne)
- **Base de données** : `newsletter_kcs`
- **Utilisateur** : `postgres`
- **Mot de passe** : `postgres123`

### **2. pgAdmin (Interface d'administration)**
- **Image** : `dpage/pgadmin4:latest`
- **Port** : `5050:80`
- **Email** : `admin@newsletter-kcs.local`
- **Mot de passe** : `admin123`
- **URL** : http://localhost:5050

### **3. MailHog (Test d'emails)**
- **Image** : `mailhog/mailhog:v1.0.1`
- **SMTP Port** : `1025`
- **Web UI Port** : `8025`
- **URL** : http://localhost:8025

## 🚀 Démarrage

### **1. Démarrer tous les services :**
```bash
docker-compose up -d
```

### **2. Vérifier le statut :**
```bash
docker-compose ps
```

### **3. Voir les logs :**
```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker-compose logs -f postgres
docker-compose logs -f pgadmin
```

## 🔧 Configuration

### **Variables d'environnement (.env.local) :**
```bash
# PostgreSQL Configuration
DB_HOST=localhost
DB_PORT=5433
DB_NAME=newsletter_kcs
DB_USER=postgres
DB_PASSWORD=postgres123

# OpenAI Configuration
OPENAI_API_KEY=your-openai-api-key-here
```

### **Connexion PostgreSQL :**
```bash
# Via psql
psql -h localhost -p 5433 -U postgres -d newsletter_kcs

# Via application Node.js
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'newsletter_kcs',
  password: 'postgres123',
  port: 5433,
})
```

## 🗄️ Base de Données

### **Initialisation Automatique :**
- Le fichier `database/init-db.sql` est exécuté automatiquement
- Création de la table `newsletters` avec structure complète
- Index et triggers configurés
- Données de test insérées

### **Structure Table newsletters :**
```sql
CREATE TABLE newsletters (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title character varying NOT NULL,
    description text,
    image_ia_url character varying(500),
    image_ia_filename character varying(255),
    image_upload_url character varying(500),
    image_upload_filename character varying(255),
    prompt_ia text,
    statut character varying(50) DEFAULT 'brouillon',
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    published_at timestamp with time zone,
    is_published boolean DEFAULT false,
    created_by uuid
);
```

## 🔍 Administration

### **pgAdmin (Interface Web) :**
1. **Accéder** : http://localhost:5050
2. **Se connecter** :
   - Email : `admin@newsletter-kcs.local`
   - Mot de passe : `admin123`
3. **Ajouter serveur** :
   - Nom : `Newsletter PostgreSQL`
   - Host : `postgres` (nom du container)
   - Port : `5432` (port interne)
   - Database : `newsletter_kcs`
   - Username : `postgres`
   - Password : `postgres123`

### **MailHog (Test d'emails) :**
1. **Interface Web** : http://localhost:8025
2. **Configuration SMTP** :
   - Host : `localhost`
   - Port : `1025`
   - Pas d'authentification

## 🛠️ Commandes Utiles

### **Gestion des services :**
```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Redémarrer un service
docker-compose restart postgres

# Reconstruire les images
docker-compose up -d --build
```

### **Gestion des données :**
```bash
# Sauvegarder la base de données
docker exec newsletter-postgres pg_dump -U postgres newsletter_kcs > backup.sql

# Restaurer la base de données
docker exec -i newsletter-postgres psql -U postgres newsletter_kcs < backup.sql

# Accéder au container PostgreSQL
docker exec -it newsletter-postgres psql -U postgres -d newsletter_kcs
```

### **Nettoyage :**
```bash
# Arrêter et supprimer les containers
docker-compose down

# Supprimer aussi les volumes (⚠️ PERTE DE DONNÉES)
docker-compose down -v

# Nettoyer les images inutilisées
docker system prune
```

## 🔄 Migration depuis Supabase

### **Changements effectués :**
- ✅ **Supprimé** : Supabase Studio, Kong, PostgREST, GoTrue, Realtime
- ✅ **Conservé** : PostgreSQL, MailHog
- ✅ **Ajouté** : pgAdmin pour l'administration
- ✅ **Simplifié** : Configuration minimale et fonctionnelle

### **Avantages :**
- **Plus simple** : Moins de services à gérer
- **Plus léger** : Moins de ressources utilisées
- **Plus direct** : Connexion directe à PostgreSQL
- **Plus flexible** : Pas de contraintes Supabase

## 📊 Monitoring

### **Vérification de santé :**
```bash
# Status des containers
docker-compose ps

# Logs en temps réel
docker-compose logs -f

# Utilisation des ressources
docker stats
```

### **Tests de connexion :**
```bash
# Test PostgreSQL
docker exec newsletter-postgres pg_isready -U postgres -d newsletter_kcs

# Test depuis l'application
npm run check-db
```

## 🚨 Dépannage

### **Problèmes courants :**

#### **Port 5433 déjà utilisé :**
```bash
# Changer le port dans docker-compose.yml
ports:
  - "5434:5432"  # Utiliser 5434 au lieu de 5433
```

#### **Problème de permissions :**
```bash
# Recréer les volumes
docker-compose down -v
docker-compose up -d
```

#### **Base de données non initialisée :**
```bash
# Vérifier les logs
docker-compose logs postgres

# Réinitialiser
docker-compose down -v
docker-compose up -d
```

---

## 🎉 **Configuration Docker Simplifiée !**

Le setup Docker est maintenant :
- ✅ **Simplifié** : Seulement PostgreSQL + pgAdmin + MailHog
- ✅ **Fonctionnel** : Prêt pour le développement
- ✅ **Documenté** : Guide complet d'utilisation
- ✅ **Automatisé** : Initialisation de base automatique

**🔗 Démarrage rapide :**
```bash
docker-compose up -d
```

**🔗 Interfaces disponibles :**
- **pgAdmin** : http://localhost:5050
- **MailHog** : http://localhost:8025
- **Application** : http://localhost:3001

---

*Configuration Docker optimisée pour Newsletter KCS* ✨
