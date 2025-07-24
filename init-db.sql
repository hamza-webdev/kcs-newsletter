-- Create users and roles
CREATE USER authenticator WITH PASSWORD 'authenticator123';
CREATE USER supabase_auth_admin WITH PASSWORD 'auth123';
CREATE USER supabase_admin WITH PASSWORD 'admin123';

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON DATABASE newsletter_kcs TO authenticator;
GRANT ALL PRIVILEGES ON DATABASE newsletter_kcs TO supabase_auth_admin;
GRANT ALL PRIVILEGES ON DATABASE newsletter_kcs TO supabase_admin;

-- Create anon role
CREATE ROLE anon;
CREATE ROLE authenticated;
CREATE ROLE service_role;

-- Grant roles to authenticator
GRANT anon TO authenticator;
GRANT authenticated TO authenticator;
GRANT service_role TO authenticator;

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create auth schema for GoTrue
CREATE SCHEMA IF NOT EXISTS auth;
GRANT USAGE ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA auth TO supabase_auth_admin;

-- Create realtime schema
CREATE SCHEMA IF NOT EXISTS _realtime;
GRANT USAGE ON SCHEMA _realtime TO supabase_admin;

-- Create public schema tables
CREATE TABLE IF NOT EXISTS newsletters (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  published_at TIMESTAMP WITH TIME ZONE,
  is_published BOOLEAN DEFAULT FALSE,
  created_by UUID
);

CREATE TABLE IF NOT EXISTS newsletter_sections (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  newsletter_id UUID REFERENCES newsletters(id) ON DELETE CASCADE,
  section_type VARCHAR(50) NOT NULL CHECK (section_type IN ('events', 'news', 'kcs_updates', 'solidarity', 'feedback', 'contact')),
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  order_index INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS contacts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  message TEXT,
  feedback_type VARCHAR(50) CHECK (feedback_type IN ('suggestion', 'complaint', 'question', 'other')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS subscribers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  subscribed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  unsubscribed_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_newsletters_published ON newsletters(is_published, published_at);
CREATE INDEX IF NOT EXISTS idx_newsletter_sections_newsletter_id ON newsletter_sections(newsletter_id);
CREATE INDEX IF NOT EXISTS idx_newsletter_sections_order ON newsletter_sections(newsletter_id, order_index);
CREATE INDEX IF NOT EXISTS idx_contacts_created_at ON contacts(created_at);
CREATE INDEX IF NOT EXISTS idx_subscribers_email ON subscribers(email);
CREATE INDEX IF NOT EXISTS idx_subscribers_active ON subscribers(is_active);

-- Grant permissions to roles
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated, service_role;

-- Enable RLS
ALTER TABLE newsletters ENABLE ROW LEVEL SECURITY;
ALTER TABLE newsletter_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;

-- RLS Policies for newsletters
CREATE POLICY "Public can view published newsletters" ON newsletters
  FOR SELECT USING (is_published = true);

CREATE POLICY "Authenticated users can manage newsletters" ON newsletters
  FOR ALL USING (true);

-- RLS Policies for newsletter_sections
CREATE POLICY "Public can view sections of published newsletters" ON newsletter_sections
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM newsletters 
      WHERE newsletters.id = newsletter_sections.newsletter_id 
      AND newsletters.is_published = true
    )
  );

CREATE POLICY "Authenticated users can manage newsletter sections" ON newsletter_sections
  FOR ALL USING (true);

-- RLS Policies for contacts
CREATE POLICY "Anyone can insert contacts" ON contacts
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Authenticated users can view contacts" ON contacts
  FOR SELECT USING (true);

-- RLS Policies for subscribers
CREATE POLICY "Anyone can subscribe" ON subscribers
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Authenticated users can manage subscribers" ON subscribers
  FOR ALL USING (true);

-- Update triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_newsletters_updated_at BEFORE UPDATE ON newsletters
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_newsletter_sections_updated_at BEFORE UPDATE ON newsletter_sections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO newsletters (id, title, description, is_published, published_at) VALUES
  (gen_random_uuid(), 'Newsletter KCS - Janvier 2024', 'Découvrez les actualités du mois de janvier avec nos événements à venir, les dernières nouvelles de la veille technologique et les initiatives solidaires.', true, NOW() - INTERVAL '15 days'),
  (gen_random_uuid(), 'Newsletter KCS - Décembre 2023', 'Bilan de fin d''année avec nos réalisations, les événements marquants et les perspectives pour 2024.', true, NOW() - INTERVAL '45 days');

-- Insert sample newsletter sections
WITH newsletter_ids AS (
  SELECT id, title FROM newsletters WHERE title LIKE 'Newsletter KCS - Janvier 2024'
)
INSERT INTO newsletter_sections (newsletter_id, section_type, title, content, order_index)
SELECT 
  newsletter_ids.id,
  'events',
  'Formations à venir',
  '<p>Découvrez nos prochaines formations en développement web et mobile. Inscriptions ouvertes pour les sessions de février et mars.</p><ul><li>Formation React.js - 15 février</li><li>Formation Node.js - 22 février</li><li>Workshop Mobile - 1er mars</li></ul>',
  1
FROM newsletter_ids
UNION ALL
SELECT 
  newsletter_ids.id,
  'news',
  'Veille technologique',
  '<p>Les dernières actualités du monde de la tech qui nous ont marqués ce mois-ci.</p><p>Focus sur les nouvelles fonctionnalités de Next.js 14 et l''évolution de l''écosystème JavaScript.</p>',
  2
FROM newsletter_ids
UNION ALL
SELECT 
  newsletter_ids.id,
  'kcs_updates',
  'Actualités KCS',
  '<p>Retour sur les événements marquants de janvier au sein de notre association.</p><p>Nouveau partenariat avec des entreprises locales pour faciliter l''insertion professionnelle de nos membres.</p>',
  3
FROM newsletter_ids;

-- Insert sample subscribers
INSERT INTO subscribers (email, name, is_active) VALUES
  ('admin@assokcs.org', 'Administrateur KCS', true),
  ('membre1@example.com', 'Marie Dupont', true),
  ('membre2@example.com', 'Jean Martin', true),
  ('test@example.com', 'Utilisateur Test', true);
