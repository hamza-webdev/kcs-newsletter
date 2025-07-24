#!/bin/bash

# Script de synchronisation vers VPS
# Copie les fichiers et dossiers spécifiés vers le serveur

# Configuration VPS
VPS_IP="167.86.93.157"
VPS_USER="vpsadmin"
VPS_PATH="/home/vpsadmin/newslettre"
LOCAL_APP_DIR="./app"

echo "🚀 Synchronisation vers VPS Newsletter KCS"
echo "=========================================="
echo "VPS: $VPS_USER@$VPS_IP"
echo "Destination: $VPS_PATH"
echo "Source locale: $LOCAL_APP_DIR"
echo ""

# Vérification de la connexion SSH
echo "🔐 Test de connexion SSH..."
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes $VPS_USER@$VPS_IP "echo 'Connexion OK'" 2>/dev/null; then
    echo "❌ Erreur: Impossible de se connecter au VPS"
    echo "Vérifiez:"
    echo "  - La connexion internet"
    echo "  - Les identifiants SSH"
    echo "  - Que le serveur est accessible"
    exit 1
fi
echo "✅ Connexion SSH réussie"

# Vérification des fichiers locaux
echo ""
echo "📋 Vérification des fichiers locaux..."

# Liste des dossiers à copier
FOLDERS=("public" "src" "scripts")
# Liste des fichiers à copier
FILES=(".env.local" "package.json" "postcss.config.mjs" "next.config.ts" "tsconfig.json")

# Vérification des dossiers
for folder in "${FOLDERS[@]}"; do
    if [ ! -d "$LOCAL_APP_DIR/$folder" ]; then
        echo "⚠️  Dossier manquant: $LOCAL_APP_DIR/$folder"
    else
        echo "✅ Dossier trouvé: $folder"
    fi
done

# Vérification des fichiers
for file in "${FILES[@]}"; do
    if [ ! -f "$LOCAL_APP_DIR/$file" ]; then
        echo "⚠️  Fichier manquant: $LOCAL_APP_DIR/$file"
    else
        echo "✅ Fichier trouvé: $file"
    fi
done

# Vérification des fichiers spéciaux
if [ ! -f "docker-compose.yml" ]; then
    echo "⚠️  Fichier manquant: docker-compose.yml (racine du projet)"
else
    echo "✅ Fichier trouvé: docker-compose.yml"
fi

if [ ! -f "init-db.sql" ]; then
    echo "⚠️  Fichier manquant: init-db.sql (racine du projet)"
else
    echo "✅ Fichier trouvé: init-db.sql"
fi

echo ""
read -p "🤔 Continuer la synchronisation ? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Synchronisation annulée"
    exit 1
fi

# Création du répertoire de destination sur le VPS
echo ""
echo "📁 Préparation du répertoire de destination..."
ssh $VPS_USER@$VPS_IP << EOF
echo "Création du répertoire $VPS_PATH..."
mkdir -p $VPS_PATH
echo "Configuration des permissions..."
chmod 755 $VPS_PATH
echo "✅ Répertoire prêt"
EOF

# Fonction de synchronisation avec rsync
sync_with_rsync() {
    local source=$1
    local dest=$2
    local description=$3
    
    echo "📦 Synchronisation: $description"
    if rsync -avz --progress --delete "$source" "$VPS_USER@$VPS_IP:$dest"; then
        echo "✅ $description synchronisé avec succès"
    else
        echo "❌ Erreur lors de la synchronisation de $description"
        return 1
    fi
}

# Synchronisation des dossiers
echo ""
echo "📂 Synchronisation des dossiers..."
for folder in "${FOLDERS[@]}"; do
    if [ -d "$LOCAL_APP_DIR/$folder" ]; then
        sync_with_rsync "$LOCAL_APP_DIR/$folder/" "$VPS_PATH/$folder/" "Dossier $folder"
    fi
done

# Synchronisation des fichiers
echo ""
echo "📄 Synchronisation des fichiers..."
for file in "${FILES[@]}"; do
    if [ -f "$LOCAL_APP_DIR/$file" ]; then
        echo "📦 Copie: $file"
        if scp "$LOCAL_APP_DIR/$file" "$VPS_USER@$VPS_IP:$VPS_PATH/"; then
            echo "✅ $file copié avec succès"
        else
            echo "❌ Erreur lors de la copie de $file"
        fi
    fi
done

# Synchronisation des fichiers spéciaux (racine du projet)
echo ""
echo "📄 Synchronisation des fichiers de configuration..."

if [ -f "docker-compose.yml" ]; then
    echo "📦 Copie: docker-compose.yml"
    if scp "docker-compose.yml" "$VPS_USER@$VPS_IP:$VPS_PATH/"; then
        echo "✅ docker-compose.yml copié avec succès"
    else
        echo "❌ Erreur lors de la copie de docker-compose.yml"
    fi
fi

if [ -f "init-db.sql" ]; then
    echo "📦 Copie: init-db.sql"
    if scp "init-db.sql" "$VPS_USER@$VPS_IP:$VPS_PATH/"; then
        echo "✅ init-db.sql copié avec succès"
    else
        echo "❌ Erreur lors de la copie de init-db.sql"
    fi
fi

# Vérification de la synchronisation
echo ""
echo "🔍 Vérification de la synchronisation..."
ssh $VPS_USER@$VPS_IP << EOF
echo "📋 Contenu du répertoire $VPS_PATH:"
ls -la $VPS_PATH/
echo ""
echo "📊 Taille des dossiers:"
du -sh $VPS_PATH/*/ 2>/dev/null || echo "Aucun dossier trouvé"
echo ""
echo "📄 Fichiers de configuration:"
ls -la $VPS_PATH/*.{json,ts,mjs,local,yml,sql} 2>/dev/null || echo "Certains fichiers de config manquent"
EOF

# Configuration des permissions
echo ""
echo "🔧 Configuration des permissions..."
ssh $VPS_USER@$VPS_IP << EOF
echo "Configuration des permissions pour $VPS_PATH..."
chmod -R 755 $VPS_PATH
chmod 644 $VPS_PATH/*.json 2>/dev/null || true
chmod 644 $VPS_PATH/*.ts 2>/dev/null || true
chmod 644 $VPS_PATH/*.mjs 2>/dev/null || true
chmod 600 $VPS_PATH/.env.local 2>/dev/null || true
chmod 644 $VPS_PATH/*.yml 2>/dev/null || true
chmod 644 $VPS_PATH/*.sql 2>/dev/null || true

# Permissions spéciales pour les uploads
if [ -d "$VPS_PATH/public/uploads" ]; then
    chmod 755 $VPS_PATH/public/uploads
    echo "✅ Permissions uploads configurées"
fi

echo "✅ Permissions configurées"
EOF

# Résumé final
echo ""
echo "🎉 Synchronisation terminée avec succès!"
echo ""
echo "📊 Résumé:"
echo "   - Dossiers synchronisés: ${#FOLDERS[@]}"
echo "   - Fichiers copiés: $((${#FILES[@]} + 2))"
echo "   - Destination: $VPS_USER@$VPS_IP:$VPS_PATH"
echo ""
echo "🔗 Prochaines étapes:"
echo "   1. Se connecter au VPS: ssh $VPS_USER@$VPS_IP"
echo "   2. Aller dans le répertoire: cd $VPS_PATH"
echo "   3. Installer les dépendances: npm install"
echo "   4. Démarrer les services: docker-compose up -d"
echo ""
echo "💡 Commandes utiles:"
echo "   - Voir les fichiers: ssh $VPS_USER@$VPS_IP 'ls -la $VPS_PATH'"
echo "   - Voir les logs: ssh $VPS_USER@$VPS_IP 'cd $VPS_PATH && docker-compose logs -f'"
echo "   - Redémarrer: ssh $VPS_USER@$VPS_IP 'cd $VPS_PATH && docker-compose restart'"
