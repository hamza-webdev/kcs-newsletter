#!/bin/bash

# Script de synchronisation intelligente vers VPS
# Avec exclusions et optimisations

# Configuration
VPS_IP="167.86.93.157"
VPS_USER="vpsadmin"
VPS_PATH="/home/vpsadmin/newslettre"
LOCAL_APP_DIR="./app"

echo "🧠 Synchronisation Intelligente vers VPS"
echo "========================================"
echo "🎯 $VPS_USER@$VPS_IP:$VPS_PATH"
echo ""

# Vérification des prérequis
echo "🔍 Vérification des prérequis..."

# Test rsync
if ! command -v rsync &> /dev/null; then
    echo "⚠️  rsync non trouvé, utilisation de scp"
    USE_RSYNC=false
else
    echo "✅ rsync disponible"
    USE_RSYNC=true
fi

# Test connexion
echo "🔐 Test connexion SSH..."
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes $VPS_USER@$VPS_IP "echo 'OK'" 2>/dev/null; then
    echo "❌ Connexion SSH échouée"
    echo "💡 Essayez: ssh-copy-id $VPS_USER@$VPS_IP"
    exit 1
fi
echo "✅ Connexion SSH OK"

# Préparation du répertoire distant
echo ""
echo "📁 Préparation du serveur..."
ssh $VPS_USER@$VPS_IP << EOF
# Création des répertoires
mkdir -p $VPS_PATH/{public/uploads,src,scripts}
chmod -R 755 $VPS_PATH

# Sauvegarde de l'ancien .env.local si il existe
if [ -f "$VPS_PATH/.env.local" ]; then
    cp $VPS_PATH/.env.local $VPS_PATH/.env.local.backup.\$(date +%Y%m%d_%H%M%S)
    echo "📋 Sauvegarde .env.local créée"
fi

echo "✅ Serveur préparé"
EOF

# Fonction de synchronisation avec rsync (optimisée)
sync_with_rsync() {
    local source=$1
    local dest=$2
    local description=$3
    
    echo "📦 Sync: $description"
    
    # Exclusions pour éviter les fichiers inutiles
    local excludes=(
        "--exclude=node_modules"
        "--exclude=.next"
        "--exclude=.git"
        "--exclude=*.log"
        "--exclude=.DS_Store"
        "--exclude=Thumbs.db"
        "--exclude=*.tmp"
        "--exclude=*.temp"
    )
    
    if rsync -avz --progress --delete "${excludes[@]}" "$source" "$VPS_USER@$VPS_IP:$dest" 2>/dev/null; then
        echo "✅ $description"
    else
        echo "❌ Erreur $description"
        return 1
    fi
}

# Fonction de synchronisation avec scp (fallback)
sync_with_scp() {
    local source=$1
    local dest=$2
    local description=$3
    
    echo "📦 Copy: $description"
    if scp -r "$source" "$VPS_USER@$VPS_IP:$dest" 2>/dev/null; then
        echo "✅ $description"
    else
        echo "❌ Erreur $description"
        return 1
    fi
}

# Synchronisation des dossiers
echo ""
echo "📂 Synchronisation des dossiers..."

if [ "$USE_RSYNC" = true ]; then
    # Avec rsync (plus efficace)
    sync_with_rsync "$LOCAL_APP_DIR/public/" "$VPS_PATH/public/" "Dossier public/"
    sync_with_rsync "$LOCAL_APP_DIR/src/" "$VPS_PATH/src/" "Dossier src/"
    
    if [ -d "$LOCAL_APP_DIR/scripts" ]; then
        sync_with_rsync "$LOCAL_APP_DIR/scripts/" "$VPS_PATH/scripts/" "Dossier scripts/"
    fi
else
    # Avec scp (fallback)
    sync_with_scp "$LOCAL_APP_DIR/public" "$VPS_PATH/" "Dossier public/"
    sync_with_scp "$LOCAL_APP_DIR/src" "$VPS_PATH/" "Dossier src/"
    
    if [ -d "$LOCAL_APP_DIR/scripts" ]; then
        sync_with_scp "$LOCAL_APP_DIR/scripts" "$VPS_PATH/" "Dossier scripts/"
    fi
fi

# Synchronisation des fichiers de configuration
echo ""
echo "📄 Synchronisation des fichiers..."

# Fichiers depuis app/
declare -A files_app=(
    [".env.local"]="Configuration environnement"
    ["package.json"]="Dépendances Node.js"
    ["postcss.config.mjs"]="Configuration PostCSS"
    ["next.config.ts"]="Configuration Next.js"
    ["tsconfig.json"]="Configuration TypeScript"
)

for file in "${!files_app[@]}"; do
    if [ -f "$LOCAL_APP_DIR/$file" ]; then
        echo "📦 ${files_app[$file]}: $file"
        if scp "$LOCAL_APP_DIR/$file" "$VPS_USER@$VPS_IP:$VPS_PATH/" 2>/dev/null; then
            echo "✅ $file"
        else
            echo "❌ Erreur $file"
        fi
    else
        echo "⚠️  $file non trouvé"
    fi
done

# Fichiers depuis la racine
declare -A files_root=(
    ["docker-compose.yml"]="Configuration Docker"
    ["init-db.sql"]="Script initialisation DB"
)

for file in "${!files_root[@]}"; do
    if [ -f "$file" ]; then
        echo "📦 ${files_root[$file]}: $file"
        if scp "$file" "$VPS_USER@$VPS_IP:$VPS_PATH/" 2>/dev/null; then
            echo "✅ $file"
        else
            echo "❌ Erreur $file"
        fi
    else
        echo "⚠️  $file non trouvé"
    fi
done

# Configuration post-synchronisation
echo ""
echo "🔧 Configuration post-sync..."
ssh $VPS_USER@$VPS_IP << EOF
cd $VPS_PATH

# Permissions de sécurité
chmod -R 755 .
chmod 600 .env.local 2>/dev/null || true
chmod 644 *.json *.ts *.mjs *.yml *.sql 2>/dev/null || true

# Répertoire uploads
mkdir -p public/uploads
chmod 755 public/uploads

# Nettoyage des fichiers temporaires
find . -name "*.tmp" -delete 2>/dev/null || true
find . -name "*.log" -delete 2>/dev/null || true
find . -name ".DS_Store" -delete 2>/dev/null || true

echo "✅ Configuration terminée"
EOF

# Rapport final
echo ""
echo "📊 Rapport de synchronisation..."
ssh $VPS_USER@$VPS_IP << EOF
cd $VPS_PATH

echo "📋 Structure des fichiers:"
tree -L 2 2>/dev/null || ls -la

echo ""
echo "📊 Statistiques:"
echo "  - Taille totale: \$(du -sh . | cut -f1)"
echo "  - Nombre de fichiers: \$(find . -type f | wc -l)"
echo "  - Dossiers: \$(find . -type d | wc -l)"

echo ""
echo "🔍 Fichiers de configuration:"
ls -la *.{json,ts,mjs,local,yml,sql} 2>/dev/null | head -10

echo ""
echo "📁 Dossier public/uploads:"
ls -la public/uploads/ 2>/dev/null | head -5 || echo "  Vide"
EOF

# Instructions finales
echo ""
echo "🎉 Synchronisation terminée avec succès!"
echo ""
echo "🚀 Prochaines étapes sur le serveur:"
echo "   1. Connexion: ssh $VPS_USER@$VPS_IP"
echo "   2. Navigation: cd $VPS_PATH"
echo "   3. Installation: npm install --production"
echo "   4. Build: npm run build"
echo "   5. Démarrage: docker-compose up -d"
echo ""
echo "🔧 Commandes de maintenance:"
echo "   - Logs: docker-compose logs -f"
echo "   - Restart: docker-compose restart"
echo "   - Status: docker-compose ps"
echo ""
echo "📱 Application accessible sur:"
echo "   - HTTP: http://$VPS_IP:3001"
echo "   - HTTPS: https://newslettre.kcs.zidani.org (si configuré)"
