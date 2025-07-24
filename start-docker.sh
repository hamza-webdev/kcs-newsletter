#!/bin/bash

# Script de démarrage Docker pour Newsletter KCS

echo "🐳 Démarrage de l'application Newsletter KCS avec Docker"
echo "======================================================="
echo ""

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Vérifier si Docker Compose est installé
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

# Vérifier si le fichier .env existe
if [ ! -f .env ]; then
    echo "⚠️  Fichier .env non trouvé. Création à partir du template..."
    cp .env.docker .env
    echo "📝 Fichier .env créé. IMPORTANT: Configurez votre clé OpenAI dans .env"
    echo ""
fi

# Vérifier la clé OpenAI
if grep -q "your-openai-api-key-here" .env; then
    echo "⚠️  ATTENTION: Vous devez configurer votre clé OpenAI dans le fichier .env"
    echo "   Éditez le fichier .env et remplacez 'your-openai-api-key-here' par votre vraie clé"
    echo ""
    read -p "🤔 Continuer quand même ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Démarrage annulé. Configurez d'abord votre clé OpenAI."
        exit 0
    fi
fi

echo "🔧 Arrêt des containers existants..."
docker-compose down 2>/dev/null || docker compose down 2>/dev/null || echo "Aucun container à arrêter"

echo ""
echo "🏗️  Construction et démarrage des services..."
echo "   - PostgreSQL (Base de données)"
echo "   - pgAdmin (Interface d'administration)"
echo "   - MailHog (Serveur email de test)"
echo "   - Newsletter App (Application Next.js)"
echo ""

# Utiliser docker-compose ou docker compose selon la version
if command -v docker-compose &> /dev/null; then
    docker-compose up --build -d
else
    docker compose up --build -d
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Application démarrée avec succès!"
    echo ""
    echo "📋 Services disponibles:"
    echo "   🌐 Application:     http://localhost:3001"
    echo "   🗄️  pgAdmin:        http://localhost:5050"
    echo "      └─ Email:       admin@newsletter-kcs.local"
    echo "      └─ Mot de passe: admin123"
    echo "   📧 MailHog:        http://localhost:8025"
    echo "   🐘 PostgreSQL:     localhost:5433"
    echo ""
    echo "⏳ Attente du démarrage complet des services..."
    sleep 10
    
    echo "🔍 Vérification de l'état des services..."
    if command -v docker-compose &> /dev/null; then
        docker-compose ps
    else
        docker compose ps
    fi
    
    echo ""
    echo "📊 Logs en temps réel (Ctrl+C pour arrêter):"
    echo "   Pour voir les logs: docker-compose logs -f"
    echo "   Pour arrêter: docker-compose down"
    echo ""
    
    # Test de santé de l'application
    echo "🏥 Test de santé de l'application..."
    sleep 5
    if curl -f http://localhost:3001/api/health &>/dev/null; then
        echo "✅ Application en bonne santé!"
    else
        echo "⚠️  L'application démarre encore... Patientez quelques instants."
    fi
    
else
    echo "❌ Erreur lors du démarrage des services"
    echo "📋 Vérifiez les logs avec: docker-compose logs"
    exit 1
fi
