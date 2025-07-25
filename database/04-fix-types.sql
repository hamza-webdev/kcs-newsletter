-- Script pour corriger les types de colonnes

-- Supprimer les colonnes existantes et les recréer avec le bon type
ALTER TABLE newsletters DROP COLUMN IF EXISTS created_by CASCADE;
ALTER TABLE newsletters DROP COLUMN IF EXISTS assigned_to CASCADE;
ALTER TABLE newsletters DROP COLUMN IF EXISTS validated_by CASCADE;

-- Recréer les colonnes avec le bon type
ALTER TABLE newsletters ADD COLUMN created_by INTEGER;
ALTER TABLE newsletters ADD COLUMN assigned_to INTEGER;
ALTER TABLE newsletters ADD COLUMN validated_by INTEGER;

-- Ajouter les contraintes de clé étrangère
ALTER TABLE newsletters ADD CONSTRAINT fk_newsletters_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE newsletters ADD CONSTRAINT fk_newsletters_assigned_to 
    FOREIGN KEY (assigned_to) REFERENCES users(id);
ALTER TABLE newsletters ADD CONSTRAINT fk_newsletters_validated_by 
    FOREIGN KEY (validated_by) REFERENCES users(id);

-- Assigner toutes les newsletters existantes à l'admin
UPDATE newsletters SET created_by = 1 WHERE created_by IS NULL;

-- Recréer les index
CREATE INDEX IF NOT EXISTS idx_newsletters_created_by ON newsletters(created_by);
CREATE INDEX IF NOT EXISTS idx_newsletters_assigned_to ON newsletters(assigned_to);

-- Vérifier les résultats
SELECT 
    id, 
    title as titre, 
    status, 
    created_by,
    created_at 
FROM newsletters 
ORDER BY created_at DESC 
LIMIT 5;
