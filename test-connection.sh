#!/bin/bash

# Test de connexion au VPS
VPS_IP="167.86.93.157"
VPS_USER="vpsadmin"
DOMAIN="newslettre.kcs.zidani.org"

echo "🔍 Test de connexion au VPS"
echo "=========================="
echo "VPS: $VPS_USER@$VPS_IP"
echo "Domaine: $DOMAIN"
echo ""

echo "📡 Test de ping..."
if ping -c 3 $VPS_IP > /dev/null 2>&1; then
    echo "✅ Ping réussi vers $VPS_IP"
else
    echo "❌ Ping échoué vers $VPS_IP"
    exit 1
fi

echo ""
echo "🔐 Test de connexion SSH..."
echo "Tentative de connexion à $VPS_USER@$VPS_IP..."
echo ""

# Test de connexion SSH avec timeout
timeout 10 ssh -o ConnectTimeout=5 -o BatchMode=yes $VPS_USER@$VPS_IP "echo 'Connexion SSH réussie!'" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Connexion SSH réussie!"
    echo ""
    echo "🔍 Informations du serveur:"
    ssh $VPS_USER@$VPS_IP << 'EOF'
echo "OS: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
echo "Espace disque disponible:"
df -h / | tail -1 | awk '{print "  " $4 " disponible sur " $2 " (" $5 " utilisé)"}'
echo "Mémoire disponible:"
free -h | grep Mem | awk '{print "  " $7 " disponible sur " $2}'
echo ""
echo "🐳 Docker installé:"
if command -v docker > /dev/null 2>&1; then
    echo "  ✅ Docker: $(docker --version)"
else
    echo "  ❌ Docker non installé"
fi

if command -v docker-compose > /dev/null 2>&1; then
    echo "  ✅ Docker Compose: $(docker-compose --version)"
else
    echo "  ❌ Docker Compose non installé"
fi

echo ""
echo "🌐 Nginx installé:"
if command -v nginx > /dev/null 2>&1; then
    echo "  ✅ Nginx: $(nginx -v 2>&1)"
else
    echo "  ❌ Nginx non installé"
fi

echo ""
echo "📁 Répertoire de déploiement:"
if [ -d "/home/vpsadmin/newslettre" ]; then
    echo "  ✅ /home/vpsadmin/newslettre existe"
    ls -la /home/vpsadmin/newslettre/ 2>/dev/null | head -10
else
    echo "  ❌ /home/vpsadmin/newslettre n'existe pas"
fi
EOF

else
    echo "❌ Connexion SSH échouée!"
    echo ""
    echo "🔧 Solutions possibles:"
    echo "   1. Vérifiez que le serveur SSH est démarré sur le VPS"
    echo "   2. Vérifiez les identifiants (utilisateur: $VPS_USER)"
    echo "   3. Vérifiez que le port SSH (22) est ouvert"
    echo "   4. Configurez l'authentification par clé SSH si nécessaire"
    echo ""
    echo "💡 Pour configurer l'authentification par clé SSH:"
    echo "   ssh-keygen -t rsa -b 4096 -C 'votre-email@example.com'"
    echo "   ssh-copy-id $VPS_USER@$VPS_IP"
    exit 1
fi

echo ""
echo "🌐 Test de résolution DNS..."
if nslookup $DOMAIN > /dev/null 2>&1; then
    echo "✅ Résolution DNS réussie pour $DOMAIN"
    echo "   IP: $(nslookup $DOMAIN | grep -A1 'Name:' | tail -1 | awk '{print $2}')"
else
    echo "❌ Résolution DNS échouée pour $DOMAIN"
    echo "⚠️  Assurez-vous que le domaine pointe vers $VPS_IP"
fi

echo ""
echo "🎉 Test de connexion terminé!"
echo ""
echo "📝 Prochaines étapes:"
echo "   1. Si tout est OK, lancez: ./setup-server.sh"
echo "   2. Puis lancez: ./deploy.sh"
echo "   3. Configurez la clé OpenAI sur le serveur"
