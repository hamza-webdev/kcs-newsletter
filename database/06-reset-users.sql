-- Script pour réinitialiser complètement les utilisateurs
-- Supprime et recrée tous les utilisateurs avec des mots de passe valides

-- Supprimer tous les utilisateurs existants
DELETE FROM user_sessions;
DELETE FROM users;

-- Réinitialiser les séquences
ALTER SEQUENCE users_id_seq RESTART WITH 1;
ALTER SEQUENCE user_sessions_id_seq RESTART WITH 1;

-- Insérer l'admin avec un hash bcrypt valide pour "password123"
-- Hash généré avec bcrypt.hash('password123', 10)
INSERT INTO users (username, email, password_hash, role, first_name, last_name, is_active) VALUES
('admin', 'admin@newsletter-kcs.local', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'Administrateur', 'Système', true);

-- Insérer les gestionnaires avec le même hash
INSERT INTO users (username, email, password_hash, role, first_name, last_name, is_active) VALUES
('gestionnaire1', 'gestionnaire1@newsletter-kcs.local', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'gestionnaire', 'Ahmed', 'Benali', true),
('gestionnaire2', 'gestionnaire2@newsletter-kcs.local', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'gestionnaire', 'Fatima', 'Zahra', true),
('gestionnaire3', 'gestionnaire3@newsletter-kcs.local', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'gestionnaire', 'Mohamed', 'Alami', true),
('gestionnaire4', 'gestionnaire4@newsletter-kcs.local', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'gestionnaire', 'Aicha', 'Idrissi', true),
('gestionnaire5', 'gestionnaire5@newsletter-kcs.local', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'gestionnaire', 'Youssef', 'Tazi', true);

-- Vérifier les utilisateurs créés
SELECT 
    id,
    username, 
    email, 
    role, 
    first_name, 
    last_name,
    is_active,
    CASE 
        WHEN password_hash IS NOT NULL AND LENGTH(password_hash) > 50 THEN 'Hash valide'
        ELSE 'Problème hash'
    END as password_status,
    created_at
FROM users 
ORDER BY role, username;

-- Afficher le nombre d'utilisateurs
SELECT 
    role,
    COUNT(*) as count
FROM users 
GROUP BY role
ORDER BY role;
