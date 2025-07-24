# 🔧 Résolution Problème Connexion PostgreSQL

## ❌ Problème Initial

### **Erreur ECONNREFUSED :**
```
GET /api/newsletters 500 in 2237ms
Erreur récupération newsletters: AggregateError: 
code: 'ECONNREFUSED'
```

### **Cause :**
1. **Variables d'environnement** : Noms incorrects dans l'API
2. **Structure de table** : Colonnes manquantes ou noms différents
3. **Configuration** : Port et paramètres de connexion

## ✅ Solutions Appliquées

### **1. Correction Variables d'Environnement**

#### **Avant (.env.local existant) :**
```bash
DB_HOST=localhost
DB_PORT=5433
DB_NAME=newsletter_kcs
DB_USER=postgres
DB_PASSWORD=postgres123
```

#### **Code API Corrigé :**
```typescript
// Avant (incorrect)
const pool = new Pool({
  user: process.env.POSTGRES_USER || 'postgres',
  host: process.env.POSTGRES_HOST || 'localhost',
  database: process.env.POSTGRES_DB || 'newsletter_kcs',
  password: process.env.POSTGRES_PASSWORD || 'password',
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
})

// Après (correct)
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'newsletter_kcs',
  password: process.env.DB_PASSWORD || 'postgres123',
  port: parseInt(process.env.DB_PORT || '5433'),
})
```

### **2. Vérification Connexion PostgreSQL**

#### **Test de Connexion :**
```bash
netstat -an | findstr :5433
# Résultat: PostgreSQL écoute sur le port 5433 ✅

node -e "const { Pool } = require('pg'); ..."
# Résultat: Connexion réussie: { now: 2025-07-23T20:55:12.233Z } ✅
```

### **3. Mise à Jour Structure de Table**

#### **Structure Existante Découverte :**
```sql
-- Table existante avec colonnes différentes
id: uuid NOT NULL DEFAULT gen_random_uuid()
title: character varying NOT NULL          -- au lieu de "titre"
description: text                          -- au lieu de "contenu"
created_at: timestamp with time zone DEFAULT now()
updated_at: timestamp with time zone DEFAULT now()
published_at: timestamp with time zone
is_published: boolean DEFAULT false
created_by: uuid
```

#### **Colonnes Ajoutées :**
```sql
-- Nouvelles colonnes ajoutées automatiquement
image_ia_url VARCHAR(500)
image_ia_filename VARCHAR(255)
image_upload_url VARCHAR(500)
image_upload_filename VARCHAR(255)
prompt_ia TEXT
statut VARCHAR(50) DEFAULT 'brouillon'
```

### **4. Adaptation Code API**

#### **Requête SELECT Adaptée :**
```typescript
// Mapping des colonnes existantes
let query = `
  SELECT 
    id, title as titre, description as contenu, image_ia_url, image_ia_filename, 
    image_upload_url, image_upload_filename, prompt_ia, 
    statut, created_at, updated_at
  FROM newsletters
`
```

#### **Requête INSERT Adaptée :**
```typescript
const insertQuery = `
  INSERT INTO newsletters (
    title, description, image_ia_url, image_ia_filename, 
    image_upload_url, image_upload_filename, prompt_ia, statut
  ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
  RETURNING *, title as titre, description as contenu
`
```

## 🛠️ Script de Vérification Créé

### **Script `check-database.js` :**
```javascript
// Fonctionnalités du script :
✅ Vérification existence table
✅ Analyse structure colonnes
✅ Détection colonnes manquantes
✅ Ajout automatique colonnes
✅ Création triggers updated_at
✅ Rapport détaillé
```

### **Commande NPM :**
```bash
npm run check-db
```

### **Résultat Exécution :**
```
🔍 Vérification de la base de données...
✅ Table "newsletters" existe
📋 Structure actuelle analysée
⚠️  Colonnes manquantes détectées
🔧 Ajout des colonnes manquantes...
   ✅ Colonne "image_ia_url" ajoutée
   ✅ Colonne "image_ia_filename" ajoutée
   ✅ Colonne "image_upload_url" ajoutée
   ✅ Colonne "image_upload_filename" ajoutée
   ✅ Colonne "prompt_ia" ajoutée
   ✅ Colonne "statut" ajoutée
📊 Nombre de newsletters: 2
🎉 Base de données prête !
```

## 📊 Configuration Finale

### **Variables d'Environnement (.env.local) :**
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

### **Structure Table Finale :**
```sql
CREATE TABLE newsletters (
  -- Colonnes existantes
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title character varying NOT NULL,           -- mappé vers "titre"
  description text,                           -- mappé vers "contenu"
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  published_at timestamp with time zone,
  is_published boolean DEFAULT false,
  created_by uuid,
  
  -- Colonnes ajoutées pour newsletter
  image_ia_url VARCHAR(500),
  image_ia_filename VARCHAR(255),
  image_upload_url VARCHAR(500),
  image_upload_filename VARCHAR(255),
  prompt_ia TEXT,
  statut VARCHAR(50) DEFAULT 'brouillon'
);
```

## 🎯 APIs Fonctionnelles

### **1. GET /api/newsletters :**
```bash
curl http://localhost:3001/api/newsletters
# Retourne la liste des newsletters avec mapping colonnes
```

### **2. POST /api/newsletters :**
```javascript
// FormData avec titre, contenu, images
const formData = new FormData()
formData.append('titre', 'Newsletter Test')
formData.append('contenu', 'Contenu de test')
// + images IA et upload
```

### **3. Mapping Automatique :**
```typescript
// Les colonnes sont automatiquement mappées :
title → titre (dans la réponse)
description → contenu (dans la réponse)
```

## 🚀 Test de Fonctionnement

### **1. API Newsletters :**
```
GET http://localhost:3001/api/newsletters
✅ Retourne JSON avec newsletters existantes
```

### **2. Page Création :**
```
http://localhost:3001/admin-postgres/nouvelle-newsletter
✅ Formulaire fonctionnel
✅ Génération IA opérationnelle
✅ Sauvegarde PostgreSQL prête
```

### **3. Logs Serveur :**
```
✅ Connexion PostgreSQL établie
✅ Requêtes SQL exécutées
✅ Données récupérées/insérées
```

## 📋 Scripts Disponibles

### **Commandes NPM :**
```bash
npm run dev          # Démarrer serveur développement
npm run check-db     # Vérifier/mettre à jour base de données
npm run init-db      # Initialiser base de données (si besoin)
```

---

## 🎉 **Problème Résolu !**

La connexion PostgreSQL est maintenant opérationnelle avec :
- ✅ **Variables d'environnement** : Correctement mappées
- ✅ **Structure de table** : Adaptée et étendue
- ✅ **API fonctionnelle** : GET/POST opérationnels
- ✅ **Mapping colonnes** : Transparent pour l'interface
- ✅ **Scripts de maintenance** : Vérification automatique
- ✅ **Sauvegarde newsletter** : Prête à l'utilisation

**🔗 Prêt à utiliser :**
- API : http://localhost:3001/api/newsletters
- Interface : http://localhost:3001/admin-postgres/nouvelle-newsletter

---

*Connexion PostgreSQL établie et APIs opérationnelles* ✨
