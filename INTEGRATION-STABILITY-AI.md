# 🤖 Intégration Stability AI - Génération d'Images

## 🚀 Vue d'Ensemble

L'API Stability AI est maintenant intégrée pour générer des images de newsletter basées uniquement sur le **titre** de la newsletter.

## 🔧 Configuration Technique

### **API Endpoint Utilisé :**
```
POST https://api.stability.ai/v1/generation/stable-diffusion-v1-5/text-to-image
```

### **Clé API :**
```
Authorization: sk-ysnUMVE05PCwnB4cYCE8b0yuiHqifS3PG0iVafdYCoWcvMOM
```

### **Paramètres de Génération :**
```javascript
{
  text_prompts: [{ text: prompt }],
  cfg_scale: 7,        // Guidance scale (7 = équilibré)
  height: 512,         // Hauteur en pixels
  width: 512,          // Largeur en pixels
  samples: 1,          // Nombre d'images à générer
  steps: 30            // Nombre d'étapes de diffusion
}
```

## 📋 Fonctionnement Détaillé

### **1. Création du Prompt**
```javascript
const prompt = `Professional newsletter header design for "${titre}", modern layout, clean typography, corporate style, business newsletter, professional colors, high quality`
```

**Exemple :**
- **Titre :** "Newsletter KCS - Janvier 2024"
- **Prompt généré :** "Professional newsletter header design for 'Newsletter KCS - Janvier 2024', modern layout, clean typography, corporate style, business newsletter, professional colors, high quality"

### **2. Appel API Stability AI**
```javascript
const response = await axios.post(
  'https://api.stability.ai/v1/generation/stable-diffusion-v1-5/text-to-image',
  {
    text_prompts: [{ text: prompt }],
    cfg_scale: 7,
    height: 512,
    width: 512,
    samples: 1,
    steps: 30
  },
  {
    headers: {
      'Authorization': 'sk-ysnUMVE05PCwnB4cYCE8b0yuiHqifS3PG0iVafdYCoWcvMOM',
      'Content-Type': 'application/json'
    },
    responseType: 'arraybuffer'  // Important pour recevoir l'image
  }
)
```

### **3. Sauvegarde de l'Image**
```javascript
// Créer le dossier uploads
const uploadsDir = path.join(process.cwd(), 'public', 'uploads')
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true })
}

// Générer nom unique
const timestamp = Date.now()
const filename = `newsletter-${timestamp}.png`
const filepath = path.join(uploadsDir, filename)

// Sauvegarder
const imageBuffer = Buffer.from(response.data)
fs.writeFileSync(filepath, imageBuffer)

// URL publique
const imageUrl = `/uploads/${filename}`
```

### **4. Réponse API**
```javascript
return NextResponse.json({
  success: true,
  imageUrl: imageUrl,        // URL publique de l'image
  prompt: prompt,            // Prompt utilisé
  filename: filename         // Nom du fichier
})
```

## 🎯 Flux Complet

```mermaid
graph TD
    A[Utilisateur saisit titre] --> B[Clique "Générer avec IA"]
    B --> C[Validation: titre présent?]
    C -->|Non| D[Afficher erreur]
    C -->|Oui| E[Créer prompt professionnel]
    E --> F[Appel API Stability AI]
    F --> G[Recevoir image en arraybuffer]
    G --> H[Créer dossier uploads si nécessaire]
    H --> I[Générer nom fichier unique]
    I --> J[Sauvegarder image sur disque]
    J --> K[Retourner URL publique]
    K --> L[Afficher image dans interface]
```

## 🔍 Gestion des Erreurs

### **Types d'Erreurs Gérées :**

#### **1. Erreurs de Validation :**
```javascript
if (!titre) {
  return NextResponse.json(
    { error: 'Titre requis' },
    { status: 400 }
  )
}
```

#### **2. Erreurs API Stability AI :**
```javascript
if (axios.isAxiosError(error)) {
  const status = error.response?.status
  const message = error.response?.data?.message || error.message
  
  return NextResponse.json(
    { 
      error: `Erreur API Stability AI (${status}): ${message}`,
      details: error.response?.data
    },
    { status: status || 500 }
  )
}
```

#### **3. Erreurs Système :**
```javascript
return NextResponse.json(
  { error: 'Erreur lors de la génération de l\'image' },
  { status: 500 }
)
```

## 📁 Structure des Fichiers

### **Dossier de Stockage :**
```
public/
└── uploads/
    ├── newsletter-1642784523000.png
    ├── newsletter-1642784567000.png
    └── ...
```

### **Nommage des Fichiers :**
```javascript
const filename = `newsletter-${timestamp}.png`
// Exemple: newsletter-1642784523000.png
```

## 🎨 Optimisation du Prompt

### **Structure du Prompt :**
```
"Professional newsletter header design for '[TITRE]', modern layout, clean typography, corporate style, business newsletter, professional colors, high quality"
```

### **Mots-clés Importants :**
- **Professional** : Style professionnel
- **Newsletter header** : Type d'image spécifique
- **Modern layout** : Design contemporain
- **Clean typography** : Typographie épurée
- **Corporate style** : Style d'entreprise
- **Business newsletter** : Contexte business
- **Professional colors** : Couleurs professionnelles
- **High quality** : Haute qualité

## ⚙️ Paramètres Stability AI

### **cfg_scale: 7**
- **Rôle :** Contrôle l'adhérence au prompt
- **Valeurs :** 1-20
- **7 :** Équilibre entre créativité et fidélité

### **steps: 30**
- **Rôle :** Nombre d'étapes de diffusion
- **Valeurs :** 10-150
- **30 :** Bon compromis qualité/vitesse

### **size: 512x512**
- **Rôle :** Dimensions de l'image
- **Options :** 512x512, 768x768, 1024x1024
- **512x512 :** Rapide et économique

## 🔄 Interface Utilisateur

### **Modifications Apportées :**

#### **1. Validation Simplifiée :**
```javascript
// Avant: titre ET contenu requis
if (!formData.titre || !formData.contenu) { ... }

// Après: seul le titre requis
if (!formData.titre) { ... }
```

#### **2. Message d'Aide :**
```javascript
// Nouveau message
'Remplissez le titre pour générer une image avec Stability AI'
```

#### **3. Logs de Debug :**
```javascript
console.log('Génération image pour:', formData.titre)
console.log('Prompt:', prompt)
console.log('Image générée avec succès:', data.imageUrl)
```

## 💰 Coûts et Limites

### **Coûts Stability AI :**
- **Stable Diffusion v1.5 :** ~$0.002 par image
- **512x512 pixels :** Tarif de base
- **30 steps :** Coût standard

### **Limites Techniques :**
- **Taille max :** 1024x1024 pixels
- **Rate limit :** Selon votre plan
- **Formats :** PNG uniquement

## 🚀 Améliorations Possibles

### **1. Paramètres Configurables :**
```javascript
const [aiSettings, setAiSettings] = useState({
  style: 'professional',
  size: '512x512',
  steps: 30,
  cfg_scale: 7
})
```

### **2. Styles Prédéfinis :**
```javascript
const styles = {
  professional: "corporate style, business newsletter, professional colors",
  creative: "creative design, vibrant colors, artistic layout",
  minimal: "minimalist design, clean lines, simple typography"
}
```

### **3. Historique des Générations :**
```javascript
const [imageHistory, setImageHistory] = useState([])
```

---

## 🎉 **Intégration Réussie !**

L'API Stability AI est maintenant intégrée avec :
- ✅ **Génération basée sur titre** uniquement
- ✅ **Sauvegarde automatique** des images
- ✅ **Gestion d'erreurs** complète
- ✅ **Interface utilisateur** optimisée
- ✅ **Logs de debug** pour monitoring

**🔗 Testez maintenant :**
1. Allez sur http://localhost:3001/admin-postgres/nouvelle-newsletter
2. Saisissez un titre (ex: "Newsletter KCS - Janvier 2024")
3. Cliquez sur "Générer avec IA"
4. Attendez la génération (~10-30 secondes)
5. Visualisez l'image générée !

---

*Intégration Stability AI opérationnelle avec prompts optimisés* ✨
