-- Initialisation de la base de données newsletter_kcs
-- Ce script est exécuté automatiquement lors du premier démarrage de PostgreSQL

-- Création de la table newsletters si elle n'existe pas
CREATE TABLE IF NOT EXISTS newsletters (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    title character varying NOT NULL,
    description text,
    image_ia_url character varying(500),
    image_ia_filename character varying(255),
    image_upload_url character varying(500),
    image_upload_filename character varying(255),
    prompt_ia text,
    statut character varying(50) DEFAULT 'brouillon'::character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    published_at timestamp with time zone,
    is_published boolean DEFAULT false,
    created_by uuid,
    CONSTRAINT newsletters_pkey PRIMARY KEY (id)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_newsletters_created_at ON newsletters(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_newsletters_statut ON newsletters(statut);
CREATE INDEX IF NOT EXISTS idx_newsletters_title ON newsletters(title);
CREATE INDEX IF NOT EXISTS idx_newsletters_is_published ON newsletters(is_published);

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger pour mettre à jour updated_at
DROP TRIGGER IF EXISTS update_newsletters_updated_at ON newsletters;
CREATE TRIGGER update_newsletters_updated_at
    BEFORE UPDATE ON newsletters
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Commentaires sur les colonnes
COMMENT ON TABLE newsletters IS 'Table pour stocker les newsletters créées';
COMMENT ON COLUMN newsletters.id IS 'Identifiant unique de la newsletter';
COMMENT ON COLUMN newsletters.title IS 'Titre de la newsletter';
COMMENT ON COLUMN newsletters.description IS 'Contenu principal de la newsletter';
COMMENT ON COLUMN newsletters.image_ia_url IS 'URL publique de l''image générée par IA';
COMMENT ON COLUMN newsletters.image_ia_filename IS 'Nom du fichier de l''image IA';
COMMENT ON COLUMN newsletters.image_upload_url IS 'URL publique de l''image uploadée';
COMMENT ON COLUMN newsletters.image_upload_filename IS 'Nom du fichier de l''image uploadée';
COMMENT ON COLUMN newsletters.prompt_ia IS 'Prompt utilisé pour générer l''image IA';
COMMENT ON COLUMN newsletters.statut IS 'Statut de la newsletter (brouillon, publiée, archivée)';
COMMENT ON COLUMN newsletters.created_at IS 'Date de création';
COMMENT ON COLUMN newsletters.updated_at IS 'Date de dernière modification';
COMMENT ON COLUMN newsletters.published_at IS 'Date de publication';
COMMENT ON COLUMN newsletters.is_published IS 'Indique si la newsletter est publiée';
COMMENT ON COLUMN newsletters.created_by IS 'ID de l''utilisateur créateur';

-- Insertion de données de test (optionnel)
INSERT INTO newsletters (title, description, statut, is_published) VALUES 
('Newsletter KCS - Bienvenue', 'Bienvenue dans notre système de newsletter. Cette newsletter de test vous montre les fonctionnalités disponibles.', 'publiée', true),
('Newsletter KCS - Janvier 2024', 'Newsletter du mois de janvier avec les dernières actualités et mises à jour.', 'brouillon', false)
ON CONFLICT DO NOTHING;

-- Affichage du résultat
SELECT 'Base de données newsletter_kcs initialisée avec succès!' as message;
SELECT 'Table newsletters créée avec ' || COUNT(*) || ' enregistrements' as status FROM newsletters;
