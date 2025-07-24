#!/bin/bash

# Script de synchronisation interactif vers VPS
# Interface utilisateur conviviale

# Configuration
VPS_IP="167.86.93.157"
VPS_USER="vpsadmin"
VPS_PATH="/home/vpsadmin/newslettre"
LOCAL_APP_DIR="./app"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fonction d'affichage coloré
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Header
clear
print_color $PURPLE "╔══════════════════════════════════════════════════════════════╗"
print_color $PURPLE "║                    📡 SYNC TO VPS                           ║"
print_color $PURPLE "║                Newsletter KCS Deployment                     ║"
print_color $PURPLE "╚══════════════════════════════════════════════════════════════╝"
echo ""
print_color $CYAN "🎯 Destination: $VPS_USER@$VPS_IP:$VPS_PATH"
print_color $CYAN "📁 Source locale: $LOCAL_APP_DIR"
echo ""

# Menu de sélection
print_color $YELLOW "🔧 Options de synchronisation:"
echo "   1) 🚀 Synchronisation complète (recommandé)"
echo "   2) 📂 Dossiers seulement (public, src, scripts)"
echo "   3) 📄 Fichiers de config seulement"
echo "   4) ⚡ Synchronisation rapide (sans vérifications)"
echo "   5) 🔍 Vérifier l'état du serveur"
echo "   6) ❌ Annuler"
echo ""

read -p "$(print_color $BLUE "Choisissez une option (1-6): ")" choice

case $choice in
    1)
        SYNC_TYPE="complete"
        print_color $GREEN "✅ Synchronisation complète sélectionnée"
        ;;
    2)
        SYNC_TYPE="folders"
        print_color $GREEN "✅ Synchronisation des dossiers sélectionnée"
        ;;
    3)
        SYNC_TYPE="config"
        print_color $GREEN "✅ Synchronisation des fichiers de config sélectionnée"
        ;;
    4)
        SYNC_TYPE="quick"
        print_color $GREEN "✅ Synchronisation rapide sélectionnée"
        ;;
    5)
        SYNC_TYPE="check"
        print_color $GREEN "✅ Vérification de l'état du serveur"
        ;;
    6)
        print_color $RED "❌ Synchronisation annulée"
        exit 0
        ;;
    *)
        print_color $RED "❌ Option invalide"
        exit 1
        ;;
esac

echo ""

# Test de connexion
print_color $BLUE "🔐 Test de connexion SSH..."
if ssh -o ConnectTimeout=5 -o BatchMode=yes $VPS_USER@$VPS_IP "echo 'Connexion réussie'" 2>/dev/null; then
    print_color $GREEN "✅ Connexion SSH établie"
else
    print_color $RED "❌ Impossible de se connecter au VPS"
    print_color $YELLOW "💡 Vérifiez vos identifiants SSH ou configurez une clé:"
    print_color $YELLOW "   ssh-copy-id $VPS_USER@$VPS_IP"
    exit 1
fi

# Fonction de vérification de l'état du serveur
check_server_status() {
    print_color $BLUE "🔍 Vérification de l'état du serveur..."
    ssh $VPS_USER@$VPS_IP << 'EOF'
echo "📊 Informations système:"
echo "  - OS: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "  - Uptime: $(uptime -p 2>/dev/null || uptime)"
echo "  - Espace disque: $(df -h / | tail -1 | awk '{print $4 " disponible"}')"
echo "  - Mémoire: $(free -h | grep Mem | awk '{print $7 " disponible"}')"
echo ""
echo "📁 État du répertoire /home/vpsadmin/newslettre:"
if [ -d "/home/vpsadmin/newslettre" ]; then
    cd /home/vpsadmin/newslettre
    echo "  - Taille: $(du -sh . | cut -f1)"
    echo "  - Fichiers: $(find . -type f | wc -l)"
    echo "  - Dernière modification: $(stat -c %y . | cut -d. -f1)"
    echo ""
    echo "📋 Contenu:"
    ls -la | head -10
else
    echo "  ❌ Répertoire n'existe pas encore"
fi
echo ""
echo "🐳 État Docker:"
if command -v docker > /dev/null 2>&1; then
    echo "  ✅ Docker installé: $(docker --version | cut -d, -f1)"
    if docker-compose ps 2>/dev/null | grep -q "Up"; then
        echo "  🟢 Containers actifs:"
        docker-compose ps | grep "Up"
    else
        echo "  🔴 Aucun container actif"
    fi
else
    echo "  ❌ Docker non installé"
fi
EOF
    
    if [ "$SYNC_TYPE" = "check" ]; then
        print_color $GREEN "✅ Vérification terminée"
        exit 0
    fi
}

# Exécution de la vérification pour tous les types sauf quick
if [ "$SYNC_TYPE" != "quick" ]; then
    check_server_status
    echo ""
    read -p "$(print_color $BLUE "Continuer avec la synchronisation ? (y/N): ")" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_color $RED "❌ Synchronisation annulée"
        exit 0
    fi
fi

# Préparation du serveur
print_color $BLUE "📁 Préparation du serveur..."
ssh $VPS_USER@$VPS_IP << EOF
mkdir -p $VPS_PATH/{public/uploads,src,scripts}
chmod -R 755 $VPS_PATH
if [ -f "$VPS_PATH/.env.local" ]; then
    cp $VPS_PATH/.env.local $VPS_PATH/.env.local.backup.\$(date +%Y%m%d_%H%M%S)
fi
EOF
print_color $GREEN "✅ Serveur préparé"

# Synchronisation selon le type choisi
case $SYNC_TYPE in
    "complete"|"folders")
        print_color $BLUE "📂 Synchronisation des dossiers..."
        
        # Public
        print_color $CYAN "  📦 Dossier public/"
        if scp -r $LOCAL_APP_DIR/public $VPS_USER@$VPS_IP:$VPS_PATH/ 2>/dev/null; then
            print_color $GREEN "  ✅ public/ synchronisé"
        else
            print_color $RED "  ❌ Erreur public/"
        fi
        
        # Src
        print_color $CYAN "  📦 Dossier src/"
        if scp -r $LOCAL_APP_DIR/src $VPS_USER@$VPS_IP:$VPS_PATH/ 2>/dev/null; then
            print_color $GREEN "  ✅ src/ synchronisé"
        else
            print_color $RED "  ❌ Erreur src/"
        fi
        
        # Scripts
        if [ -d "$LOCAL_APP_DIR/scripts" ]; then
            print_color $CYAN "  📦 Dossier scripts/"
            if scp -r $LOCAL_APP_DIR/scripts $VPS_USER@$VPS_IP:$VPS_PATH/ 2>/dev/null; then
                print_color $GREEN "  ✅ scripts/ synchronisé"
            else
                print_color $RED "  ❌ Erreur scripts/"
            fi
        fi
        
        if [ "$SYNC_TYPE" = "folders" ]; then
            print_color $GREEN "✅ Synchronisation des dossiers terminée"
            exit 0
        fi
        ;;
esac

case $SYNC_TYPE in
    "complete"|"config"|"quick")
        print_color $BLUE "📄 Synchronisation des fichiers de configuration..."
        
        # Fichiers depuis app/
        files=(".env.local" "package.json" "postcss.config.mjs" "next.config.ts" "tsconfig.json")
        for file in "${files[@]}"; do
            if [ -f "$LOCAL_APP_DIR/$file" ]; then
                print_color $CYAN "  📦 $file"
                if scp "$LOCAL_APP_DIR/$file" "$VPS_USER@$VPS_IP:$VPS_PATH/" 2>/dev/null; then
                    print_color $GREEN "  ✅ $file"
                else
                    print_color $RED "  ❌ Erreur $file"
                fi
            fi
        done
        
        # Fichiers depuis la racine
        root_files=("docker-compose.yml" "init-db.sql")
        for file in "${root_files[@]}"; do
            if [ -f "$file" ]; then
                print_color $CYAN "  📦 $file"
                if scp "$file" "$VPS_USER@$VPS_IP:$VPS_PATH/" 2>/dev/null; then
                    print_color $GREEN "  ✅ $file"
                else
                    print_color $RED "  ❌ Erreur $file"
                fi
            fi
        done
        ;;
esac

# Configuration des permissions
print_color $BLUE "🔧 Configuration des permissions..."
ssh $VPS_USER@$VPS_IP << EOF
cd $VPS_PATH
chmod -R 755 .
chmod 600 .env.local 2>/dev/null || true
chmod 644 *.json *.ts *.mjs *.yml *.sql 2>/dev/null || true
mkdir -p public/uploads && chmod 755 public/uploads
EOF
print_color $GREEN "✅ Permissions configurées"

# Rapport final
echo ""
print_color $PURPLE "╔══════════════════════════════════════════════════════════════╗"
print_color $PURPLE "║                    🎉 SYNCHRONISATION TERMINÉE              ║"
print_color $PURPLE "╚══════════════════════════════════════════════════════════════╝"
echo ""

print_color $GREEN "✅ Synchronisation réussie vers $VPS_USER@$VPS_IP:$VPS_PATH"
echo ""
print_color $YELLOW "🚀 Prochaines étapes sur le serveur:"
print_color $CYAN "   1. ssh $VPS_USER@$VPS_IP"
print_color $CYAN "   2. cd $VPS_PATH"
print_color $CYAN "   3. npm install --production"
print_color $CYAN "   4. docker-compose up -d"
echo ""
print_color $YELLOW "🔧 Commandes utiles:"
print_color $CYAN "   - Logs: docker-compose logs -f"
print_color $CYAN "   - Status: docker-compose ps"
print_color $CYAN "   - Restart: docker-compose restart"
echo ""
print_color $YELLOW "🌐 Application accessible sur:"
print_color $CYAN "   - HTTP: http://$VPS_IP:3001"
print_color $CYAN "   - HTTPS: https://newslettre.kcs.zidani.org"
