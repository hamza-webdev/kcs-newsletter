# Newsletter KCS - Configuration Supabase/PostgreSQL

## 🎉 Installation Réussie !

L'application Newsletter KCS a été configurée avec succès pour utiliser PostgreSQL via Docker. Voici un résumé de ce qui a été mis en place :

## 🚀 Ce qui a été installé

### 1. Base de données PostgreSQL
- **Container Docker** : `newsletter-postgres`
- **Port** : 5433 (localhost:5433)
- **Base de données** : `newsletter_kcs`
- **Utilisateur** : `postgres`
- **Mot de passe** : `postgres123`

### 2. MailHog (Serveur email de test)
- **Container Docker** : `newsletter-mailhog`
- **Interface Web** : http://localhost:8026
- **Port SMTP** : 1026

### 3. Structure de la base de données
Les tables suivantes ont été créées automatiquement :
- `newsletters` - Stockage des newsletters
- `newsletter_sections` - Sections de chaque newsletter
- `contacts` - Messages de contact et feedback
- `subscribers` - Liste des abonnés
- `auth_users` - Authentification simple

### 4. Données de test
Des données d'exemple ont été insérées :
- 2 newsletters de démonstration
- Sections de newsletter avec contenu
- Abonnés de test
- Utilisateur admin de test

## 🔗 URLs disponibles

| Service | URL | Description |
|---------|-----|-------------|
| **Application** | http://localhost:3001 | Site principal |
| **Admin PostgreSQL** | http://localhost:3001/admin-postgres | Interface d'administration |
| **Admin Démo** | http://localhost:3001/admin-demo | Version démo (données statiques) |
| **MailHog** | http://localhost:8026 | Interface emails de test |

## 🛠️ Commandes utiles

### Gestion Docker
```bash
# Démarrer les services
docker-compose -f docker-compose-simple.yml up -d

# Arrêter les services
docker-compose -f docker-compose-simple.yml down

# Voir l'état des services
docker-compose -f docker-compose-simple.yml ps

# Voir les logs
docker-compose -f docker-compose-simple.yml logs -f
```

### Connexion directe à PostgreSQL
```bash
# Avec psql
psql -h localhost -p 5433 -U postgres -d newsletter_kcs

# Ou avec un client GUI
Host: localhost
Port: 5433
Database: newsletter_kcs
Username: postgres
Password: postgres123
```

## 📊 Fonctionnalités disponibles

### ✅ Fonctionnalités implémentées
- [x] Interface d'administration fonctionnelle
- [x] Connexion à PostgreSQL
- [x] Affichage des newsletters depuis la base de données
- [x] Statistiques en temps réel
- [x] Gestion des emails de test avec MailHog
- [x] Structure de base de données complète
- [x] Données de test pré-chargées

### 🔄 Prochaines étapes possibles
- [ ] Authentification complète
- [ ] CRUD complet pour les newsletters
- [ ] Éditeur de newsletter avancé
- [ ] Système d'envoi d'emails réels
- [ ] Import/export des abonnés
- [ ] Statistiques avancées
- [ ] API REST complète

## 🔧 Configuration

### Variables d'environnement (app/.env.local)
```env
# Database Configuration
DB_HOST=localhost
DB_PORT=5433
DB_NAME=newsletter_kcs
DB_USER=postgres
DB_PASSWORD=postgres123

# Email Configuration (MailHog)
SMTP_HOST=localhost
SMTP_PORT=1026
SMTP_FROM=newsletter@assokcs.org

# Application
NEXT_PUBLIC_APP_URL=http://localhost:3001
```

## 🎯 Test de l'installation

1. **Vérifiez que Docker fonctionne** :
   ```bash
   docker-compose -f docker-compose-simple.yml ps
   ```

2. **Testez l'application** :
   - Ouvrez http://localhost:3001
   - Cliquez sur "PostgreSQL" dans le header
   - Vérifiez que les données s'affichent

3. **Testez MailHog** :
   - Ouvrez http://localhost:8026
   - Interface d'emails de test disponible

## 🐛 Résolution de problèmes

### Ports déjà utilisés
Si vous avez des conflits de ports, modifiez dans `docker-compose-simple.yml` :
```yaml
ports:
  - "5434:5432"  # PostgreSQL
  - "1027:1025"  # MailHog SMTP
  - "8027:8025"  # MailHog Web
```

### Base de données vide
Si les données ne s'affichent pas :
```bash
# Recréer les containers
docker-compose -f docker-compose-simple.yml down -v
docker-compose -f docker-compose-simple.yml up -d
```

### Problèmes de connexion
1. Vérifiez que les containers sont en cours d'exécution
2. Vérifiez les variables d'environnement dans `.env.local`
3. Redémarrez l'application Next.js

## 📝 Notes techniques

- **Architecture** : Next.js + PostgreSQL + Docker
- **ORM** : Connexion directe avec le driver `pg`
- **Authentification** : Système simple pour la démo
- **Emails** : MailHog pour les tests locaux
- **Données** : Initialisées automatiquement via `init-db-simple.sql`

---

**🎉 L'installation est terminée ! Vous pouvez maintenant développer les fonctionnalités manquantes.**

Pour toute question ou problème, consultez les logs Docker ou ouvrez une issue.
