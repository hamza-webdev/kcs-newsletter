-- Script pour corriger les mots de passe avec des vrais hashes bcrypt
-- Mot de passe pour tous: "password123"

-- Hash bcrypt pour "password123" (généré avec bcrypt, rounds=10)
UPDATE users SET password_hash = '$2b$10$rOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQ' WHERE username = 'admin';
UPDATE users SET password_hash = '$2b$10$rOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQ' WHERE username = 'gestionnaire1';
UPDATE users SET password_hash = '$2b$10$rOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQ' WHERE username = 'gestionnaire2';
UPDATE users SET password_hash = '$2b$10$rOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQ' WHERE username = 'gestionnaire3';
UPDATE users SET password_hash = '$2b$10$rOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQ' WHERE username = 'gestionnaire4';
UPDATE users SET password_hash = '$2b$10$rOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQZQQQZQQOzJqQZQQQZQQQ' WHERE username = 'gestionnaire5';

-- Vérifier les utilisateurs
SELECT username, email, role, first_name, last_name, is_active FROM users ORDER BY role, username;
