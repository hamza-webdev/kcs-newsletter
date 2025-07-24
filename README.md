# Newsletter KCS - Application Web

Une application web responsive de newsletter professionnelle pour l'association KCS (assokcs.org), développée avec Next.js, Tailwind CSS et Supabase.

## 🎨 Design & Fonctionnalités

L'application respecte fidèlement le design présenté dans l'image "Newsletter KCS.png" avec :

- **Design responsive** adapté aux formats mobile, tablette et desktop
- **6 sections structurées** comme dans le design original :
  - 📅 **Évènements à venir** → Formations, entretiens, recrutements
  - 📰 **Quoi de neuf ?** → Veille et sujets documentés par KCS
  - 🏢 **En ce moment chez KCS** → Actualités, articles, interviews
  - ❤️ **Restez solidaires** → Questions et appels à l'action
  - 💬 **Vos retours sont précieux** → Feedback utilisateur + formulaire de contact
  - 📧 **Contact** → Informations et liens utiles

## 🚀 Stack Technique

- **Frontend** : Next.js 15 avec App Router
- **Styling** : Tailwind CSS
- **Base de données** : Supabase (PostgreSQL)
- **Authentification** : Supabase Auth
- **Envoi d'emails** : Resend API
- **Icons** : Lucide React
- **Formulaires** : React Hook Form + Zod
- **Dates** : date-fns

## 📁 Structure du Projet

```
app/
├── src/
│   ├── app/                    # Pages Next.js (App Router)
│   │   ├── page.tsx           # Page d'accueil
│   │   ├── newsletters/       # Archives des newsletters
│   │   ├── subscribe/         # Page d'abonnement
│   │   ├── contact/           # Page de contact
│   │   └── admin/             # Dashboard d'administration
│   ├── components/            # Composants réutilisables
│   │   ├── ui/               # Composants UI de base
│   │   ├── newsletter/       # Composants spécifiques aux newsletters
│   │   └── auth/             # Composants d'authentification
│   └── lib/                  # Utilitaires et configuration
├── supabase/                 # Schéma de base de données
└── public/                   # Assets statiques
```

## 🛠️ Installation et Configuration

### 1. Cloner le projet

```bash
git clone <repository-url>
cd newsletter-kcs-augment/app
```

### 2. Installer les dépendances

```bash
npm install
```

### 3. Configuration des variables d'environnement

Créer un fichier `.env.local` :

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url_here
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key_here

# Email Configuration (Resend)
RESEND_API_KEY=your_resend_api_key_here

# Application Configuration
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 4. Configuration Supabase

1. Créer un projet Supabase
2. Exécuter le script SQL dans `supabase/schema.sql`
3. Configurer les politiques RLS (Row Level Security)

### 5. Lancer l'application

```bash
npm run dev
```

L'application sera accessible sur `http://localhost:3000`

## 📊 Base de Données

### Tables principales

- **newsletters** : Stockage des newsletters
- **newsletter_sections** : Sections de chaque newsletter (6 types)
- **contacts** : Messages de contact et feedback
- **subscribers** : Liste des abonnés

### Types de sections

```typescript
type SectionType = 
  | 'events'        // Évènements à venir
  | 'news'          // Quoi de neuf ?
  | 'kcs_updates'   // En ce moment chez KCS
  | 'solidarity'    // Restez solidaires
  | 'feedback'      // Vos retours sont précieux
  | 'contact'       // Contact
```

## 🔐 Authentification

L'accès au dashboard d'administration est protégé par Supabase Auth :

- **Route publique** : `/admin/login`
- **Routes protégées** : `/admin/*`
- **Déconnexion automatique** en cas de session expirée

## 📧 Gestion des Emails

### Abonnement
- Formulaire d'inscription avec validation
- Stockage sécurisé des emails
- Confirmation d'abonnement

### Envoi de newsletters
- Interface d'administration pour composer
- Prévisualisation avant envoi
- Statistiques d'ouverture et de clic

## 🎯 Fonctionnalités Principales

### Front-office Public
- ✅ Page d'accueil avec présentation des sections
- ✅ Archives des newsletters avec pagination
- ✅ Formulaire d'abonnement
- ✅ Page de contact avec formulaire
- ✅ Design responsive et accessible

### Dashboard d'Administration
- ✅ Authentification sécurisée
- ✅ Vue d'ensemble avec statistiques
- ✅ Gestion des newsletters (CRUD)
- ✅ Éditeur de sections
- 🔄 Envoi d'emails (en cours)
- 🔄 Gestion des abonnés (en cours)

## 🚧 Prochaines Étapes

1. **Finaliser l'éditeur de contenu** pour les 6 sections
2. **Implémenter l'envoi d'emails** via Resend
3. **Ajouter la gestion des abonnés** (import CSV, export)
4. **Créer les statistiques avancées** (taux d'ouverture, clics)
5. **Optimiser les performances** et SEO
6. **Tests et déploiement**

## 🤝 Contribution

Ce projet est développé pour l'association KCS. Pour contribuer :

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est développé pour l'association KCS. Tous droits réservés.

## 📞 Support

Pour toute question ou support :
- Email : contact@assokcs.org
- Site web : https://assokcs.org

---

**Développé avec ❤️ pour l'association KCS**
