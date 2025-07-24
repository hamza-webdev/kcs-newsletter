#!/bin/bash

# Configuration du déploiement
VPS_IP="167.86.93.157"
VPS_USER="vpsadmin"
DOMAIN="newslettre.kcs.zidani.org"
APP_NAME="newslettre"
DEPLOY_DIR="/home/vpsadmin/$APP_NAME"
LOCAL_APP_DIR="./app"

echo "🚀 Déploiement de Newsletter KCS sur VPS"
echo "=========================================="
echo "VPS: $VPS_USER@$VPS_IP"
echo "Domaine: $DOMAIN"
echo "Répertoire: $DEPLOY_DIR"
echo ""

# Vérification des fichiers locaux
echo "📋 Vérification des fichiers locaux..."
if [ ! -d "$LOCAL_APP_DIR/src" ]; then
    echo "❌ Erreur: Dossier src/ non trouvé dans $LOCAL_APP_DIR"
    exit 1
fi

if [ ! -d "$LOCAL_APP_DIR/public" ]; then
    echo "❌ Erreur: Dossier public/ non trouvé dans $LOCAL_APP_DIR"
    exit 1
fi

if [ ! -f "$LOCAL_APP_DIR/package.json" ]; then
    echo "❌ Erreur: Fichier package.json non trouvé dans $LOCAL_APP_DIR"
    exit 1
fi

echo "✅ Fichiers locaux vérifiés"

# Création du répertoire temporaire pour le déploiement
TEMP_DIR="./deploy-temp"
rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

echo "📦 Préparation des fichiers pour le déploiement..."

# Copie des dossiers
cp -r $LOCAL_APP_DIR/src $TEMP_DIR/
cp -r $LOCAL_APP_DIR/public $TEMP_DIR/
cp -r ./database $TEMP_DIR/

# Copie des fichiers de configuration
cp $LOCAL_APP_DIR/package.json $TEMP_DIR/
cp $LOCAL_APP_DIR/package-lock.json $TEMP_DIR/ 2>/dev/null || echo "⚠️  package-lock.json non trouvé"
cp ./docker-compose.yml $TEMP_DIR/
cp $LOCAL_APP_DIR/next.config.ts $TEMP_DIR/ 2>/dev/null || echo "⚠️  next.config.ts non trouvé"
cp $LOCAL_APP_DIR/middleware.ts $TEMP_DIR/ 2>/dev/null || echo "⚠️  middleware.ts non trouvé"
cp $LOCAL_APP_DIR/tailwind.config.ts $TEMP_DIR/ 2>/dev/null || echo "⚠️  tailwind.config.ts non trouvé"
cp $LOCAL_APP_DIR/tsconfig.json $TEMP_DIR/ 2>/dev/null || echo "⚠️  tsconfig.json non trouvé"

# Création du fichier .env.local pour la production
cat > $TEMP_DIR/.env.local << EOF
# Database Configuration (PostgreSQL)
DB_HOST=localhost
DB_PORT=5433
DB_NAME=newsletter_kcs
DB_USER=postgres
DB_PASSWORD=postgres123

# Application Configuration
NEXT_PUBLIC_APP_URL=https://$DOMAIN
NODE_ENV=production

# JWT Secret for simple auth
JWT_SECRET=super-secret-jwt-token-with-at-least-32-characters-long-production

# OpenAI API Key (à configurer sur le serveur)
OPENAI_API_KEY=your-openai-api-key-here
EOF

# Création du Dockerfile pour la production
cat > $TEMP_DIR/Dockerfile << EOF
FROM node:18-alpine

WORKDIR /app

# Installation des dépendances
COPY package*.json ./
RUN npm ci --only=production

# Copie du code source
COPY . .

# Build de l'application
RUN npm run build

# Exposition du port
EXPOSE 3000

# Démarrage de l'application
CMD ["npm", "start"]
EOF

# Mise à jour du docker-compose.yml pour la production
cat > $TEMP_DIR/docker-compose.prod.yml << EOF
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15
    container_name: ${APP_NAME}-postgres
    environment:
      POSTGRES_DB: newsletter_kcs
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
      POSTGRES_HOST_AUTH_METHOD: trust
    ports:
      - "5433:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - ${APP_NAME}-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d newsletter_kcs"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Application Next.js
  app:
    build: .
    container_name: ${APP_NAME}-app
    environment:
      - NODE_ENV=production
    ports:
      - "3001:3000"
    volumes:
      - ./public/uploads:/app/public/uploads
    networks:
      - ${APP_NAME}-network
    depends_on:
      - postgres
    restart: unless-stopped

  # pgAdmin (Interface d'administration)
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: ${APP_NAME}-pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@newsletter-kcs.local
      PGADMIN_DEFAULT_PASSWORD: admin123
      PGADMIN_CONFIG_SERVER_MODE: 'False'
    ports:
      - "5050:80"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    networks:
      - ${APP_NAME}-network
    depends_on:
      - postgres
    restart: unless-stopped

volumes:
  postgres_data:
  pgadmin_data:

networks:
  ${APP_NAME}-network:
    driver: bridge
EOF

echo "✅ Fichiers préparés dans $TEMP_DIR"

# Création de l'archive
echo "📦 Création de l'archive de déploiement..."
tar -czf deploy.tar.gz -C $TEMP_DIR .
echo "✅ Archive créée: deploy.tar.gz"

# Transfert vers le VPS
echo "🚀 Transfert vers le VPS..."
echo "Connexion à $VPS_USER@$VPS_IP..."

# Création du répertoire sur le VPS et transfert
scp deploy.tar.gz $VPS_USER@$VPS_IP:/tmp/

# Connexion SSH et déploiement
ssh $VPS_USER@$VPS_IP << EOF
echo "📁 Création du répertoire de déploiement..."
sudo mkdir -p $DEPLOY_DIR
sudo chown $VPS_USER:$VPS_USER $DEPLOY_DIR

echo "📦 Extraction de l'archive..."
cd $DEPLOY_DIR
tar -xzf /tmp/deploy.tar.gz
rm /tmp/deploy.tar.gz

echo "🔧 Configuration des permissions..."
chmod +x $DEPLOY_DIR
mkdir -p $DEPLOY_DIR/public/uploads
chmod 755 $DEPLOY_DIR/public/uploads

echo "🐳 Arrêt des containers existants..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

echo "🚀 Démarrage des services..."
docker-compose -f docker-compose.prod.yml up -d --build

echo "⏳ Attente du démarrage des services..."
sleep 30

echo "🔍 Vérification du statut..."
docker-compose -f docker-compose.prod.yml ps

echo "✅ Déploiement terminé!"
echo ""
echo "🌐 Votre application est accessible à:"
echo "   - Application: http://$DOMAIN:3001"
echo "   - pgAdmin: http://$DOMAIN:5050"
echo ""
echo "📋 Pour configurer Nginx (optionnel):"
echo "   sudo nano /etc/nginx/sites-available/$DOMAIN"
EOF

# Nettoyage local
rm -rf $TEMP_DIR
rm deploy.tar.gz

echo ""
echo "🎉 Déploiement terminé avec succès!"
echo ""
echo "🔗 Liens utiles:"
echo "   - Application: http://$DOMAIN:3001"
echo "   - pgAdmin: http://$DOMAIN:5050"
echo ""
echo "📝 Prochaines étapes:"
echo "   1. Configurer la clé OpenAI dans .env.local sur le serveur"
echo "   2. Configurer Nginx pour le domaine (optionnel)"
echo "   3. Configurer SSL avec Let's Encrypt (optionnel)"
