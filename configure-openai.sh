#!/bin/bash

# Configuration de la clé OpenAI sur le serveur
VPS_IP="167.86.93.157"
VPS_USER="vpsadmin"
DEPLOY_DIR="/home/vpsadmin/newslettre"

echo "🔑 Configuration de la clé OpenAI"
echo "================================"
echo "VPS: $VPS_USER@$VPS_IP"
echo ""

# Demander la clé OpenAI
read -p "🔐 Entrez votre clé API OpenAI: " OPENAI_KEY

if [ -z "$OPENAI_KEY" ]; then
    echo "❌ Clé OpenAI requise!"
    exit 1
fi

echo ""
echo "📝 Configuration de la clé sur le serveur..."

# Connexion SSH et configuration
ssh $VPS_USER@$VPS_IP << EOF
echo "📁 Vérification du répertoire de déploiement..."
if [ ! -d "$DEPLOY_DIR" ]; then
    echo "❌ Répertoire $DEPLOY_DIR non trouvé!"
    echo "Veuillez d'abord déployer l'application avec ./deploy.sh"
    exit 1
fi

cd $DEPLOY_DIR

echo "🔧 Sauvegarde de l'ancien .env.local..."
if [ -f ".env.local" ]; then
    cp .env.local .env.local.backup.\$(date +%Y%m%d_%H%M%S)
fi

echo "✏️  Mise à jour de la clé OpenAI..."
# Remplacer la clé OpenAI dans le fichier .env.local
sed -i 's/OPENAI_API_KEY=.*/OPENAI_API_KEY=$OPENAI_KEY/' .env.local

# Vérifier que la clé a été mise à jour
if grep -q "OPENAI_API_KEY=$OPENAI_KEY" .env.local; then
    echo "✅ Clé OpenAI mise à jour avec succès!"
else
    echo "❌ Erreur lors de la mise à jour de la clé!"
    exit 1
fi

echo "🔄 Redémarrage de l'application..."
docker-compose -f docker-compose.prod.yml restart app

echo "⏳ Attente du redémarrage..."
sleep 10

echo "🔍 Vérification du statut..."
docker-compose -f docker-compose.prod.yml ps

echo "📋 Test de l'API..."
# Test simple de l'API
curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/api/newsletters > /tmp/api_test
API_STATUS=\$(cat /tmp/api_test)

if [ "\$API_STATUS" = "200" ]; then
    echo "✅ API fonctionne correctement (Status: \$API_STATUS)"
else
    echo "⚠️  API Status: \$API_STATUS (peut être normal si pas de données)"
fi

echo ""
echo "🎉 Configuration terminée!"
echo ""
echo "🌐 Votre application est accessible à:"
echo "   - https://newslettre.kcs.zidani.org"
echo "   - pgAdmin: https://newslettre.kcs.zidani.org/pgadmin/"
echo ""
echo "🔧 Pour voir les logs de l'application:"
echo "   docker-compose -f $DEPLOY_DIR/docker-compose.prod.yml logs -f app"
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Configuration de la clé OpenAI terminée avec succès!"
    echo ""
    echo "🧪 Test de la génération d'images:"
    echo "   1. Allez sur https://newslettre.kcs.zidani.org/admin-postgres/nouvelle-newsletter"
    echo "   2. Saisissez un titre"
    echo "   3. Cliquez sur 'Générer avec IA'"
    echo "   4. Vérifiez que l'image se génère correctement"
    echo ""
    echo "📊 Monitoring:"
    echo "   - Logs: ssh $VPS_USER@$VPS_IP 'cd $DEPLOY_DIR && docker-compose -f docker-compose.prod.yml logs -f app'"
    echo "   - Status: ssh $VPS_USER@$VPS_IP 'cd $DEPLOY_DIR && docker-compose -f docker-compose.prod.yml ps'"
else
    echo ""
    echo "❌ Erreur lors de la configuration!"
    echo "Vérifiez la connexion SSH et réessayez."
fi
