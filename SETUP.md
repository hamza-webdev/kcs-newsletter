# Configuration de l'Application Newsletter KCS

## 🚀 Démarrage Rapide

L'application fonctionne actuellement en mode démo. Vous pouvez :

1. **Naviguer sur l'interface publique** : http://localhost:3001
2. **Voir le dashboard de démo** : http://localhost:3001/admin-demo
3. **Tester toutes les pages** sans configuration

## 🔧 Configuration Complète avec Supabase

Pour activer toutes les fonctionnalités (authentification, base de données, etc.) :

### 1. Créer un projet Supabase

1. Allez sur [supabase.com](https://supabase.com)
2. Créez un nouveau projet
3. Notez l'URL et la clé anonyme de votre projet

### 2. Configurer les variables d'environnement

Modifiez le fichier `app/.env.local` :

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://votre-projet.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=votre_cle_anonyme_ici
SUPABASE_SERVICE_ROLE_KEY=votre_cle_service_role_ici

# Email Configuration (Resend)
RESEND_API_KEY=votre_cle_resend_ici

# Application Configuration
NEXT_PUBLIC_APP_URL=http://localhost:3001
```

### 3. Configurer la base de données

1. Dans votre projet Supabase, allez dans l'éditeur SQL
2. Copiez et exécutez le contenu du fichier `app/supabase/schema.sql`
3. Cela créera toutes les tables nécessaires avec les bonnes permissions

### 4. Configurer l'authentification

1. Dans Supabase, allez dans Authentication > Settings
2. Configurez les URLs autorisées :
   - Site URL: `http://localhost:3001`
   - Redirect URLs: `http://localhost:3001/admin`

### 5. Configurer l'envoi d'emails (optionnel)

1. Créez un compte sur [resend.com](https://resend.com)
2. Obtenez votre clé API
3. Ajoutez-la dans `.env.local`

## 🎯 Fonctionnalités Disponibles

### ✅ Actuellement fonctionnelles (mode démo)
- Page d'accueil avec design KCS
- Archives des newsletters
- Formulaire d'abonnement (interface)
- Page de contact (interface)
- Dashboard d'administration (démo)

### 🔄 Nécessitent la configuration Supabase
- Authentification réelle
- Sauvegarde des données
- Envoi d'emails
- Gestion des abonnés
- Création/édition de newsletters

## 🛠️ Commandes Utiles

```bash
# Démarrer l'application
npm run dev

# Build pour production
npm run build

# Lancer en production
npm start

# Linter
npm run lint
```

## 📁 Structure des Fichiers Importants

```
app/
├── .env.local                 # Variables d'environnement
├── src/
│   ├── app/
│   │   ├── page.tsx          # Page d'accueil
│   │   ├── admin-demo/       # Dashboard de démo
│   │   ├── admin/            # Dashboard réel (nécessite Supabase)
│   │   ├── newsletters/      # Archives
│   │   ├── subscribe/        # Abonnement
│   │   └── contact/          # Contact
│   ├── components/
│   │   ├── ui/              # Composants UI de base
│   │   ├── newsletter/      # Composants newsletters
│   │   └── auth/            # Authentification
│   └── lib/
│       ├── supabase.ts      # Client Supabase
│       └── supabase-server.ts # Server Supabase
└── supabase/
    └── schema.sql           # Schéma de base de données
```

## 🎨 Personnalisation

### Couleurs et Design
Les couleurs principales sont définies dans Tailwind CSS :
- Rose/Pink : `pink-500`, `pink-600`, etc.
- Couleurs des sections : `blue-50`, `green-50`, etc.

### Contenu
- Modifiez les textes dans les composants React
- Les données de démo sont dans les fichiers de pages
- Les types TypeScript sont dans `src/lib/supabase.ts`

## 🐛 Résolution de Problèmes

### Erreur "Invalid URL"
- Vérifiez que les variables Supabase sont correctement configurées dans `.env.local`

### Erreur d'authentification
- Vérifiez les URLs autorisées dans Supabase
- Assurez-vous que les clés API sont correctes

### Problèmes de build
- Supprimez `.next` et `node_modules`, puis réinstallez : `rm -rf .next node_modules && npm install`

## 📞 Support

Pour toute question :
- Consultez la documentation Next.js : https://nextjs.org/docs
- Documentation Supabase : https://supabase.com/docs
- Documentation Tailwind CSS : https://tailwindcss.com/docs

---

**L'application est prête à être utilisée en mode démo !** 🎉
