-- Script de création des tables utilisateurs et gestion des rôles
-- Newsletter KCS - Système d'authentification et autorisation

-- Table des utilisateurs
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'gestionnaire')),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Table des sessions utilisateur
CREATE TABLE IF NOT EXISTS user_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT
);

-- Modifier la table newsletters pour ajouter les champs de gestion
ALTER TABLE newsletters
ADD COLUMN IF NOT EXISTS created_by INTEGER,
ADD COLUMN IF NOT EXISTS assigned_to INTEGER,
ADD COLUMN IF NOT EXISTS validated_by INTEGER,
ADD COLUMN IF NOT EXISTS validated_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'brouillon' CHECK (status IN ('brouillon', 'en_attente', 'validee', 'publiee', 'rejetee')),
ADD COLUMN IF NOT EXISTS admin_notes TEXT,
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- Mettre à jour la colonne statut existante vers le nouveau système
UPDATE newsletters SET status = 
    CASE 
        WHEN statut = 'publiée' THEN 'publiee'
        WHEN statut = 'brouillon' THEN 'brouillon'
        ELSE 'brouillon'
    END
WHERE status IS NULL;

-- Table des notifications/alertes
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    newsletter_id UUID,
    type VARCHAR(50) NOT NULL, -- 'validation_request', 'rejection', 'approval', 'modification_request'
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INTEGER REFERENCES users(id)
);

-- Index pour optimiser les performances
CREATE INDEX IF NOT EXISTS idx_newsletters_created_by ON newsletters(created_by);
CREATE INDEX IF NOT EXISTS idx_newsletters_status ON newsletters(status);
CREATE INDEX IF NOT EXISTS idx_newsletters_assigned_to ON newsletters(assigned_to);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires ON user_sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger pour users
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour newsletters
DROP TRIGGER IF EXISTS update_newsletters_updated_at ON newsletters;
CREATE TRIGGER update_newsletters_updated_at 
    BEFORE UPDATE ON newsletters 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insertion des utilisateurs par défaut
-- Mot de passe hashé pour 'password123' (à changer en production)
-- Hash généré avec bcrypt, rounds=10

-- Admin par défaut
INSERT INTO users (username, email, password_hash, role, first_name, last_name) 
VALUES (
    'admin', 
    'admin@newsletter-kcs.local', 
    '$2b$10$rOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQ', -- password123
    'admin', 
    'Administrateur', 
    'Système'
) ON CONFLICT (username) DO NOTHING;

-- Gestionnaires par défaut
INSERT INTO users (username, email, password_hash, role, first_name, last_name) VALUES
('gestionnaire1', 'gestionnaire1@newsletter-kcs.local', '$2b$10$rOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQ', 'gestionnaire', 'Ahmed', 'Benali'),
('gestionnaire2', 'gestionnaire2@newsletter-kcs.local', '$2b$10$rOzJqQZQQQZQQQZQQQZQQQZQQOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQ', 'gestionnaire', 'Fatima', 'Zahra'),
('gestionnaire3', 'gestionnaire3@newsletter-kcs.local', '$2b$10$rOzJqQZQQQZQQQZQQQZQQQZQQOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQ', 'gestionnaire', 'Mohamed', 'Alami'),
('gestionnaire4', 'gestionnaire4@newsletter-kcs.local', '$2b$10$rOzJqQZQQQZQQQZQQQZQQQZQQOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQ', 'gestionnaire', 'Aicha', 'Idrissi'),
('gestionnaire5', 'gestionnaire5@newsletter-kcs.local', '$2b$10$rOzJqQZQQQZQQQZQQQZQQQZQQOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQ', 'gestionnaire', 'Youssef', 'Tazi')
ON CONFLICT (username) DO NOTHING;

-- Mettre à jour les newsletters existantes pour les assigner à l'admin
UPDATE newsletters 
SET created_by = (SELECT id FROM users WHERE username = 'admin' LIMIT 1),
    status = 'publiee'
WHERE created_by IS NULL;

-- Vue pour les statistiques par utilisateur
CREATE OR REPLACE VIEW user_newsletter_stats AS
SELECT
    u.id as user_id,
    u.username,
    u.role,
    COUNT(n.id) as total_newsletters,
    COUNT(CASE WHEN n.status = 'brouillon' THEN 1 END) as brouillons,
    COUNT(CASE WHEN n.status = 'en_attente' THEN 1 END) as en_attente,
    COUNT(CASE WHEN n.status = 'validee' THEN 1 END) as validees,
    COUNT(CASE WHEN n.status = 'publiee' THEN 1 END) as publiees,
    COUNT(CASE WHEN n.status = 'rejetee' THEN 1 END) as rejetees
FROM users u
LEFT JOIN newsletters n ON u.id::text = n.created_by::text
GROUP BY u.id, u.username, u.role;

-- Afficher les utilisateurs créés
SELECT 
    id, 
    username, 
    email, 
    role, 
    first_name, 
    last_name, 
    is_active,
    created_at
FROM users 
ORDER BY role, username;
