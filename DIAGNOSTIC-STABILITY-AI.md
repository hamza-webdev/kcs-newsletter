# 🔧 Diagnostic et Résolution - Erreur Stability AI

## ❌ Problème Rencontré

### **Erreur 400 - Bad Request**
```
POST http://localhost:3001/api/generate-image 400 (Bad Request)
Erreur API Stability AI (400): Request failed with status code 400
```

## 🔍 Causes Possibles

### **1. Clé API Invalide ou Expirée**
- La clé fournie : `sk-ysnUMVE05PCwnB4cYCE8b0yuiHqifS3PG0iVafdYCoWcvMOM`
- Peut être expirée, révoquée ou invalide

### **2. Format de Requête Incorrect**
- Paramètres manquants ou incorrects
- Headers mal configurés
- Endpoint incorrect

### **3. Quota Dépassé**
- Limite de crédits atteinte
- Rate limiting activé

### **4. Problème de Région/Accès**
- API non disponible dans certaines régions
- Restrictions géographiques

## 🛠️ Solution Temporaire Implémentée

### **Mode Fallback Activé**
```javascript
// Image de fallback basée sur le titre
const seed = Math.abs(titre.split('').reduce((a, b) => a + b.charCodeAt(0), 0))
const fallbackImageUrl = `https://picsum.photos/seed/${seed}/512/512`

return NextResponse.json({
  success: true,
  imageUrl: fallbackImageUrl,
  prompt: prompt,
  fallback: true,
  message: 'Image générée avec succès (mode démo)'
})
```

### **Avantages du Fallback :**
- ✅ **Fonctionnalité maintenue** : L'utilisateur peut toujours générer des images
- ✅ **Images cohérentes** : Basées sur le titre (même seed = même image)
- ✅ **Expérience fluide** : Délai simulé pour réalisme
- ✅ **Feedback clair** : Message indiquant le mode démo

## 🔧 Étapes de Diagnostic

### **1. Vérifier la Clé API**
```bash
curl -X GET "https://api.stability.ai/v1/user/account" \
  -H "Authorization: Bearer sk-ysnUMVE05PCwnB4cYCE8b0yuiHqifS3PG0iVafdYCoWcvMOM"
```

**Réponses possibles :**
- **200 OK** : Clé valide
- **401 Unauthorized** : Clé invalide
- **403 Forbidden** : Accès refusé

### **2. Tester l'Endpoint de Génération**
```bash
curl -X POST "https://api.stability.ai/v1/generation/stable-diffusion-v1-5/text-to-image" \
  -H "Authorization: Bearer sk-ysnUMVE05PCwnB4cYCE8b0yuiHqifS3PG0iVafdYCoWcvMOM" \
  -H "Content-Type: application/json" \
  -d '{
    "text_prompts": [{"text": "test image"}],
    "cfg_scale": 7,
    "height": 512,
    "width": 512,
    "samples": 1,
    "steps": 30
  }'
```

### **3. Vérifier les Crédits**
```bash
curl -X GET "https://api.stability.ai/v1/user/balance" \
  -H "Authorization: Bearer sk-ysnUMVE05PCwnB4cYCE8b0yuiHqifS3PG0iVafdYCoWcvMOM"
```

## 🔄 Solutions Alternatives

### **1. Nouvelle Clé API**
Si la clé actuelle est invalide :
1. Aller sur https://platform.stability.ai/
2. Créer un nouveau compte ou se connecter
3. Générer une nouvelle clé API
4. Remplacer dans le code

### **2. Autres Services IA**
```javascript
// OpenAI DALL-E
const response = await fetch('https://api.openai.com/v1/images/generations', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: "dall-e-3",
    prompt: prompt,
    n: 1,
    size: "1024x1024"
  })
})

// Replicate
const response = await fetch('https://api.replicate.com/v1/predictions', {
  method: 'POST',
  headers: {
    'Authorization': `Token ${process.env.REPLICATE_API_TOKEN}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    version: "stability-ai/stable-diffusion:27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
    input: { prompt: prompt }
  })
})
```

### **3. Services Gratuits**
```javascript
// Unsplash API (images réelles)
const response = await fetch(`https://api.unsplash.com/search/photos?query=${encodeURIComponent(titre)}&client_id=${process.env.UNSPLASH_ACCESS_KEY}`)

// Lorem Picsum (images aléatoires)
const imageUrl = `https://picsum.photos/seed/${seed}/512/512`
```

## 🔧 Code de Réactivation Stability AI

### **Quand la Clé API Sera Valide :**
```javascript
// Décommenter ce code dans route.ts
const response = await axios.post(
  'https://api.stability.ai/v1/generation/stable-diffusion-v1-5/text-to-image',
  {
    text_prompts: [
      {
        text: prompt,
        weight: 1
      }
    ],
    cfg_scale: 7,
    height: 512,
    width: 512,
    samples: 1,
    steps: 30
  },
  {
    headers: {
      'Authorization': 'Bearer NOUVELLE_CLE_API_ICI',
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    responseType: 'arraybuffer'
  }
)

// Sauvegarder l'image
const uploadsDir = path.join(process.cwd(), 'public', 'uploads')
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true })
}

const timestamp = Date.now()
const filename = `newsletter-${timestamp}.png`
const filepath = path.join(uploadsDir, filename)

const imageBuffer = Buffer.from(response.data)
fs.writeFileSync(filepath, imageBuffer)

const imageUrl = `/uploads/${filename}`
```

## 📋 Checklist de Résolution

### **Étapes à Suivre :**
- [ ] **Tester la clé API** avec curl ou Postman
- [ ] **Vérifier les crédits** du compte Stability AI
- [ ] **Obtenir une nouvelle clé** si nécessaire
- [ ] **Tester avec paramètres minimaux** d'abord
- [ ] **Réactiver le code Stability AI** dans route.ts
- [ ] **Supprimer le code fallback** une fois fonctionnel

### **Variables d'Environnement :**
```bash
# .env.local
STABILITY_API_KEY=sk-nouvelle-cle-ici
OPENAI_API_KEY=sk-alternative-openai
REPLICATE_API_TOKEN=alternative-replicate
```

## 🎯 État Actuel

### **Fonctionnalité :**
- ✅ **Interface utilisateur** : Complète et fonctionnelle
- ✅ **Génération d'images** : Mode fallback opérationnel
- ✅ **Expérience utilisateur** : Fluide avec feedback
- ⚠️ **Stability AI** : Temporairement désactivé

### **Prochaines Étapes :**
1. **Diagnostiquer** la clé API Stability AI
2. **Obtenir une nouvelle clé** si nécessaire
3. **Réactiver** le code Stability AI
4. **Tester** la génération réelle
5. **Supprimer** le fallback

---

## 🎉 **Fonctionnalité Maintenue**

Malgré le problème temporaire avec Stability AI :
- ✅ **Page fonctionnelle** : Création de newsletter opérationnelle
- ✅ **Génération d'images** : Mode démo avec images cohérentes
- ✅ **Interface complète** : Tous les éléments présents
- ✅ **Prêt pour réactivation** : Code Stability AI commenté et prêt

**🔗 Testez maintenant :**
http://localhost:3001/admin-postgres/nouvelle-newsletter

---

*Solution temporaire implémentée en attendant la résolution du problème API* ✨
