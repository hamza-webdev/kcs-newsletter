#!/bin/bash

# Script de synchronisation rapide vers VPS
# Version simplifiée avec SCP

# Configuration
VPS_IP="167.86.93.157"
VPS_USER="vpsadmin"
VPS_PATH="/home/vpsadmin/newslettre"
LOCAL_APP_DIR="./app"

echo "⚡ Synchronisation Rapide vers VPS"
echo "================================="
echo "🎯 Destination: $VPS_USER@$VPS_IP:$VPS_PATH"
echo ""

# Test de connexion rapide
echo "🔐 Test connexion..."
if ! ssh -o ConnectTimeout=3 $VPS_USER@$VPS_IP "echo 'OK'" 2>/dev/null; then
    echo "❌ Connexion échouée"
    exit 1
fi
echo "✅ Connexion OK"

# Création du répertoire de destination
echo ""
echo "📁 Préparation répertoire distant..."
ssh $VPS_USER@$VPS_IP "mkdir -p $VPS_PATH && chmod 755 $VPS_PATH"

# Synchronisation des dossiers
echo ""
echo "📂 Copie des dossiers..."

echo "  📦 Dossier public/"
scp -r $LOCAL_APP_DIR/public $VPS_USER@$VPS_IP:$VPS_PATH/ 2>/dev/null && echo "  ✅ public/ copié" || echo "  ❌ Erreur public/"

echo "  📦 Dossier src/"
scp -r $LOCAL_APP_DIR/src $VPS_USER@$VPS_IP:$VPS_PATH/ 2>/dev/null && echo "  ✅ src/ copié" || echo "  ❌ Erreur src/"

echo "  📦 Dossier scripts/"
scp -r $LOCAL_APP_DIR/scripts $VPS_USER@$VPS_IP:$VPS_PATH/ 2>/dev/null && echo "  ✅ scripts/ copié" || echo "  ❌ Erreur scripts/"

# Synchronisation des fichiers
echo ""
echo "📄 Copie des fichiers..."

# Fichiers depuis le dossier app/
FILES_APP=(".env.local" "package.json" "postcss.config.mjs" "next.config.ts" "tsconfig.json")
for file in "${FILES_APP[@]}"; do
    if [ -f "$LOCAL_APP_DIR/$file" ]; then
        echo "  📦 $file"
        scp "$LOCAL_APP_DIR/$file" "$VPS_USER@$VPS_IP:$VPS_PATH/" 2>/dev/null && echo "  ✅ $file copié" || echo "  ❌ Erreur $file"
    else
        echo "  ⚠️  $file non trouvé"
    fi
done

# Fichiers depuis la racine du projet
echo "  📦 docker-compose.yml"
scp "docker-compose.yml" "$VPS_USER@$VPS_IP:$VPS_PATH/" 2>/dev/null && echo "  ✅ docker-compose.yml copié" || echo "  ❌ Erreur docker-compose.yml"

echo "  📦 init-db.sql"
scp "init-db.sql" "$VPS_USER@$VPS_IP:$VPS_PATH/" 2>/dev/null && echo "  ✅ init-db.sql copié" || echo "  ❌ Erreur init-db.sql"

# Configuration des permissions
echo ""
echo "🔧 Configuration permissions..."
ssh $VPS_USER@$VPS_IP << 'EOF'
cd /home/vpsadmin/newslettre
chmod -R 755 .
chmod 600 .env.local 2>/dev/null || true
chmod 755 public/uploads 2>/dev/null || mkdir -p public/uploads && chmod 755 public/uploads
echo "✅ Permissions configurées"
EOF

# Vérification rapide
echo ""
echo "🔍 Vérification..."
ssh $VPS_USER@$VPS_IP << 'EOF'
cd /home/vpsadmin/newslettre
echo "📋 Fichiers présents:"
ls -1 | head -10
echo ""
echo "📊 Taille totale:"
du -sh . 2>/dev/null
EOF

echo ""
echo "🎉 Synchronisation terminée!"
echo ""
echo "🚀 Commandes suivantes:"
echo "   ssh $VPS_USER@$VPS_IP"
echo "   cd $VPS_PATH"
echo "   npm install"
echo "   docker-compose up -d"
