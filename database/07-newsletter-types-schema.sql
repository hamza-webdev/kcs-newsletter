-- Schéma complet pour l'application de newsletters avec types/thématiques
-- Basé sur le design existant et les nouvelles spécifications

-- Table des types/thématiques de newsletters
CREATE TABLE IF NOT EXISTS newsletter_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#f6339a', -- Couleur hex pour l'affichage
    icon VARCHAR(50) DEFAULT 'FileText', -- Nom de l'icône Lucide
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion des types de newsletters selon les spécifications
INSERT INTO newsletter_types (name, slug, description, color, icon, display_order) VALUES
('Événements à venir', 'evenements-a-venir', 'Annonces et informations sur les événements organisés', '#3B82F6', 'Calendar', 1),
('Veille technologique', 'veille-technologique', 'Actualités et tendances technologiques', '#10B981', 'Cpu', 2),
('Actualités KCS', 'actualites-kcs', 'Nouvelles et informations internes de KCS', '#F59E0B', 'Building2', 3),
('Initiatives solidaires', 'initiatives-solidaires', 'Actions et projets solidaires', '#EF4444', 'Heart', 4),
('Vos témoignages', 'vos-temoignages', 'Témoignages et retours d''expérience', '#8B5CF6', 'MessageSquare', 5),
('Ressources utiles', 'ressources-utiles', 'Outils, guides et ressources pratiques', '#06B6D4', 'BookOpen', 6)
ON CONFLICT (slug) DO NOTHING;

-- Modification de la table newsletters pour ajouter le type
ALTER TABLE newsletters 
ADD COLUMN IF NOT EXISTS type_id INTEGER REFERENCES newsletter_types(id),
ADD COLUMN IF NOT EXISTS priority INTEGER DEFAULT 0, -- Priorité d'affichage
ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT false, -- Newsletter mise en avant
ADD COLUMN IF NOT EXISTS published_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS views_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS reading_time INTEGER; -- Temps de lecture estimé en minutes

-- Mise à jour des newsletters existantes avec un type par défaut
UPDATE newsletters 
SET type_id = (SELECT id FROM newsletter_types WHERE slug = 'actualites-kcs' LIMIT 1)
WHERE type_id IS NULL;

-- Table des sections/éditions d'une newsletter
CREATE TABLE IF NOT EXISTS newsletter_sections (
    id SERIAL PRIMARY KEY,
    newsletter_id UUID REFERENCES newsletters(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    section_order INTEGER DEFAULT 0,
    section_type VARCHAR(50) DEFAULT 'text', -- text, image, video, link, etc.
    metadata JSONB, -- Données additionnelles (liens, images, etc.)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des ressources attachées aux newsletters
CREATE TABLE IF NOT EXISTS newsletter_resources (
    id SERIAL PRIMARY KEY,
    newsletter_id UUID REFERENCES newsletters(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    resource_type VARCHAR(50) NOT NULL, -- file, link, image, video
    resource_url VARCHAR(500) NOT NULL,
    file_size INTEGER, -- Taille en bytes si c'est un fichier
    mime_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des notifications pour le workflow
CREATE TABLE IF NOT EXISTS workflow_notifications (
    id SERIAL PRIMARY KEY,
    newsletter_id UUID REFERENCES newsletters(id) ON DELETE CASCADE,
    from_user_id INTEGER REFERENCES users(id),
    to_user_id INTEGER REFERENCES users(id),
    notification_type VARCHAR(50) NOT NULL, -- validation_request, approved, rejected, published
    message TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des vues/lectures de newsletters (analytics)
CREATE TABLE IF NOT EXISTS newsletter_views (
    id SERIAL PRIMARY KEY,
    newsletter_id UUID REFERENCES newsletters(id) ON DELETE CASCADE,
    user_ip INET,
    user_agent TEXT,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reading_duration INTEGER -- Durée de lecture en secondes
);

-- Index pour optimiser les performances
CREATE INDEX IF NOT EXISTS idx_newsletters_type_id ON newsletters(type_id);
CREATE INDEX IF NOT EXISTS idx_newsletters_published_at ON newsletters(published_at);
CREATE INDEX IF NOT EXISTS idx_newsletters_is_featured ON newsletters(is_featured);
CREATE INDEX IF NOT EXISTS idx_newsletter_sections_newsletter_id ON newsletter_sections(newsletter_id);
CREATE INDEX IF NOT EXISTS idx_newsletter_resources_newsletter_id ON newsletter_resources(newsletter_id);
CREATE INDEX IF NOT EXISTS idx_workflow_notifications_to_user ON workflow_notifications(to_user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_newsletter_views_newsletter_id ON newsletter_views(newsletter_id);

-- Triggers pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_newsletter_types_updated_at ON newsletter_types;
CREATE TRIGGER update_newsletter_types_updated_at 
    BEFORE UPDATE ON newsletter_types 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Vue pour les statistiques par type de newsletter
CREATE OR REPLACE VIEW newsletter_type_stats AS
SELECT 
    nt.id,
    nt.name,
    nt.slug,
    nt.color,
    nt.icon,
    COUNT(n.id) as total_newsletters,
    COUNT(CASE WHEN n.status = 'publiee' THEN 1 END) as published_count,
    COUNT(CASE WHEN n.status = 'en_attente' THEN 1 END) as pending_count,
    COUNT(CASE WHEN n.status = 'brouillon' THEN 1 END) as draft_count,
    COALESCE(SUM(n.views_count), 0) as total_views,
    MAX(n.published_at) as last_published
FROM newsletter_types nt
LEFT JOIN newsletters n ON nt.id = n.type_id
WHERE nt.is_active = true
GROUP BY nt.id, nt.name, nt.slug, nt.color, nt.icon
ORDER BY nt.display_order;

-- Vue pour les newsletters avec informations complètes
CREATE OR REPLACE VIEW newsletters_with_details AS
SELECT 
    n.*,
    nt.name as type_name,
    nt.slug as type_slug,
    nt.color as type_color,
    nt.icon as type_icon,
    u.username as created_by_username,
    u.first_name as created_by_first_name,
    u.last_name as created_by_last_name,
    v.username as validated_by_username,
    COUNT(ns.id) as sections_count,
    COUNT(nr.id) as resources_count
FROM newsletters n
LEFT JOIN newsletter_types nt ON n.type_id = nt.id
LEFT JOIN users u ON n.created_by = u.id
LEFT JOIN users v ON n.validated_by = v.id
LEFT JOIN newsletter_sections ns ON n.id = ns.newsletter_id
LEFT JOIN newsletter_resources nr ON n.id = nr.newsletter_id
GROUP BY n.id, nt.id, nt.name, nt.slug, nt.color, nt.icon, 
         u.username, u.first_name, u.last_name, v.username;

-- Afficher les types créés
SELECT * FROM newsletter_types ORDER BY display_order;
