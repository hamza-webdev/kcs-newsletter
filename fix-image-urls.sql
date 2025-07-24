-- Script SQL pour corriger les URLs d'images existantes dans la base de données

-- Mettre à jour les URLs d'images IA pour utiliser l'API route
UPDATE newsletters 
SET image_ia_url = REPLACE(image_ia_url, '/uploads/', '/api/uploads/')
WHERE image_ia_url LIKE '/uploads/%';

-- Mettre à jour les URLs d'images uploadées pour utiliser l'API route  
UPDATE newsletters 
SET image_upload_url = REPLACE(image_upload_url, '/uploads/', '/api/uploads/')
WHERE image_upload_url LIKE '/uploads/%';

-- Vérifier les résultats
SELECT id, titre, image_ia_url, image_upload_url 
FROM newsletters 
WHERE image_ia_url IS NOT NULL OR image_upload_url IS NOT NULL
ORDER BY created_at DESC
LIMIT 10;
