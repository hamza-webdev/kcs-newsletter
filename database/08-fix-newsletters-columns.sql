-- Script pour corriger et normaliser la table newsletters
-- Utiliser titre/contenu comme colonnes principales

-- 1. Ajouter les colonnes titre/contenu si elles n'existent pas
ALTER TABLE newsletters 
ADD COLUMN IF NOT EXISTS titre VARCHAR(255),
ADD COLUMN IF NOT EXISTS contenu TEXT;

-- 2. Migrer les données de title/description vers titre/contenu
UPDATE newsletters 
SET 
    titre = COALESCE(titre, title),
    contenu = COALESCE(contenu, description)
WHERE titre IS NULL OR contenu IS NULL;

-- 3. Mettre titre comme NOT NULL (après migration des données)
ALTER TABLE newsletters 
ALTER COLUMN titre SET NOT NULL;

-- 4. Créer des index pour les nouvelles colonnes
CREATE INDEX IF NOT EXISTS idx_newsletters_titre ON newsletters(titre);
CREATE INDEX IF NOT EXISTS idx_newsletters_contenu ON newsletters USING gin(to_tsvector('french', contenu));

-- 5. Vérifier que tous les newsletters ont un type_id
UPDATE newsletters 
SET type_id = (SELECT id FROM newsletter_types WHERE slug = 'actualites-kcs' LIMIT 1)
WHERE type_id IS NULL;

-- 6. Vérifier que tous les newsletters ont un created_by
-- (Assigner à l'admin par défaut pour les anciens)
UPDATE newsletters 
SET created_by = (SELECT id FROM users WHERE role = 'admin' LIMIT 1)
WHERE created_by IS NULL;

-- 7. Mettre à jour les statuts pour être cohérents
UPDATE newsletters 
SET status = CASE 
    WHEN status IS NULL AND statut IS NOT NULL THEN statut
    WHEN status IS NULL AND statut IS NULL THEN 'brouillon'
    ELSE status
END;

-- 8. Afficher un résumé des newsletters
SELECT 
    n.id,
    n.titre,
    nt.name as type_name,
    n.status,
    u.first_name || ' ' || u.last_name as created_by_name,
    n.created_at
FROM newsletters n
LEFT JOIN newsletter_types nt ON n.type_id = nt.id
LEFT JOIN users u ON n.created_by = u.id
ORDER BY n.created_at DESC
LIMIT 10;

-- 9. Statistiques par type
SELECT 
    nt.name as type_name,
    COUNT(n.id) as total_newsletters,
    COUNT(CASE WHEN n.status = 'publiee' THEN 1 END) as published,
    COUNT(CASE WHEN n.status = 'en_attente' THEN 1 END) as pending,
    COUNT(CASE WHEN n.status = 'brouillon' THEN 1 END) as draft
FROM newsletter_types nt
LEFT JOIN newsletters n ON nt.id = n.type_id
GROUP BY nt.id, nt.name
ORDER BY nt.display_order;
