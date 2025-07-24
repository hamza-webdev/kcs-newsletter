# Installation Supabase Local avec Docker

Ce guide vous explique comment installer et configurer Supabase localement avec Docker pour l'application Newsletter KCS.

## 🚀 Installation Rapide

### 1. Prérequis

- **Docker Desktop** installé et en cours d'exécution
- **Docker Compose** (inclus avec Docker Desktop)
- **Git** pour cloner le projet

### 2. Démarrage de Supabase

#### Sur Windows (PowerShell)
```powershell
.\start-supabase.ps1
```

#### Sur Linux/Mac (Bash)
```bash
chmod +x start-supabase.sh
./start-supabase.sh
```

#### Ou manuellement
```bash
docker-compose up -d
```

### 3. Vérification de l'installation

Après le démarrage, vérifiez que tous les services sont actifs :

```bash
docker-compose ps
```

Vous devriez voir tous les services en état "Up".

## 🔗 Services Disponibles

Une fois Supabase démarré, vous aurez accès à :

| Service | URL | Description |
|---------|-----|-------------|
| **Supabase Studio** | http://localhost:3000 | Interface d'administration |
| **API REST** | http://localhost:8000/rest/v1/ | API PostgREST |
| **Auth API** | http://localhost:8000/auth/v1/ | API d'authentification |
| **MailHog** | http://localhost:8025 | Interface emails de test |
| **PostgreSQL** | localhost:5432 | Base de données |

## 🔑 Clés d'API

Les clés suivantes sont configurées pour l'environnement local :

```env
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0

SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
```

## 🗄️ Base de Données

### Structure

La base de données est automatiquement initialisée avec :

- **newsletters** : Stockage des newsletters
- **newsletter_sections** : Sections de chaque newsletter
- **contacts** : Messages de contact et feedback
- **subscribers** : Liste des abonnés

### Données de test

Des données de test sont automatiquement insérées :
- 2 newsletters d'exemple
- Quelques sections de newsletter
- Des abonnés de test

### Connexion directe

Pour vous connecter directement à PostgreSQL :

```bash
# Avec psql
psql -h localhost -p 5432 -U postgres -d newsletter_kcs

# Avec un client GUI
Host: localhost
Port: 5432
Database: newsletter_kcs
Username: postgres
Password: postgres123
```

## 🚀 Démarrage de l'Application

Une fois Supabase démarré :

```bash
cd app
npm run dev
```

L'application sera disponible sur http://localhost:3001

## 🔐 Authentification

### Créer un utilisateur administrateur

1. Allez sur http://localhost:3001/admin-supabase
2. Cliquez sur "Créer un utilisateur de test"
3. Connectez-vous avec :
   - Email: `admin@assokcs.org`
   - Mot de passe: `admin123`

### Via Supabase Studio

1. Ouvrez http://localhost:3000
2. Allez dans "Authentication" > "Users"
3. Cliquez sur "Add user"
4. Remplissez les informations

## 📧 Emails de Test

Les emails sont capturés par MailHog :

1. Ouvrez http://localhost:8025
2. Tous les emails envoyés par l'application apparaîtront ici
3. Parfait pour tester les fonctionnalités d'inscription et de notification

## 🛠️ Commandes Utiles

### Gestion des containers

```bash
# Démarrer tous les services
docker-compose up -d

# Arrêter tous les services
docker-compose down

# Voir les logs
docker-compose logs -f

# Redémarrer un service spécifique
docker-compose restart postgres

# Voir l'état des services
docker-compose ps
```

### Gestion des données

```bash
# Supprimer toutes les données (reset complet)
docker-compose down -v
docker volume prune -f

# Sauvegarder la base de données
docker exec newsletter-postgres pg_dump -U postgres newsletter_kcs > backup.sql

# Restaurer la base de données
docker exec -i newsletter-postgres psql -U postgres newsletter_kcs < backup.sql
```

## 🐛 Résolution de Problèmes

### Port déjà utilisé

Si un port est déjà utilisé, modifiez le `docker-compose.yml` :

```yaml
ports:
  - "3001:3000"  # Au lieu de 3000:3000
```

### Services qui ne démarrent pas

1. Vérifiez que Docker Desktop est en cours d'exécution
2. Vérifiez les logs : `docker-compose logs`
3. Redémarrez les services : `docker-compose restart`

### Problèmes de connexion

1. Vérifiez que les variables d'environnement sont correctes dans `app/.env.local`
2. Vérifiez que l'URL Supabase est `http://localhost:8000`
3. Redémarrez l'application Next.js

### Base de données vide

Si la base de données n'a pas été initialisée :

```bash
# Recréer les containers avec les volumes
docker-compose down -v
docker-compose up -d
```

## 🔄 Mise à Jour

Pour mettre à jour Supabase :

```bash
# Arrêter les services
docker-compose down

# Mettre à jour les images
docker-compose pull

# Redémarrer
docker-compose up -d
```

## 📊 Monitoring

### Logs en temps réel

```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker-compose logs -f postgres
docker-compose logs -f auth
```

### Métriques

- **Supabase Studio** : Tableau de bord avec métriques
- **Docker Stats** : `docker stats` pour voir l'utilisation des ressources

## 🎯 Prochaines Étapes

Une fois Supabase configuré :

1. ✅ Testez la connexion sur http://localhost:3001/admin-supabase
2. ✅ Créez un utilisateur administrateur
3. ✅ Explorez l'interface Supabase Studio
4. 🔄 Développez les fonctionnalités manquantes
5. 🔄 Configurez l'envoi d'emails réels

---

**Supabase local est maintenant prêt ! 🎉**

Pour toute question, consultez la [documentation officielle Supabase](https://supabase.com/docs) ou ouvrez une issue.
